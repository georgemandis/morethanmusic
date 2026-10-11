CoreMidi4J 1.6 (https://github.com/DerekCook/CoreMidi4J) by Derek Cook and James Elliott, Apache License 2.0.
Copied from explorer/MidiExplorer/code. The bytes slides list every MIDI input and refresh the list when
something is plugged in; the stock Java CoreMIDI provider lists devices once at JVM start and never again.
Without this jar the deck still runs, the list is whatever was plugged in at launch.
