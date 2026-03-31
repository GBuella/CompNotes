/* vim: set et tw=120 ts=4 sw=4 cinoptions=+4,(0,t0: */
/*
 * Copyright 2026, Gabor Buella
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.System;
import Toybox.StringUtil;

class LongTextView extends View {
    private var _textSource as Array<String>;

    private var _textLines as Array<String> = [];
    private static const _font = Graphics.FONT_SYSTEM_XTINY;
    private var _firstLine as Number = 0;
    private var _lineHeight as Numeric = 0;

    // The dimensions of the text area
    private var _top as Numeric = 0;
    private var _left as Numeric = 0;
    private var _width as Numeric = 0;
    private var _displayLineCount as Number = 0;

    // Where to draw the triangles?
    private var _arrowX as Numeric = 0; // horizontal location of the tips
    private var _arrowLowY as Numeric = 0; // bottom of the lower triangle's tip

    function initialize(text as Array<String>) {
        View.initialize();
        _textSource = text;
    }

    function canForward() as Boolean {
        // Are there anymore lines to view?
        return _firstLine + _displayLineCount < _textLines.size();
    }

    function onLayout(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        _lineHeight = Graphics.getFontHeight(_font) + 1;
        _top = _lineHeight + 1;
        _arrowX = w / 2;
        _arrowLowY = h;
        var maxBottom = h - _lineHeight;
        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
            /*
             * Find a square, to use as text area. The top left corner is equally
             * far from the top and left of the screen.
             */
            var margin = w * 0.146;
            _left = margin;
            if (margin >= _top) { // make sure the a triangle with this height fits above the text
                _top = margin;
            }
            _width = w - 2 * _left;
            maxBottom = h - _lineHeight;
            if (maxBottom > h - _top) { // make sure the a triangle with this height fits below the text
                maxBottom = h - _top;
            }
        }
        else {
            // Assume the screen is square shaped.
            _width = w;
        }
        while (_top + (_displayLineCount + 1) * _lineHeight <= maxBottom) {
            _displayLineCount++;
        }

        generateLines(dc);
    }

    function generateLines(dc as Dc) as Void {
        var tokens = [];
        for (var i = 0; i < _textSource.size(); ++i) {
            var chars = _textSource[i].toCharArray();
            var token = [];
            for (var ci = 0; ci < chars.size(); ++ci) {
                if (!chars[ci].equals(' ')) {
                    token.add(chars[ci]);
                }
                else {
                    if (token.size() > 0) {
                        tokens.add(StringUtil.charArrayToString(token));
                    }
                    token = [];
                }
            }
            if (token.size() != 0) {
                tokens.add(StringUtil.charArrayToString(token));
            }
            tokens.add("\n");
        }
        var nextLine = "";
        for (var i = 0; i < tokens.size(); ++i) {
            if (tokens[i].equals("\n")) {
                _textLines.add(nextLine);
                nextLine = "";
                continue;
            }

            if (dc.getTextWidthInPixels(nextLine + " " + tokens[i], _font) <= _width) {
                if (!nextLine.equals("")) {
                    nextLine += " ";
                }
                nextLine += tokens[i];
            }
            else {
                _textLines.add(nextLine);
                nextLine = tokens[i];
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        if (_firstLine != 0) {
            dc.fillPolygon([[_arrowX, 0],
                            [_arrowX - _lineHeight / 2, _lineHeight],
                            [_arrowX + _lineHeight / 2, _lineHeight]]);
        }
        if (canForward()) {
            dc.fillPolygon([[_arrowX, _arrowLowY],
                            [_arrowX - _lineHeight / 2, _arrowLowY - _lineHeight],
                            [_arrowX + _lineHeight / 2, _arrowLowY - _lineHeight]]);
        }
        for (var i = 0; i < _displayLineCount; ++i) {
            dc.drawText(_left, _top + _lineHeight * i, _font,
                        _textLines[_firstLine + i], Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function isTapBackward(coors as Array<Number>) as Boolean {
        return coors[1] < _top + _lineHeight;
    }

    function isTapForward(coors as Array<Number>) as Boolean {
        return coors[1] > _arrowLowY - _lineHeight * 3;
    }

    function forward() as Boolean {
        if (canForward()) {
            _firstLine++;
            requestUpdate();
            return true;
        }
        return false;
    }

    function backward() as Boolean {
        if (_firstLine != 0) {
            _firstLine--;
            requestUpdate();
            return true;
        }
        return false;
    }
}

class LongTextViewDelegate extends InputDelegate {
    private var _view as LongTextView;

    function initialize(v as LongTextView) {
        InputDelegate.initialize();
        _view = v;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        if (_view.isTapBackward(clickEvent.getCoordinates())) {
            return _view.backward();
        }
        if (_view.isTapForward(clickEvent.getCoordinates())) {
            return _view.forward();
        }
        return false;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        if (swipeEvent.getDirection() == SWIPE_DOWN) {
            return _view.backward();
        }
        if (swipeEvent.getDirection() == SWIPE_UP) {
            return _view.forward();
        }
        return false;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == KEY_DOWN) {
            return _view.forward();
        }
        if (keyEvent.getKey() == KEY_UP) {
            return _view.backward();
        }
        return false;
    }
}
