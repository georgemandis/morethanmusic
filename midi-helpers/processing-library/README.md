# midihelpers for Processing

The midi-helpers Java tabs as an installable library. Same classes, same API as the tabs: `PipSqueak`,
`MidiFighter`, `Launchpad`, `CircuitPlayground`, `SlideTrinkey`, `RotaryTrinkey`, `AnyMidi`, and
`MidiCore` underneath. javax.sound.midi only, so nothing else to install.

```java
import midihelpers.*;

PipSqueak stick = new PipSqueak(this);

void setup() {
  size(600, 600);
  stick.connect();
}

void draw() {
  background(0);
  circle(300 + stick.x * 250, 300 - stick.y * 250, stick.pressed ? 60 : 30);
}
```

## Install

Sketch > Import Library > Manage Libraries, search for midihelpers. Or unzip `midihelpers.zip` into
your sketchbook's `libraries/` folder (Processing > Settings shows the sketchbook location) and restart
Processing. File > Examples > Contributed Libraries > midihelpers has one sketch per device.

The drop-in path still works: copy `MidiCore.pde` and the device tab into the sketch folder instead.
Same code, no install. The tabs are in `midi-helpers/java/` and on the site.

Two differences from the tabs. The sketch-level functions live on the class:
`MidiCore.printMidiDevices()`, `MidiCore.midiInputs()`, `MidiCore.midiOutputs()`. And every field and
method the tabs left package-private is public here, because a sketch cannot see package-private
members of a library.

## Build

The library is generated from the tabs. Edit `midi-helpers/java/*.pde`, then:

```sh
midi-helpers/processing-library/build.sh    # build/midihelpers/, build/midihelpers.zip, build/midihelpers.txt
midi-helpers/processing-library/test.sh     # zip layout, examples compile, the Java suite runs against the jar,
                                            # Processing's own CLI builds an example when Processing.app is installed
```

`generate.mjs` does the rewrite (package line, imports, static sketch functions, public members).
`library.properties` carries the version shown in the Contribution Manager; `prettyVersion` must match
`midi-helpers/VERSION` and `version` goes up by one per release.
