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

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;


class CompNotesApp extends Application.AppBase {
    private var _notes as Array<Note>;
    private var _fromComp as Note?;

    function initialize() {
        AppBase.initialize();
        _notes = [];
        _fromComp = null;
    }

    function getNote(n as Number) as Note {
        return _notes[n - 1];
    }

    function onStart(state as Dictionary?) as Void {
        if (state != null) {
            if (state.hasKey(:launchedFromComplication)) {
                // Let getInitialView know that which complication to edit
                _fromComp = new Note(state.get(:launchedFromComplication) as Number);
                return;
            }
        }
        if (_notes.size() == 0) {
            for (var i = 0; i < $.CNNoteCount; ++i) {
                _notes.add(new Note(i + 1));
            }
        }
    }

    function onStop(state as Dictionary?) as Void {
        // TODO: is this needed?
        _fromComp = null;
    }

    function noteEditView(note as Note) as [Views, InputDelegates] {
        var view = new KeypadView(note.isLabelEditable() ? null : note.getLabel(),
                                  note.specialSymbol());
        return [view, new KeypadDelegate(view, note)];
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (_fromComp instanceof Note) {
            return noteEditView(_fromComp);
        }

        var menu = new WatchUi.Menu2({:title => loadResource(Rez.Strings.AppName)});
        for (var i = 0; i < _notes.size(); ++i) {
            menu.addItem(_notes[i].getMainMenuItem());
        }
        menu.addItem(new MenuItem(loadResource(Rez.Strings.menu_label_about), null, :about, null));

        return [menu, new CompNotesDelegate()];
    }

    function onSettingsChanged() as Void {
        for (var i = 0; i < _notes.size(); ++i) {
            _notes[i].reloadSettings();
        }
    }
}

function getApp() as CompNotesApp {
    return Application.getApp() as CompNotesApp;
}

function getNote(n as Number) as Note {
    return getApp().getNote(n);
}
