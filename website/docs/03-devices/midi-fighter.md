---
title: "Midi Fighter"
description: "Sixteen arcade buttons, one on/off LED each. Every button is a note; every LED is a note sent back."
sidebar_position: 3
---

{/* generated from devices/midi-fighter/device.md by `node website/refresh.mjs devices`; edit the source, not this */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# Midi Fighter Classic

Sixteen arcade buttons in a 4×4 grid with an on/off LED under each. Every button is a note and every
LED is a note sent back. That's the whole device, which makes it the easiest one on the table to
understand completely. It's the 2010 Classic, not the 3D, so no colours and no accelerometer. There
are four on the table.

| | |
|---|---|
| Maker | DJ TechTools |
| USB name | "Midi Fighter Classic" |
| Ports | 1 in, 1 out |
| Sends | Notes 36 to 51 on channel 3, one per button. |
| Receives | The same notes back on channel 3. Velocity above 0 lights the LED, 0 clears it. |
| Buy | Not sold any more. Second-hand only. |

## What it sends

| Event | Message | Notes |
|---|---|---|
| Press | Note on, channel 3 | Status `0x92`. Velocity is fixed per unit, 127 or 125 on ours. |
| Release | Note off, channel 3 | Status `0x82`. |
| USB name | | "Midi Fighter Classic" |

In the factory Default mode the notes are 36 to 51. Bottom-left is the lowest note and top-left is 48:

```
48 49 50 51
44 45 46 47
40 41 42 43
36 37 38 39
```

The helper numbers cells 0 to 15 in reading order, top-left first, and reports a bank if the unit is in
Four Banks mode, where the top row switches banks and sends notes 0 to 3. All units should be in
Default. If the top row does something odd, the unit is in Four Banks mode and the helper reports the
bank.

## Lighting the LEDs

Send the button's own note back on channel 3. Velocity above 0 lights it, 0 or a note off clears it. No
brightness, no colour. A held button stays lit. The device never reports LED state, so the helper
keeps its own picture of which are on.

## Start here

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

<LiveSketch src="/starters/p5/midi-fighter/" title="Midi Fighter starter, p5.js" />

Code: `starters/p5/midi-fighter/sketch.js`. Paste it into the
[p5.js web editor](/pick-your-tool/p5/#use-the-p5js-web-editor) with the helper script tag, or
download the folder and double-click `index.html`.

{/* include: starters/p5/midi-fighter/sketch.js */}

```javascript title="sketch.js"
// Midi Fighter starter: a 4x4 grid. Press a button to toggle its cell on screen and its LED.
// Click once to connect MIDI. No Midi Fighter: keys 1234 / qwer / asdf / zxcv.
let mf;
const lit = new Array(16).fill(false);

function setup() {
  createCanvas(600, 600);
  mf = new MidiFighter();          // change this: new MidiFighter({ name: "...", channel: 3 }) if it isn't found
  mf.connectOnClick();             // connects on the first click and shows a hint until then
}

function draw() {
  background(20);
  for (let i = 0; i < 16; i++) {                     // index 0 is top-left, reading order
    const x = (i % 4) * 150, y = floor(i / 4) * 150;
    fill(lit[i] ? color(255, 200, 60) : (mf.pressed(i) ? 110 : 50));   // change this: colours
    rect(x + 10, y + 10, 130, 130, 24);              // change this: what a cell looks like
  }
}

function padPressed(i) {           // the helper calls this on every press (or poll mf.justPressed(i) in draw)
  lit[i] = !lit[i];                // change this: what a press does
  mf.led(i, lit[i]);               // light the real button to match; the device remembers it
}
```

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

Open `starters/python/midifighter_starter/midifighter_starter.pyde`.

{/* include: starters/python/midifighter_starter/midifighter_starter.pyde */}

```python title="midifighter_starter.pyde"
# Midi Fighter starter: a 4x4 grid. Press a button to toggle its cell on screen and its LED.
# No Midi Fighter: keys 1234 / qwer / asdf / zxcv. Edit the lines marked "change this".
from __future__ import division, print_function
from midifighter import MidiFighter

mf = None
lit = [False] * 16

def setup():
    global mf
    size(600, 600)
    mf = MidiFighter(this)   # change this: MidiFighter(this, "name", channel) if it isn't found
    mf.connect()             # prints the MIDI devices it found; fine with no device

def draw():
    background(20)
    for i in range(16):      # index 0 is top-left, reading order
        x, y = mf.col(i) * 150, mf.row(i) * 150
        fill(color(255, 200, 60) if lit[i] else (110 if mf.pressed(i) else 50))   # change this: colours
        rect(x + 10, y + 10, 130, 130, 24)    # change this: what a cell looks like

def pad_pressed(i):          # the helper calls this on every press (or poll mf.just_pressed(i) in draw)
    lit[i] = not lit[i]      # change this: what a press does
    mf.led(i, lit[i])        # light the real button to match; the device remembers it

def stop(): mf.close()       # LEDs off and port closed when the sketch closes
```

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

Open `starters/java/MidiFighterStarter/MidiFighterStarter.pde`.

{/* include: starters/java/MidiFighterStarter/MidiFighterStarter.pde */}

```java title="MidiFighterStarter.pde"
// Midi Fighter starter: a 4x4 grid. Press a button to toggle its cell on screen and its LED.
// No Midi Fighter: keys 1234 / qwer / asdf / zxcv. Edit the lines marked "change this".
MidiFighter mf;
boolean[] lit = new boolean[16];

void setup() {
  size(600, 600);
  mf = new MidiFighter(this);   // change this: new MidiFighter(this, "name", channel) if it isn't found
  mf.connect();                 // prints the MIDI devices it found; fine with no device
}

void draw() {
  background(20);
  for (int i = 0; i < 16; i++) {                     // index 0 is top-left, reading order
    float x = mf.col(i) * 150, y = mf.row(i) * 150;
    fill(lit[i] ? color(255, 200, 60) : (mf.pressed(i) ? 110 : 50));   // change this: colours
    rect(x + 10, y + 10, 130, 130, 24);              // change this: what a cell looks like
  }
}

void padPressed(int i) {        // the helper calls this on every press (or poll mf.justPressed(i) in draw)
  lit[i] = !lit[i];             // change this: what a press does
  mf.led(i, lit[i]);            // light the real button to match; the device remembers it
}
```

{/* /include */}

</TabItem>
</Tabs>

## The helper

| | |
|---|---|
| `new MidiFighter(this)` | Connects to the first device whose name contains "Midi Fighter". |
| `mf.pressed(i)`, `mf.justPressed(i)` | Cell i, 0 to 15 in reading order. "Just" is true for one frame. |
| `mf.bank` | 0 to 3 when the unit is in bank mode, otherwise 0. |
| `mf.led(i, on)`, `mf.led(i, on, bank)`, `mf.clear()` | Lights are on or off. The bank form writes into a bank you are not looking at. The device shows it when you switch. |
| `void padPressed(int index)`, `void padReleased(int index)` | Define either in your sketch and the helper calls it. |

### From the helpers' README

{/* include: midi-helpers/README.md#Midi Fighter */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

Sixteen arcade buttons in a 4x4, one on/off LED each. Notes in `grid-controllers/MIDI-FIGHTER-CLASSIC.md`.

```java
MidiFighter mf = new MidiFighter(this);                      // or (this, "name"), (this, "name", channel)
mf.pressed(i); mf.justPressed(i); mf.justReleased(i);        // i = 0..15, 0 = top-left, reading order
mf.velocity[i]; mf.anyPressed(); mf.row(i); mf.col(i); mf.index(row, col);
mf.bank;                                                     // 0..3 in Four Banks Internal mode, else 0
mf.mode;                                                     // "default" or "internal", detected; set it to force
mf.led(i, true); mf.led(i, true, bank); mf.leds(new int[] {0, 5, 10, 15}); mf.clear();
mf.setMap(loadJSONObject("map.json"));                        // a layout learned in grid-explorer.html
```
Callbacks: `padPressed(int index)`, `padReleased(int index)`, `bankChanged(int bank)`.
Stand-in: keys `1234` / `qwer` / `asdf` / `zxcv`.

Message map: Note On / Note Off on channel 3 (default; `new MidiFighter(this, "midi fighter", ch)` for a
unit set differently). Default mode notes, reading order:

```
48 49 50 51
44 45 46 47
40 41 42 43
36 37 38 39
```
Four Banks Internal: the top row sends notes 0..3 (bank select, 0-based here, 1-based in the DJ TechTools
docs) and the other twelve send `36 + 12·bank + offset`. The helper starts in default mode and switches to
internal the first time it sees a note 0..3. LEDs: Note On velocity 127 on the same channel lights a
button, Note Off clears it. Bank-select LEDs belong to the device. Unchanged LED states are not re-sent.

Python: `MidiFighter(this, name="midi fighter", channel=3)`, `mf.pressed(i)`, `mf.just_pressed(i)`,
`mf.bank`, `mf.led(i, True, bank)`, `mf.leds([0, 5])`, `mf.clear()`, `mf.set_map(dict)`; module-level
`note_for_index(index, mode, bank)` and `index_for_note(note, mode)`.

{/* /include */}

## Try first

- Toggle lights, which the starter does. Then a press lights its neighbours too: Lights Out.
- A sixteen-step sequencer. Each button a step, a playhead on the LEDs. There is a
  [port](/examples/demos/#ports-you-can-take-apart) to take apart.
- Simon. The LEDs play a sequence, you play it back.
- A 4×4 pixel canvas, mirrored big on screen.

More on the [ideas page](/examples/project-ideas/#midi-fighter-classic-16-arcade-buttons-one-led-each) and
the [demos page](/examples/demos/#midi-fighter-classic). The on-device menu and how to un-brick one:
[MIDI-FIGHTER-CLASSIC.md](pathname:///grid-controllers/MIDI-FIGHTER-CLASSIC.md).

## Without the helper

Notes 36 to 51 in, the same notes back out for the LEDs. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](/examples/three-bytes-no-helpers/) first.

- Java mode: [`starters/raw/java/RawMidiFighter/`](pathname:///starters/raw/java/RawMidiFighter/RawMidiFighter.pde)
- Python Mode: [`starters/raw/python/raw_midifighter/`](pathname:///starters/raw/python/raw_midifighter/raw_midifighter.pyde)
- p5.js: [`starters/raw/p5/midi-fighter/`](pathname:///starters/raw/p5/midi-fighter/), or its [sketch.js](pathname:///starters/raw/p5/midi-fighter/sketch.js)
