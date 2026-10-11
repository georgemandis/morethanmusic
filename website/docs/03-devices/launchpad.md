---
title: "Launchpad"
description: "An 8×8 grid of RGB pads. The pads are notes; the colours go back as SysEx."
sidebar_position: 4
---

{/* generated from devices/launchpad/device.md by `node website/refresh.mjs devices`; edit the source, not this */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# Launchpad Mini MK3

An 8×8 grid of RGB pads, eight buttons across the top, eight down the right side, and a logo button.
The pads are notes and the colours go back as SysEx. Think of it as a 64-pixel display that can feel
you touching it. There are two on the table, so share.

| | |
|---|---|
| Maker | Novation |
| USB name | "LPMiniMK3 MIDI". There is also "LPMiniMK3 DAW". Use MIDI. |
| Ports | Two pairs, MIDI and DAW. The helper picks the MIDI one. |
| Sends | Notes for the pads, CC 19 to 99 for the buttons, in Programmer mode. |
| Receives | A note with a palette index as velocity lights a pad. SysEx for exact RGB, all pads at once and scrolling text. |
| Buy | [novationmusic.com/products/launchpad-mini-mk3](https://novationmusic.com/products/launchpad-mini-mk3) |

## What it sends

In Programmer mode, which the helper switches on when it connects and off when your sketch closes:

| Control | Message | Numbers |
|---|---|---|
| Pad press and release | Note on, note off | Note is row × 10 + column counted from the bottom-left as 11, so top-right is 88. The helper turns that into x 0..7 left to right, y 0..7 top to bottom. |
| Top row buttons | CC | 91 to 98, left to right. The first four are printed as arrows. |
| Right column buttons | CC | 89 down to 19, in steps of 10 |
| Logo | CC | 99 |
| USB name | | "LPMiniMK3 MIDI". There is also a DAW port. The helper picks the MIDI one. |

## Lighting the pads

A note on sent to a pad with a palette index 0 to 127 as velocity sets a colour. 0 is off. Exact RGB,
all 64 pads at once, and scrolling text are SysEx commands. The helper gives you `set`, `setRGB` and
`text`. The bytes are taken apart in the [Launchpad Marquee notes](pathname:///launchpad-marquee/README.md).

Handy palette indexes: 3 white, 5 red, 9 orange, 13 yellow, 21 green, 37 cyan, 45 blue, 53 magenta.
`pad.set(x, y, c)` also accepts an ordinary Processing colour.

## Start here

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

<LiveSketch src="/starters/p5/launchpad/" title="Launchpad starter, p5.js" />

The browser asks for MIDI, then SysEx. Say yes to both. Code: `starters/p5/launchpad/sketch.js`. Paste it into the
[p5.js web editor](/pick-your-tool/p5/#use-the-p5js-web-editor) with the helper script tag, or
download the folder and double-click `index.html`.

{/* include: starters/p5/launchpad/sketch.js */}

```javascript title="sketch.js"
// Launchpad starter: paint on the 8x8 grid. Press a pad to colour it; the top-left button clears.
// Click once to connect MIDI (the Launchpad needs SysEx; Chrome asks). No Launchpad: click the cells, 'c' clears.
let pad;
let cells = new Array(64).fill(null);
const CELL = 70;                   // pixels per cell on screen

function setup() {
  createCanvas(560, 560);
  pad = new Launchpad();           // change this: new Launchpad({ name: "..." }) if it isn't found
  pad.connectOnClick();            // connects on the first click and shows a hint until then
}

function draw() {
  background(20);
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) {
    fill(cells[x + y * 8] || color(45));
    rect(x * CELL + 4, y * CELL + 4, CELL - 8, CELL - 8, 10);   // change this: how a cell is drawn
  }
  if (pad.connected()) pad.button("top0", pad.RED);             // keep the "clear" button lit
}

function paint(x, y) {
  const c = color(x * 36, y * 36, 255 - x * 20);   // change this: pick the colour another way
  cells[x + y * 8] = c;
  pad.set(x, y, c);                                // light the real pad with the same colour
}

function clearAll() { cells = new Array(64).fill(null); pad.clear(); }

function padPressed(x, y) { paint(x, y); }                               // the helper calls these two
function buttonPressed(id) { if (id === "top0") clearAll(); }
function mousePressed() { const x = floor(mouseX / CELL), y = floor(mouseY / CELL); if (x < 8 && y >= 0 && y < 8) paint(x, y); }   // stand-in
function keyPressed() { if (key === "c") clearAll(); }
```

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

Open `starters/python/launchpad_starter/launchpad_starter.pyde`.

{/* include: starters/python/launchpad_starter/launchpad_starter.pyde */}

```python title="launchpad_starter.pyde"
# Launchpad starter: paint on the 8x8 grid. Press a pad to colour it; the top-left button clears.
# No Launchpad: click the cells, 'c' clears. Edit the lines marked "change this".
from __future__ import division, print_function
from launchpad import Launchpad

pad, cells = None, [None] * 64
CELL = 70                        # pixels per cell on screen

def setup():
    global pad
    size(560, 560)
    pad = Launchpad(this)        # change this: Launchpad(this, "name") if it isn't found
    pad.connect()                # prints the MIDI devices it found; puts the pad in programmer mode
    pad.button("top0", pad.RED)  # light the "clear" button

def draw():
    pad.update()                 # once per frame, so the callbacks below fire
    background(20)
    for y in range(8):
        for x in range(8):
            fill(cells[x + y * 8] or color(45))
            rect(x * CELL + 4, y * CELL + 4, CELL - 8, CELL - 8, 10)   # change this: how a cell is drawn

def paint(x, y):
    c = color(x * 36, y * 36, 255 - x * 20)   # change this: pick the colour another way
    cells[x + y * 8] = c
    pad.set(x, y, c)             # light the real pad with the same colour

def clear_all():
    for i in range(64): cells[i] = None
    pad.clear()
    pad.button("top0", pad.RED)
def pad_pressed(x, y): paint(x, y)                 # the helper calls these two
def button_pressed(id):
    if id == "top0": clear_all()
def mousePressed(): paint(mouseX // CELL, mouseY // CELL)   # stand-ins without a device
def keyPressed():
    if key == 'c': clear_all()
def stop(): pad.close()                            # back to Live mode when the sketch closes
```

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

Open `starters/java/LaunchpadStarter/LaunchpadStarter.pde`.

{/* include: starters/java/LaunchpadStarter/LaunchpadStarter.pde */}

```java title="LaunchpadStarter.pde"
// Launchpad starter: paint on the 8x8 grid. Press a pad to colour it; the top-left button clears.
// No Launchpad: click the cells, 'c' clears. Edit the lines marked "change this".
Launchpad pad;
color[] cells = new color[64];
int cell = 70;                  // pixels per cell on screen

void setup() {
  size(560, 560);
  pad = new Launchpad(this);    // change this: new Launchpad(this, "name") if it isn't found
  pad.connect();                // prints the MIDI devices it found; puts the pad in programmer mode
  pad.button("top0", pad.RED);  // light the "clear" button
}

void draw() {
  background(20);
  for (int y = 0; y < 8; y++) for (int x = 0; x < 8; x++) {
    fill(cells[x + y * 8] == 0 ? color(45) : cells[x + y * 8]);
    rect(x * cell + 4, y * cell + 4, cell - 8, cell - 8, 10);   // change this: how a cell is drawn
  }
}

void paint(int x, int y) {
  color c = color(x * 36, y * 36, 255 - x * 20);   // change this: pick the colour another way
  cells[x + y * 8] = c;
  pad.set(x, y, c);                                // light the real pad with the same colour
}

void clearAll() {
  cells = new color[64];
  pad.clear();
  pad.button("top0", pad.RED);
}

void padPressed(int x, int y) { paint(x, y); }                   // the helper calls these two
void buttonPressed(String id) { if (id.equals("top0")) clearAll(); }
void mousePressed() { paint(mouseX / cell, mouseY / cell); }      // stand-ins without a device
void keyPressed() { if (key == 'c') clearAll(); }
```

{/* /include */}

</TabItem>
</Tabs>

## The helper

| | |
|---|---|
| `new Launchpad(this)` | Connects to the "LPMiniMK3 MIDI" ports, switches to Programmer mode, and puts the device back in Live mode when the sketch closes. |
| `pad.pressed(x, y)`, `pad.justPressed(x, y)` | x 0..7 left to right, y 0..7 top to bottom. |
| `pad.set(x, y, c)`, `pad.setRGB(x, y, r, g, b)` | A palette index 0..127 or a Processing colour. Or RGB with each channel 0..255. |
| `pad.button("top3", c)`, `pad.clear()`, `pad.text("hi", c)` | Side buttons by id, everything off, and the firmware's own text scroll. |
| `void padPressed(int x, int y)`, `void padReleased(int x, int y)`, `void buttonPressed(String id)` | Define any in your sketch and the helper calls it. |

### From the helpers' README

{/* include: midi-helpers/README.md#Launchpad */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

8x8 RGB pads, eight buttons across the top, eight down the right side, the logo. Programmer mode on
`connect()`, Live mode back in `dispose()` / `close()`.

```java
Launchpad pad = new Launchpad(this);                         // or (this, "name")
pad.pressed(x, y); pad.justPressed(x, y); pad.justReleased(x, y);   // x 0..7 left to right, y 0..7 top to bottom
pad.velocity[y][x]; pad.anyPressed();
pad.buttonPressed("top3"); pad.buttonJustPressed("right0"); pad.buttonJustReleased("logo");
pad.set(x, y, color(255, 0, 0));      // any Processing colour, sent as RGB
pad.set(x, y, pad.GREEN);             // or a palette index 0..127 (0 = off): pad.OFF, WHITE, RED, ORANGE, YELLOW, LIME, GREEN, MINT, CYAN, SKY, BLUE, VIOLET, MAGENTA, PINK
pad.setRGB(x, y, r, g, b);            // 0..255 each
pad.flash(x, y, a, b); pad.pulse(x, y, c);                   // palette indices
pad.button("top3", c); pad.clear();
pad.text("hi", c); pad.text("hi", c, speed, loop); pad.stopText();
```
Callbacks: `padPressed(int x, int y)`, `padReleased(int x, int y)`, `buttonPressed(String id)`,
`buttonReleased(String id)`. Button ids: `top0`..`top7`, `right0` (top) .. `right7` (bottom), `logo`.
No keyboard stand-in.

A Processing colour has its alpha bits set, so it is a negative int. A palette index is 0..127. That is how
`set()` tells them apart: `pad.set(x, y, 5)` is palette red, `pad.set(x, y, color(255, 0, 0))` is RGB red.
Unchanged values are not re-sent, so repainting all 64 pads in `draw()` is fine.

Message map (programmer mode): pad = note `(8 - y) * 10 + (x + 1)` (11 bottom-left, 88 top-right), Note
On velocity > 0 is press, 0 is release. Top row = CC 91..98, right column = CC 89 (top) .. 19 (bottom), logo
= CC 99, value > 0 is press. Output: palette colour = Note On on channel 1 (static), 2 (flash), 3 (pulse),
or CC on channel 1 for buttons. SysEx header `F0 00 20 29 02 0D`; `0E 01/00` programmer / Live mode; `03`
followed by `<type> <led> <colour...>` entries lights LEDs (type 0 palette, 1 flash a/b, 2 pulse, 3 RGB
with 7-bit values); `07 <loop> <speed> <colourspec> <ascii...>` scrolls text. Ported from
`grid-controllers/launchpad.js`.

Python: `Launchpad(this, name="LPMiniMK3 MIDI")`, `pad.pressed(x, y)`, `pad.just_pressed(x, y)`,
`pad.button_pressed("top3")`, `pad.set(x, y, c)`, `pad.set_rgb`, `pad.flash`, `pad.pulse`, `pad.button`,
`pad.clear()`, `pad.text(s, c, speed, loop)`, `pad.stop_text()`, `pad.close()`; module-level
`xy_to_note`, `note_to_xy`, `button_to_cc`, `cc_to_button`, `COLORS`.

{/* /include */}

## Try first

- Paint. Each press cycles a pad through colours. Then mirror it big on screen.
- Game of Life. Press to seed, logo to step. There is a [port](/examples/demos/#ports-you-can-take-apart)
  of the automata demo.
- Two players: one at the keyboard, one at the board. Quest is built on this.
- Snake, steered with the arrow buttons.

More on the [ideas page](/examples/project-ideas/#launchpad-mini-mk3-88-rgb-pads--16-buttons) and the
[demos page](/examples/demos/#launchpad-mini-mk3).

## Without the helper

One SysEx for programmer mode, pads as notes, palette colours out. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](/examples/three-bytes-no-helpers/) first.

- Java mode: [`starters/raw/java/RawLaunchpad/`](pathname:///starters/raw/java/RawLaunchpad/RawLaunchpad.pde)
- Python Mode: [`starters/raw/python/raw_launchpad/`](pathname:///starters/raw/python/raw_launchpad/raw_launchpad.pyde)
- p5.js: [`starters/raw/p5/launchpad/`](pathname:///starters/raw/p5/launchpad/), or its [sketch.js](pathname:///starters/raw/p5/launchpad/sketch.js)
