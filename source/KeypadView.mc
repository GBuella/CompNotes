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
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
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

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Timer;

class KeypadView extends WatchUi.View {
    private var _buttonSize as Numeric = 0;
    private var _buttonTop as Array<Numeric> = [];
    private var _buttonLeft as Array<Numeric> = [];
    private var _buttonLabel as Array<String> = [];
    private const _gap as Number = 3;
    private var _textTop as Numeric = 0;
    private var _textLeft as Numeric = 0;
    private var _textRight as Numeric = 0;
    private var _center as Numeric = 0;
    private var _labelTop as Numeric = 0;
    private var _text as Array<String> = [];
    private var _textStr as String = "";
    private var _highlightedKey as Number = -1;
    private var _underLineY as Numeric = 0;
    private const _textFont = Graphics.FONT_SMALL;
    private const _labelFont = Graphics.FONT_XTINY;
    private const _buttonFont = Graphics.FONT_XTINY;
    private var _isCursorOn as Boolean = false;
    private var _cursorTimer as Timer.Timer = new Timer.Timer();
    private var _labelStr as String;
    private var _labelEditmode as Boolean;
    private var _canEditLabel as Boolean;
    private var _specialSymbol as String;
    private var _saveIcon as BitmapReference;

    function initialize(label as String?, specialSymbol as String) {
        View.initialize();
        if (label == null) {
            _labelStr = "";
            _labelEditmode = true;
            _canEditLabel = true;
        }
        else {
            _labelStr = label;
            _labelEditmode = false;
            _canEditLabel = false;
        }
        _specialSymbol = specialSymbol;
        _saveIcon = Application.loadResource(Rez.Drawables.saveIcon);
    }

