---
title: "PipSqueak"
description: "A joystick and a button from useMIDI. Two CCs for the axes, one for the button."
sidebar_position: 1
---

{/* generated from devices/pipsqueak/device.md by `node website/refresh.mjs devices`; edit the source, not this */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# PipSqueak

A joystick and a button from [useMidi](https://usemidi.com). Thanks to Masson there for providing them.
Two axes, each a control change 0 to 127, and a button that is also a control change. Some on the table
were set up with the [configurator](https://usemidi.com/configure.html), so the helper takes a config
instead of assuming the numbers below.

| | |
|---|---|
| Maker | useMidi |
| USB name | contains "PipSqueak", on some units "PipSqueaker" |
| Ports | 1 in, 1 out |
| Sends | CC 17 left and right, CC 20 up and down, CC 25 button. The numbers are a config, not a constant. |
| Receives | Rules saved in the configurator. Stock firmware flashes the LED red on note 60. |
| Buy | [usemidi.com/product/pipsqueak-black](https://usemidi.com/product/pipsqueak-black) |
| Firmware | Stock. Set up at [usemidi.com/configure.html](https://usemidi.com/configure.html) |

## What it sends

| Control | Message | Default | Notes |
|---|---|---|---|
| Left and right | CC | CC 17 | 0 left, 126 right. Rest is around 60, not 64: the centre is off-centre on purpose and the helper calibrates for it. |
| Up and down | CC | CC 20 | 0 down, 126 up. Rest around 68. |
| Button | CC | CC 25 | Above 64 while held, 0 when released. |
| USB name | | contains "PipSqueak" | Some units enumerate as "PipSqueaker". The Explorer prints the exact name. |

Defaults measured from a real unit on September 12, 2026. A custom unit may use other numbers. Check
[the Explorer](/the-explorer/) and pass a config.

## Start here

It's under 40 lines. Open it, press Run, and push the stick. The `change this` comments mark the lines
to make your own, and [Hello world](/examples/hello-world/) walks through this exact sketch line by line.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

<LiveSketch src="/starters/p5/pipsqueak/" title="PipSqueak starter, p5.js" />

Code: `starters/p5/pipsqueak/sketch.js`. Paste it into the
[p5.js web editor](/pick-your-tool/p5/#use-the-p5js-web-editor) with the helper script tag, or
download the folder and double-click `index.html`.

{/* include: starters/p5/pipsqueak/sketch.js */}

```javascript title="sketch.js"
// PipSqueak starter: the joystick pushes a dot around, the button changes its colour.
// Click the page once to connect MIDI (browsers want a click first). No stick: arrows move, space is the button.
let stick, px, py, hue = 200;

function setup() {
  createCanvas(800, 600);
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 8);
  px = width / 2;
  py = height / 2;
  stick = new PipSqueak();        // change this: new PipSqueak({ name: "...", smoothing: 0.5 }) for a custom unit
  stick.connectOnClick();         // connects on the first click and shows a hint until then
}

function draw() {
  px = constrain(px + stick.x * 6, 0, width);    // stick.x is -1..1. change this: 6 is the speed in pixels per frame
  py = constrain(py - stick.y * 6, 0, height);   // stick.y is +1 when pushed up; screen y grows downward
  if (stick.justPressed()) hue = (hue + 47) % 360;   // change this: what a tap of the button does
  fill(0, 0, 8, 12);                             // change this: a lower alpha leaves a longer trail
  rect(0, 0, width, height);
  fill(hue, 80, 100);
  circle(px, py, 40 + stick.magnitude * 30 + (stick.pressed ? 40 : 0));   // change this: what gets drawn
}
```

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

Open `starters/python/pipsqueak_starter/pipsqueak_starter.pyde`.

{/* include: starters/python/pipsqueak_starter/pipsqueak_starter.pyde */}

```python title="pipsqueak_starter.pyde"
# PipSqueak starter: the joystick pushes a dot around, the button changes its colour.
# No stick: arrows move, space is the button. Edit the lines marked "change this".
from __future__ import division, print_function
from pipsqueak import PipSqueak

stick, px, py, hue = None, 0, 0, 200

def setup():
    global stick, px, py
    size(800, 600)
    colorMode(HSB, 360, 100, 100, 100)
    background(0, 0, 8)
    px, py = width / 2, height / 2
    stick = PipSqueak(this)    # change this: PipSqueak(this, "name") if yours has another name
    stick.connect()            # prints the MIDI devices it found; fine with no device

def draw():
    global px, py, hue
    px = constrain(px + stick.x * 6, 0, width)    # stick.x is -1..1. change this: 6 is the speed
    py = constrain(py - stick.y * 6, 0, height)   # stick.y is +1 when pushed up; screen y grows downward
    if stick.just_pressed():
        hue = (hue + 47) % 360                    # change this: what a tap of the button does
    fill(0, 0, 8, 12)                             # change this: a lower alpha leaves a longer trail
    rect(0, 0, width, height)
    fill(hue, 80, 100)
    size_ = 40 + stick.magnitude * 30 + (40 if stick.pressed else 0)
    circle(px, py, size_)                         # change this: what gets drawn

def stop(): stick.close()    # closes the MIDI port when the sketch closes
```

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

Open `starters/java/PipSqueakStarter/PipSqueakStarter.pde`.

{/* include: starters/java/PipSqueakStarter/PipSqueakStarter.pde */}

```java title="PipSqueakStarter.pde"
// PipSqueak starter: the joystick pushes a dot around, the button changes its colour.
// No stick: arrows move, space is the button. Edit the lines marked "change this".
PipSqueak stick;
float px, py, hue = 200;

void setup() {
  size(800, 600);
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 8);
  px = width / 2;
  py = height / 2;
  stick = new PipSqueak(this);   // change this: new PipSqueak(this, "name") if yours has another name
  stick.connect();               // prints the MIDI devices it found; fine with no device
}

void draw() {
  px = constrain(px + stick.x * 6, 0, width);    // stick.x is -1..1. change this: 6 is the speed
  py = constrain(py - stick.y * 6, 0, height);   // stick.y is +1 when pushed up; screen y grows downward
  if (stick.justPressed()) hue = (hue + 47) % 360;   // change this: what a tap of the button does
  fill(0, 0, 8, 12);                             // change this: a lower alpha leaves a longer trail
  rect(0, 0, width, height);
  fill(hue, 80, 100);
  float size = 40 + stick.magnitude * 30 + (stick.pressed ? 40 : 0);
  circle(px, py, size);                          // change this: what gets drawn
}
```

{/* /include */}

</TabItem>
</Tabs>

## The helper

| | |
|---|---|
| `new PipSqueak(this)`, `new PipSqueak(this, "name", config)` | Connects by USB-name substring. The config carries CC numbers, centre and range per axis, the button CC and threshold, deadzone and smoothing. |
| `stick.x`, `stick.y` | -1 to 1. `y` is +1 when pushed up, so subtract it from a screen y. |
| `stick.angle`, `stick.magnitude` | Radians and 0 to 1. The angle is NaN inside the deadzone, so test `magnitude` first. |
| `stick.pressed`, `stick.justPressed()`, `stick.justReleased()` | The button. The "just" ones are true for one frame. |
| `void stickPressed()`, `void stickReleased()` | Define either in your sketch and the helper calls it. |

### From the helpers' README

{/* include: midi-helpers/README.md#PipSqueak */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

A joystick and one button. It sends Control Change. Units are configured at usemidi.com/configure.html,
so the map is a config, not a constant.

```java
PipSqueak stick = new PipSqueak(this);                       // or (this, "name"), (this, "name", config)
stick.connect();  stick.connected();
stick.x; stick.y;                 // -1..1, y is +1 pushed up
stick.angle; stick.magnitude;     // radians (0 = right, counter-clockwise positive) / 0..1. angle is NaN in the deadzone
stick.pressed; stick.justPressed(); stick.justReleased();
stick.rawX; stick.rawY;           // last CC values, 0..127
stick.recenter();                 // hands off for 0.5 s; the resting position becomes the centre. recenter(seconds) too
stick.flash();                    // Note On 60 velocity 127 then Note Off, to the stick's own port: the LED flashes red for 200 ms
stick.send(status, d1, d2);       // any message to the stick, for rules you saved in the useMidi configurator
```
Callbacks: `stickPressed()`, `stickReleased()`. Stand-in: arrow keys and SPACE.

The LED is rule-based. The stick takes no colour commands. It stores rules set in the useMidi
configurator ("when this message arrives, do this to the LED") and the helper only sends. George's units
run firmware 2.7.0-beta.3 with one rule: Note On 60 on any channel flashes the LED red for 200 ms.
`flash()` sends that pair. `send()` is for other rules. The output port opens on the first send;
`connect()` only opens the input. No output port (older firmware, no stick): both calls do nothing after
one console line. Python: `stick.flash()`, `stick.send(status, d1, d2)`. p5: the same, with the port
opened asynchronously and the first messages queued in order.

Config is a `PipSqueakConfig` (public fields `xCC, xCenter, xMin, xMax, xInvert, yCC..., buttonCC,
buttonThreshold, buttonNote, deadzone, smoothing, name`) or a `JSONObject` in the shape the JS and Python
helpers use. One `pipsqueak.json` serves all three:

```json
{ "name": "pipsqueak",
  "x": {"cc": 17, "center": 60, "min": 0, "max": 126, "invert": false},
  "y": {"cc": 20, "center": 68, "min": 0, "max": 126, "invert": false},
  "button": {"cc": 25, "threshold": 64},
  "deadzone": 0.1, "smoothing": 1.0 }
```
`new PipSqueak(this, "pipsqueak", loadJSONObject("pipsqueak.json"))`. A button that sends a note is
`"button": {"note": 60}`. `smoothing` is a moving average factor: 1 is none, 0.3 is heavy. The rest
position is off-centre on purpose; that is what the unit does.

Message maps. Two have been seen on real units. With no config the Java helper knows both: it starts on
`stock` and switches once to another known map the moment a message arrives that only that map claims. It
also snaps each axis centre to the first value it sees when that value is within 12 of the map's rest,
because the first message is sent as the stick leaves rest. `stick.config.profile` says which map is live.
The console prints the switch.

| Profile | x | y | button | measured |
| --- | --- | --- | --- | --- |
| `stock` (default) | CC 17, rest 60 | CC 20, rest 68 | CC 25, value ≥ 64 | 2026-09-12 |
| `usemidi` | CC 10, rest 67 | CC 7, rest 70 | note 60 on / off (velocity 127 both ways) | 2026-10-02, a unit named `PipSqueaker` |

Any channel. A JSON or `PipSqueakConfig` you pass means what it says (`auto` off unless the JSON says
`"auto": true`). A third map: read it off the Explorer, then add a profile to `PipSqueakConfig.profiles()`
or ship a JSON. The Python and JS helpers only carry the `stock` defaults; give them a config for a
`usemidi` unit. Normalisation is piecewise-linear around the centre, then a radial deadzone, then a rescale
so magnitude runs 0..1 from the deadzone edge to full deflection. Same maths as `pipsqueak.js`.

Python: `PipSqueak(this, name=None, config=None)` with a dict config; `stick.x`, `stick.angle` (None in
the deadzone), `stick.just_pressed()`, `stick.events()` ("press"/"release" since last call), `recenter()`.
The old `PipSqueak(config)` form from `pipsqueak/pipsqueak_py` still works; then you call `update()`.

{/* /include */}

## Try first

- A dot with a trail. Then colour the trail by angle.
- A character whose speed is the magnitude. Then walls.
- Hold the button to draw, release to lift the pen.
- Steer a parameter, not a position. The [Gray-Scott demo](pathname:///pipsqueak-grayscott/) does this.

More on the [ideas page](/examples/project-ideas/#pipsqueak-joystick--button) and the
[demos page](/examples/demos/#pipsqueak).

## Without the helper

Three CCs decoded inline: 17 is x, 20 is y, 25 is the button. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](/examples/three-bytes-no-helpers/) first.

- Java mode: [`starters/raw/java/RawPipSqueak/`](pathname:///starters/raw/java/RawPipSqueak/RawPipSqueak.pde)
- Python Mode: [`starters/raw/python/raw_pipsqueak/`](pathname:///starters/raw/python/raw_pipsqueak/raw_pipsqueak.pyde)
- p5.js: [`starters/raw/p5/pipsqueak/`](pathname:///starters/raw/p5/pipsqueak/), or its [sketch.js](pathname:///starters/raw/p5/pipsqueak/sketch.js)
