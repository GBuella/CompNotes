CopmlicationNotes

## Description

Quick notes, that can be seen on Watchfaces as complications.

Want to remember which locker you use in the gym today?
Want to remember the gate code for the AriBNB you're staying at?
Purchased a train ticket, and to see which car/seat reservation on your wrist?

You can very swiftly write any of these on a note on your watch, see your
note on your watchface without pressing any buttons, without reaching for your phone!

Settings:
Each note can be given a name. This name can also be displayed on some watchfaces.
Each note can be edited with a keypad keyboard on the watch. This keypad contains digits, and a few other symbols,
one of which can be choosen freely in the app settings.
Each note allows either editing a label and value separately, or can edited without modifying the label (see below for more explanation).

Usage examples, using watch faces from ManuelB:
https://apps.garmin.com/apps/787d97ad-a7cb-41f6-93fd-1897aec95caa
https://apps.garmin.com/apps/1cdab86b-58dd-47e2-9f4c-60a178859691

To remember your gym locker, you can choose one of the three notes, change its name to "Lock" in the mobile app settings, and set label to non-editable. Add this note to a watchface. You should see on your watchface something like: "Lock 123". Long tap on the complication to edit your locker number. As long as your code consists of no more than 5 digits, this should be easy!

What if you would remember your gate code for a place you are staying for the next four days, e.g. 12🔑5493. You need to use this gate code 3 times a day, but ManuelB's watchfaces only display up to 5 characters. Well, you can edit the label displayed next to the complication, you just need to enable this in the settings on your phone. Now you the keypad editor allow you to edit the label first, once that is confirmed, it allows you to edit the complication itself. Where in the previous scenario the watchface displayed "Lock 123", it should display e.g. "12 🔑5493".

Some other watchfaces, that support this complication, but without displaying a label:
https://apps.garmin.com/apps/c823674b-3a55-46b8-b352-c0a1a301d9cd
https://apps.garmin.com/apps/c9f57ab1-c334-4f9b-87ec-5458cc79c868

## TODO
- [x] Fix the key symbol
- [x] Handle WF tap
- [ ] Create glance - no point
- [x] Make the keypad look acceptable
- [ ] Add an expire option
- [x] Follow https://developer.garmin.com/connect-iq/monkey-c/coding-conventions/
- [x] Find a list of supported devices
- [ ] Fix publishing to Faceit - not possible, apparently
- [x] Support keypad while touch is off
- [x] Add option to publish comps with/without labels
- [x] Add a green tick mark to the keypad
- [x] Find a key emoji for the "key" symbol
- [x] Add option to edit label & value together
- [ ] Write a description of the settings for the Garmin App Store
- [ ] List supporting watchfaces in the G App Store description
- [ ] Create some images for the Garmin App Store

## Devices:

List according to https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFaceDelegate.html#onPress-instance_function
except Instinct watches, which don't have touchscreens - onPress can't work.

- Approach® S50
- Approach® S70 42mm
- Approach® S70 47mm
- D2™ Air X10
- D2™ Mach 1
- D2™ Mach 2
- Descent™ G2
- Descent™ Mk3 43mm / Mk3i 43mm
- Descent™ Mk3i 51mm
- Enduro™ 3
- epix™ (Gen 2) / quatix® 7 Sapphire
- epix™ Pro (Gen 2) 42mm
- epix™ Pro (Gen 2) 47mm / quatix® 7 Pro
- epix™ Pro (Gen 2) 51mm / D2™ Mach 1 Pro / tactix® 7 – AMOLED Edition
- fēnix® 7 / quatix® 7
- fēnix® 7 Pro - Solar Edition (no Wi-Fi)
- fēnix® 7 Pro
- fēnix® 7S Pro
- fēnix® 7S
- fēnix® 7X / tactix® 7 / quatix® 7X Solar / Enduro™ 2
- fēnix® 7X Pro - Solar Edition (no Wi-Fi)
- fēnix® 7X Pro
- fēnix® 8 43mm
- fēnix® 8 47mm / 51mm / tactix® 8 47mm / 51mm / quatix® 8 47mm / 51mm
- fēnix® 8 Pro 47mm / 51mm / MicroLED / quatix® 8 Pro 47mm / 51mm
- fēnix® 8 Solar 47mm
- fēnix® 8 Solar 51mm / tactix® 8 Solar 51mm
- fēnix® E
- Forerunner® 165 Music
- Forerunner® 165
- Forerunner® 265
- Forerunner® 265s
- Forerunner® 570 42mm
- Forerunner® 570 47mm
- Forerunner® 955 / Solar
- Forerunner® 965
- Forerunner® 970
- MARQ® (Gen 2) Athlete / Adventurer / Captain / Golfer / Carbon Edition / Commander - Carbon Edition
- MARQ® (Gen 2) Aviator
- Venu® 2 Plus
- Venu® 2
- Venu® 2S
- Venu® 3
- Venu® 3S
- Venu® 4 41mm
- Venu® 4 45mm / D2™ Air X15
- Venu® Sq 2 Music
- Venu® Sq 2
- Venu® X1
- vívoactive® 5
- vívoactive® 6
