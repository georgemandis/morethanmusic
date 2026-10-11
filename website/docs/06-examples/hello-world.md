---
title: "Hello world"
description: The first starter sketch, walked through line by line, in Java, Python Mode and p5.js.
sidebar_position: 1
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# Hello world

Every device has a starter sketch under 40 lines that reads the device and draws something right
away. This is the PipSqueak one, because a joystick is about as simple as it gets: two axes and a
button. The other starters have the same shape, so once this one makes sense, so do they. It comes in
p5.js, Python Mode and Java; the tabs below switch between them.

## Open it

In p5.js: plug the PipSqueak in, open [the starter](pathname:///starters/p5/pipsqueak/) in a browser
with Web MIDI, and click the canvas once. Or paste it into the
[web editor](/pick-your-tool/p5/#use-the-p5js-web-editor).

In Processing: plug the PipSqueak in first. Java's MIDI on macOS doesn't see devices plugged in after a
sketch starts, so if you plug in late, stop and run again. Open
`starters/python/pipsqueak_starter/pipsqueak_starter.pyde` in Python Mode, or
`starters/java/PipSqueakStarter/PipSqueakStarter.pde` in Java mode, and press Run.

Push the stick. A dot moves. Tap the button and it changes colour. No stick? The helper fakes one. The
arrow keys move it and space is the button.

## The whole sketch

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

The same sketch in the browser:

<LiveSketch src="/starters/p5/pipsqueak/" title="PipSqueak starter, p5.js" />

To edit it, paste the code into the [p5.js web editor](/pick-your-tool/p5/#use-the-p5js-web-editor)
with the helper script tag, or download the folder and double-click `index.html`.

{/* include: starters/p5/%pipsqueak%/sketch.js */}

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

The folder also holds a `sketch.properties` file, which is what makes Processing 4 open it in Python
Mode. Keep it when you copy the sketch. See [Before you start](/pick-your-tool/processing-python/).

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

## Line by line

The helper is the MIDI side of the sketch. In p5.js it is the one `midi-helpers.js` script tag in
`index.html`. In Processing it is the `MidiCore` and `PipSqueak` tabs next to the starter. Either way
it talks to MIDI, decodes the three bytes, and turns them into a few fields you can read. You never
edit it. Every Processing starter carries its own copy because Processing can't import a sibling
folder. The [Helpers](/helpers/) page has the install options.

`let stick;` declares the helper. In Python Mode the import line does the same; in Java it is
`PipSqueak stick;`.

`stick = new PipSqueak();` creates it. In Processing it is `PipSqueak(this)`: `this` is your sketch,
so the helper can update itself before every `draw()`. If the Explorer shows your stick under another
name, pass that name as an argument.

`stick.connectOnClick();` waits for your first click, because a browser won't hand out MIDI until
you click something, then opens the device. In Processing it is `stick.connect();`, which opens it at
once. Both print the MIDI ports they can see, open the first one whose name contains "PipSqueak", and
carry on. With no device the keyboard stand-in takes over. Nothing here ever throws.

`stick.x` and `stick.y` are the joystick, -1 to 1, calibrated for the stick's off-centre rest and a
small deadzone. `y` is +1 when you push up, so the starter subtracts it from screen y. The `6` is the
speed.

`stick.justPressed()` is true for one frame after the button goes down. `stick.pressed` is true while
it is held.

`stick.magnitude` is how far the stick is pushed, 0 to 1. `stick.angle` is radians and NaN inside the
deadzone, so check `magnitude` first.

The translucent rectangle drawn over the frame each time is what leaves the trail. Lower the alpha for
a longer one.

Python Mode uses snake_case: `stick.just_pressed()`. Its `stop()` calls `stick.close()`. In Java and
p5.js the helper does that itself.

## Callbacks

Instead of polling in `draw()`, define a function with the right name and the helper calls it:
`void stickPressed()`, `void stickReleased()`, or for any device `void noteOn(int channel, int note,
int velocity)` and `void controlChange(int channel, int number, int value)`. Nothing to register.

## How every helper behaves

{/* include: midi-helpers/README.md#Shared rules */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

Channels are 1..16 in every call and callback. Status `0x92` is channel 3.

`connect()` prints the inputs and outputs Java sees, opens the first input and first output whose name or
description contains the substring (any case), and returns a boolean. An empty name opens every input
(that is what `AnyMidi` with no name does) and the first output. No match: one line on the console
and the sketch keeps going. `connected()` means an input is open. The constructor never touches hardware,
so `new PipSqueak(this)` is fine as a field initializer.

Messages arrive on Java's MIDI thread and queue. Java helpers register `pre()` and drain the queue right
before `draw()`, so `pressed` and `justPressed()` hold for a whole frame, and `justPressed()` is true for
one frame per press. Python Mode has no per-frame hook for a module, so a Python helper drains the queue
the first time you touch it in a frame (it watches `this.frameCount`). Callbacks only? Call
`helper.update()` at the top of `draw()`.

Callbacks work the Processing way. Define a sketch function with the right name and arguments and the
helper calls it. Java finds it by reflection, so it must be a top-level sketch function. Python looks in
the sketch module; pass `callbacks=globals()` if that ever fails. Every helper offers `noteOn(channel,
note, velocity)`, `noteOff(channel, note, velocity)` and `controlChange(channel, number, value)` (Python:
`note_on`, `note_off`, `control_change`). Each of those also takes the device name as a trailing
argument if you declare it: `noteOn(int channel, int note, int velocity, String device)`. The old arity
keeps working. Device callbacks are listed per device. Callbacks run on the animation thread, before
`draw()`.

No device? Each helper that has a keyboard stand-in keeps the sketch usable from the keyboard. Details
per device. Python stand-ins read one key at a time.

`dispose()` (Java) restores the device: LEDs off, Launchpad back to Live mode, ports closed. Python helpers
have `close()`; call it from `stop()` if you care.

Java helpers are `public class`. Keep it that way: `registerMethod()` throws `IllegalAccessException` on a
package-private inner class. The tabs also compile with plain javac (float literals carry an `f`, no
`color` type, no `#hex` literals). That is how the tests build them.

`MidiCore` works on its own for anything unusual: `new MidiCore(this, "input substring", "output
substring")`, `send`, `noteOn`, `noteOff`, `controlChange`, `programChange`, `pitchBend`, `sysex(int[])`,
`poll(handler)`, `inject(status, d1, d2)` to fake a message, and the sketch-level `printMidiDevices()`,
`midiInputs()`, `midiOutputs()`. Python: `MidiCore(this, "in", "out")`, `print_midi_devices()`,
`midi_inputs()`, `midi_outputs()`.

{/* /include */}

## Now change something

Each `change this` comment marks a line worth changing. When you've had a go, head to your
[device page](/devices/) and the [ideas list](/examples/project-ideas/).