    private function drawButton(dc as Dc, n as Number) as Void {
        dc.setPenWidth((n == _highlightedKey) ? 3 : 1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var top = _buttonTop[n];
        var left = _buttonLeft[n];
        var label = _buttonLabel[n];
        if (label.equals("backspace")) {
            var t = top + _buttonSize / 8;
            var b = top + _buttonSize - _buttonSize / 8;
            var ltip = left + _buttonSize / 8;
            var l = left + _buttonSize / 3;
            var r = left + _buttonSize - _buttonSize / 8;
            dc.drawLine(l, t, r, t);
            dc.drawLine(r, t, r, b);
            dc.drawLine(l, b, r, b);
            dc.drawLine(ltip, (t + b) / 2, l, b);
            dc.drawLine(ltip, (t + b) / 2, l, t);
            t += _buttonSize / 8;
            b -= _buttonSize / 8;
            l += _buttonSize / 8;
            r -= _buttonSize / 8;
            dc.setPenWidth(3);
            dc.drawLine(l, t, r, b);
            dc.drawLine(l, b, r, t);
            return;
        }
        if (label.equals("savebutton")) {
            dc.drawBitmap(left + _buttonSize / 2 - _saveIcon.getWidth() / 2,
                          top + _buttonSize / 2 - _saveIcon.getHeight() / 2,
                          _saveIcon);
        }
        if ((n == _highlightedKey) or !label.equals("savebutton")) {
            dc.setPenWidth((n == _highlightedKey) ? 3 : 1);
            dc.drawRoundedRectangle(left, top, _buttonSize, _buttonSize, 4);
        }
        if (label.equals(" ")) {
            var l = left + _buttonSize / 8;
            var r = left + _buttonSize - _buttonSize / 8;
            var b = top + _buttonSize - _buttonSize / 8;
            var t = b - _buttonSize / 5;
            dc.drawLine(l, t, l, b);
            dc.drawLine(l, b, r, b);
            dc.drawLine(r, t, r, b);
        }
        else if (!label.equals("savebutton")) {
            dc.drawText(left + _buttonSize / 2, top + _buttonSize / 2,
                        _buttonFont, label,
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function timerCallback() as Void {
        _isCursorOn = !_isCursorOn;
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        _cursorTimer.start(self.method(:timerCallback), 800, true);
    }

    function onHide() as Void {
        _cursorTimer.stop();
    }

    function onLabelDone() as Void {
        _labelStr = _textStr;
        _textStr = "";
        _text = [];
        _labelEditmode = false;
    }

    function labelEditing() as Boolean {
        return _labelEditmode;
    }

    function addRow(left as Numeric, top as Numeric, labels as Array<String>) as Void {
        for (var i = 0; i < labels.size(); ++i) {
            _buttonTop.add(top);
            _buttonLeft.add(left + i * (_buttonSize + _gap));
            _buttonLabel.add(labels[i]);
        }
    }

    function onLayout(dc as Dc) as Void {
        var w = dc.getWidth();
        var radius = w / 2;
        _center = radius;
        var r2;
        var row_top;
        var row_left;
        var shape = System.getDeviceSettings().screenShape;
        if (shape == System.SCREEN_SHAPE_ROUND) {
            _buttonSize = radius / 3 - 1;
            r2 = radius * radius;
            row_top = radius + Math.sqrt(r2 - (_buttonSize * 1.5) * (_buttonSize * 1.5)) - _buttonSize;
            row_left = radius - _buttonSize * 1.5;
        }
        else {
            _buttonSize = w / 4 - _gap;
            row_top = dc.getHeight() - _buttonSize - 2;
            row_left = 2;
        }
        addRow(row_left, row_top, ["*", "0", "#"]); // indexes: 0, 1, 2
        row_top -= _buttonSize + _gap;
        row_left = radius - 2 * _buttonSize;
        addRow(row_left, row_top, ["7", "8", "9", " "]); // 3, 4, 5, 6
        row_top -= _buttonSize + _gap;
        addRow(row_left, row_top, ["4", "5", "6", _specialSymbol]); // 7, 8, 9, 10
        row_top -= _buttonSize + _gap;
        addRow(row_left, row_top, ["1", "2", "3", "backspace"]); // 11, 12, 13, 14
        _textTop = row_top - dc.getFontHeight(_textFont) - _gap;
        _underLineY = row_top - _gap;
        _textRight = w - _buttonSize * 2;
        _buttonTop.add(_textTop);
        _buttonLeft.add(_textRight);
        _buttonLabel.add("savebutton");
        _labelTop = _textTop - dc.getFontHeight(_labelFont) - _gap;
        _textLeft = _buttonSize;
    }

    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        for (var i = 0; i < _buttonTop.size(); ++i) {
            drawButton(dc, i);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(_textLeft, _textTop, _textFont, _textStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setPenWidth(1);
        dc.drawLine(_textLeft, _underLineY, _textRight, _underLineY);
        dc.drawLine(_textLeft, _underLineY, _textLeft, _underLineY - 10);
        dc.drawLine(_textRight, _underLineY, _textRight, _underLineY - 10);
        if (_isCursorOn) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            var cursorX = _textLeft + dc.getTextWidthInPixels(_textStr, _textFont);
            dc.setPenWidth(4);
            dc.drawLine(cursorX, _textTop, cursorX, _underLineY - 1);
        }
        if (!_labelEditmode) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(_center, _labelTop, _labelFont, _labelStr,
                        Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function isButton(click as ClickEvent) as Number? {
        var x = click.getCoordinates()[0];
        var y = click.getCoordinates()[1];
        for (var i = 0; i < _buttonTop.size(); ++i) {
            if (_buttonTop[i] < y and _buttonTop[i] + _buttonSize > y
                and _buttonLeft[i] < x and _buttonLeft[i] + _buttonSize > x) {
                return i;
            }
        }
        return null;
    }

    function highligthButton(i as Number) as Void {
        _highlightedKey = i;
    }

    function onButtonTap() as Void {
        var label = _buttonLabel[_highlightedKey];
        if (label.equals("backspace")) {
            if (_text.size() == 0) {
                if (_canEditLabel and !_labelEditmode) {
                    _labelEditmode = true;
                }
                return;
            }
            _text = _text.slice(0, -1);
            _textStr = "";
            for (var i = 0; i < _text.size(); ++i) {
                _textStr += _text[i];
            }
            return;
        }

        if (_textStr.length() < $.CNNoteMaxLen) {
            _text.add(label);
            _textStr += label;
        }
    }

    function getString() as String {
        return _textStr;
    }

    function getLabelString() as String {
        return _labelStr;
    }

    function highlightPrevButton() as Void {
        _highlightedKey--;
        if (_highlightedKey < 0) {
            _highlightedKey = _buttonTop.size() - 1;
        }
        WatchUi.requestUpdate();
    }

    function highlightNextButton() as Void {
        _highlightedKey++;
        if (_highlightedKey == _buttonTop.size()) {
            _highlightedKey = 0;
        }
        WatchUi.requestUpdate();
    }

    function isAnyHighlighted() as Boolean {
        return _highlightedKey >= 0 and _highlightedKey < _buttonTop.size();
    }

    function isSaveHighlighted() as Boolean {
        if (isAnyHighlighted()) {
            return _buttonLabel[_highlightedKey].equals("savebutton");
        }
        else {
            return false;
        }
    }
}

class KeypadDelegate extends WatchUi.InputDelegate {
    private var _view as KeypadView;
    private var _note as Note;

    function initialize(view as KeypadView, note as Note) {
        InputDelegate.initialize();
        _note = note;
        _view = view;
    }

    function enterPressed() as Void {
        if (_view.labelEditing()) {
            _view.onLabelDone();
        }
        else {
            if (_note.isLabelEditable()) {
                _note.update(_view.getLabelString(), _view.getString());
            }
            else {
                _note.update(null, _view.getString());
            }
            WatchUi.popView($.CNSlideOutMethod);
        }
    }

    function onTap(click as ClickEvent) as Boolean {
        var buttonI = _view.isButton(click);
        if (buttonI instanceof Number) {
            _view.highligthButton(buttonI);
            if (_view.isSaveHighlighted()) {
                enterPressed();
            }
            else {
                _view.onButtonTap();
                WatchUi.requestUpdate();
            }
            return true;
        }
        return false;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (keyEvent.getKey() == KEY_ENTER) {
            if (_view.isAnyHighlighted() and !_view.isSaveHighlighted()) {
                _view.onButtonTap();
                WatchUi.requestUpdate();
            }
            else {
                enterPressed();
            }
            return true;
        }
        else if (keyEvent.getKey() == KEY_DOWN) {
            _view.highlightPrevButton();
            WatchUi.requestUpdate();
            return true;
        }
        else if (keyEvent.getKey() == KEY_UP) {
            _view.highlightNextButton();
            WatchUi.requestUpdate();
            return true;
        }
        else {
            return false;
        }
    }
}
