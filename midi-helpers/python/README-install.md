# mtm-midi-helpers for Processing Python Mode

`midicore.py` and six device modules. `javax.sound.midi` only, so nothing
else to install. Same API as the Java tabs and the p5 scripts, with Python names
(`just_pressed()`, `note_on`, `control_change`).

## Install

Processing has no library manager for Python Mode, so the modules go next to the sketch.

1. Unzip. Copy `midicore.py` and the module for your device into the sketch folder, beside the `.pyde`.
   `midicore.py` is always needed. Copy all seven if you are not sure.
2. Copy `sketch.properties` into the sketch folder too, if the folder has none. Processing 4 picks the
   mode from that file, not from the file extension. Without it the sketch opens in Java mode and the
   editor crashes.
3. Open the sketch. `from pipsqueak import PipSqueak` and go.

```python
from pipsqueak import PipSqueak

def setup():
    global stick
    size(600, 600)
    stick = PipSqueak(this)
    stick.connect()

def draw():
    background(0)
    circle(300 + stick.x * 250, 300 - stick.y * 250, 60 if stick.pressed else 30)
```

Pass `this` to the constructor. The helper reads `frameCount` off it to refresh once per frame and
`keyPressed` for the keyboard stand-ins.

## Java 17 and accessibility

Python Mode runs Jython with `respectJavaAccessibility` off, which makes Jython reach for private JDK
members. Java 17 refuses that for `javax.sound.midi`. `midicore.py` sets
`org.python.core.Options.respectJavaAccessibility = True` before it imports anything from
`javax.sound.midi`, and the modules only use public API. Import a helper module before anything else
that touches `javax.sound.midi` yourself.

Python Mode is Python 2.7. No f-strings. Start your sketch with
`from __future__ import division, print_function` if you want Python 3 division and print.

## Which module

| Device | Module | Class |
|---|---|---|
| useMIDI PipSqueak | `pipsqueak.py` | `PipSqueak` |
| Midi Fighter Classic | `midifighter.py` | `MidiFighter` |
| Launchpad Mini MK3 | `launchpad.py` | `Launchpad` |
| Circuit Playground, multi-tool firmware | `circuitplayground.py` | `CircuitPlayground` |
| Slide Trinkey, Rotary Trinkey | `trinkeys.py` | `SlideTrinkey`, `RotaryTrinkey` |
| anything else | `anymidi.py` | `AnyMidi` |

The full reference is the midi-helpers README on the site: https://morethanmusic.dev/helpers/
