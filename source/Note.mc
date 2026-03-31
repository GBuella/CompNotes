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
import Toybox.Complications;

class Note {
    // The id shoud match the complication id in the resource XML
    private var _id as Number;

    private var _mItem as MenuItem?;
    (:initialized) private var _name as String;
    private var _label as String;
    private var _value as String;
    (:initialized) private var _editLabel as Boolean;
    (:initialized) private var _specialSymbol as String;

    function getLabel() as String {
        // This is what is published as short label with the complication.
        // If there is no label set, then publish the name.

        if (_label.equals("")) {
            return _name;
        }
        else {
            return _label;
        }
    }

    function getValue() as String {
        return _value;
    }

    function isLabelEditable() as Boolean {
        return _editLabel;
    }

    function specialSymbol() as String {
        return _specialSymbol;
    }

    private function setupMenuItemSublabel() as Void {
        if (_mItem == null) {
            return;
        }
        if (_editLabel) {
            _mItem.setSubLabel(_label + " " + _value);
        }
        else {
            _mItem.setSubLabel(_value);
        }
    }

    function getMainMenuItem() as MenuItem {
        if (_mItem == null) {
            _mItem = new MenuItem(_name, null, _id, null);
            setupMenuItemSublabel();
        }
        return _mItem;
    }

    function publish() as Void {
        Complications.updateComplication(_id, {
            :value => (_value.equals("") ? null : _value),
            :shortLabel => getLabel()
        });
    }

    private function loadSettings() as Void {
        var id = _id.toString();
        _name = Application.Properties.getValue("name" + id) as String;
        if (_name.equals("")) {
            _name = id + ". " + Application.loadResource(Rez.Strings.note);
        }
        _editLabel = Application.Properties.getValue("editlabel" + id) as Boolean;
        _specialSymbol = Application.Properties.getValue("note" + id + "_special_symbol") as String;
        if (_specialSymbol.equals("")) {
            _specialSymbol = "🔑";
        }
        else if (_specialSymbol.length() > 3) {
            _specialSymbol = _specialSymbol.substring(0, 3);
        }
    }

    function reloadSettings() as Void {
        loadSettings();
        if (_mItem != null) {
            _mItem.setLabel(_name);
            setupMenuItemSublabel();
        }
        publish();
    }

    function initialize(n as Number) {
        _id = n;
        _label = "";
        _value = "";
        loadSettings();
        var x = Storage.getValue(_id) as Dictionary?;
        if (x instanceof Dictionary) {
            if (x.hasKey("label")) {
                _label = x.get("label") as String;
            }
            if (x.hasKey("value")) {
                _value = x.get("value") as String;
            }
            publish();
        }
    }

    function update(l as String?, v as String?) as Void {
        if (l == null and v == null) {
            return;
        }
        if (l != null) {
            _label = l;
        }
        if (v != null) {
            _value = v;
        }
        setupMenuItemSublabel();
        publish();
        Storage.setValue(_id, {"value" => _value, "label" => _label});
    }
}