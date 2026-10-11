---
title: Helpers
slug: /helpers/
description: The MIDI helpers for p5.js, Processing Java and Python Mode. One API, three languages, installable or as drop-in tabs.
---

# Helpers

One small library, three times: a script for p5.js, tabs or a library for Processing Java, modules for
Python Mode. Each device gets a class that turns its messages into a few fields and callbacks, so a
sketch reads `stick.x` instead of decoding bytes. The version number moves together across the three.

{/* include: midi-helpers/README.md#Install */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

Three ways in, same API. Version numbers move together; see `CHANGELOG.md`.

| | Install | Then |
|---|---|---|
| p5.js, one tag | `<script src="https://morethanmusic.dev/mtm-midi-helpers/latest/midi-helpers.js"></script>` | `new PipSqueak()` |
| p5.js, module | `npx jsr add @georgemandis/mtm-midi-helpers` or `npm install mtm-midi-helpers` | `import { PipSqueak } from "@georgemandis/mtm-midi-helpers"` (npm: `"mtm-midi-helpers"`) |
| Processing Java, library | Sketch > Import Library > Manage Libraries, search `midihelpers` (or unzip `midihelpers.zip` into the sketchbook's `libraries/`) | `import midihelpers.*;` |
| Processing Java, tabs | copy `MidiCore.pde` and the device tab into the sketch folder | nothing |
| Python Mode | download `mtm-midi-helpers-python-1.0.0.zip`, copy `midicore.py` and the module next to the `.pyde` | `from pipsqueak import PipSqueak` |

Downloads: `https://morethanmusic.dev/mtm-midi-helpers/latest/` (the versioned folder `1.0.0/` keeps
working after the next release). The library build lives in `processing-library/`, the zip script in
`python/zip.sh`, `release.sh` runs everything and lays the copies into the site.

{/* /include */}

Hosted copies: [`/mtm-midi-helpers/latest/`](pathname:///mtm-midi-helpers/latest/SHA256SUMS) lists
every file and its checksum. The versioned folder, `1.0.0/`, keeps working after the next release.

## In a sketch

{/* include: midi-helpers/README.md#In the IDE */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

Java mode: copy `MidiCore.pde` and the device tab into the sketch folder, or drag them onto the IDE window.
They show up as tabs.

```java
PipSqueak stick = new PipSqueak(this);

void setup() {
  size(600, 600);
  stick.connect();                      // prints the MIDI devices it found; fine with no device
}

void draw() {
  background(0);
  circle(300 + stick.x * 250, 300 - stick.y * 250, stick.pressed ? 60 : 30);
}
```

Python Mode: copy `midicore.py` and the device module next to the `.pyde`. Pass `this` so the helper can
update itself once per frame.

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

Python Mode and Java 17. Python Mode runs Jython with `respectJavaAccessibility` off, which makes
Jython reach for private JDK members. Java 17 refuses that for `javax.sound.midi`, so `midicore.py`
sets `org.python.core.Options.respectJavaAccessibility = True` before it imports anything from
`javax.sound.midi`. Verified in George's IDE. The modules only use public API, so nothing else changes.
A Python sketch folder also needs a `sketch.properties` so the IDE opens it in the right mode:

```
mode=Python
mode.id=jycessing.mode.PythonMode
```

Every Python sketch in the repo has one. `sync.sh` writes it into any Python Mode sketch folder it syncs
into that lacks it.

Processing cannot import a sibling folder, so sketches hold copies and this folder is the source. A sketch
opts in with a `.midi-helpers` file listing the helpers it wants, one per line (`MidiCore` is implied).
`midi-helpers/sync.sh` copies the current versions in. `sync.sh --check` only reports.

{/* /include */}

## Reference

- Rules every helper follows (channels, `connect()`, callbacks, keyboard stand-ins) are on the
  [Hello world](/examples/hello-world/#how-every-helper-behaves) page.
- Each [device page](/devices/) has the fields and callbacks of its own helper.
- The full README, the changelog and the tests are in the repo:
  [midi-helpers/README.md](pathname:///midi-helpers/README.md),
  [CHANGELOG.md](pathname:///midi-helpers/CHANGELOG.md).
