---
title: "Rotary Trinkey"
description: "Adafruit's USB stick with a click knob, a push switch, a touch pad and one pixel. Two CCs, two notes, George's CircuitPython on it."
sidebar_position: 6
---

{/* generated from devices/rotary-trinkey/device.md by `node website/refresh.mjs devices`; edit the source, not this */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# Rotary Trinkey

A USB stick with a rotary encoder you solder on yourself, a push switch under the knob, a capacitive
touch pad and one NeoPixel. George's CircuitPython firmware makes it a class-compliant MIDI device: no
driver, no library on either end. The knob sends two things at once, an absolute position and a
relative click, so a sketch can pick whichever is easier.

| | |
|---|---|
| Maker | Adafruit, with George's firmware |
| USB name | "Rotary Trinkey M0" |
| Ports | 1 in, 1 out |
| Sends | CC 2 absolute and CC 3 relative for the knob, note 61 for the press, note 62 for the touch pad, channel 1. |
| Receives | Any note on. The pixel takes that note's colour for a second. |
| Buy | [adafruit.com/product/4964](https://www.adafruit.com/product/4964) |
| Firmware | [firmware/trinkey-midi](pathname:///firmware/trinkey-midi/README.md), CircuitPython |

## What it sends

| Control | Message | Numbers | Notes |
|---|---|---|---|
| Knob, absolute | CC | CC 2, 0 to 127 | The position. Sent on every click, and once at startup. |
| Knob, relative | CC | CC 3 | 1 is one click clockwise, 127 one click counter-clockwise. Two's complement, so 2 is two clicks. |
| Knob press | Note on, note off | Note 61, velocity 127 | Down and up. |
| Touch pad | Note on, note off | Note 62, velocity 127 | On when touched, off on release. |
| USB name | | "Rotary Trinkey M0" | The drive, when it mounts, is `ROTARYPY`. |

## What it receives

| Message | Effect |
|---|---|
| Any note on | The pixel takes a colour from the note number for one second. `m.noteOn(1, 61, 127)` from a sketch. |

Everything is on channel 1. The board sends one CC 2 with the knob's position at startup. Whatever the
switch reads at power-up counts as released, so don't hold it while plugging in. Flashing and the pin
names are in the [trinkey-midi README](pathname:///firmware/trinkey-midi/README.md).

## Start here

There is no dedicated starter yet. The generic one draws every note and CC it hears, so turn the knob
and watch CC 2 and CC 3. Then use the helper below.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

<LiveSketch src="/starters/p5/anything-else/" title="Trinkeys starter, p5.js" />

This is the generic starter. It draws every note and CC the knob sends. Code: `starters/p5/anything-else/sketch.js`. Paste it into the
[p5.js web editor](/pick-your-tool/p5/#use-the-p5js-web-editor) with the helper script tag, or
download the folder and double-click `index.html`.

{/* include: starters/p5/anything-else/sketch.js */}

```javascript title="sketch.js"
// AnyMidi starter: the Explorer's raw log as a sketch. A connection line, a device picker, the last 12 messages
// (time, device, channel, type, number, value, raw bytes), then note circles and CC bars underneath to play with.
// Click once to connect MIDI. No device: letters are notes, drag the mouse for a knob.
let m, picker, known = "", log = [];
const pop = new Array(128).fill(0), knob = new Array(128).fill(0);
const TYPES = { 0x80: "noteOff", 0x90: "noteOn", 0xa0: "polyTouch", 0xb0: "cc", 0xc0: "program", 0xd0: "aftertouch", 0xe0: "pitchBend" };

function setup() {
  const cnv = createCanvas(900, 560);
  textFont("monospace"); textSize(12); noStroke();
  picker = createSelect(); picker.option("All inputs");         // the device picker, above the canvas
  cnv.elt.parentNode.insertBefore(picker.elt, cnv.elt);
  m = new AnyMidi();                                             // no name: every input
  m.connectOnClick(() => {});                                    // the connection line below replaces the helper's hint
}

const wanted = (device) => picker.value() === "All inputs" || device === picker.value();
function logMsg(status, d1, d2, device, value) {                 // one line per message, newest last
  if (!wanted(device)) return;
  const type = TYPES[status & 0xf0] || "status " + status, ch = status < 0xf0 ? "ch" + String((status & 0x0f) + 1).padStart(2) : "    ";
  log.push(`${(millis() / 1000).toFixed(2).padStart(7)}  ${device.slice(0, 18).padEnd(18)}  ${ch}  ${type.padEnd(10)} ${String(d1).padStart(3)} ${String(value).padStart(5)}   [${status}, ${d1}, ${d2}]`);
  if (log.length > 12) log.shift();
}
function raw(status, d1, d2, device) {                           // the bytes as received; rebuilt for the keyboard stand-in
  return device === "keyboard" || !m.last ? [status, d1, d2] : [m.last.status, m.last.data1, m.last.data2];
}

function draw() {
  if (m.core.access && !m.core.access.onstatechange) m.core.access.onstatechange = () => m.connect();   // devices come and go: reopen
  const inputs = m.devices();                                    // repopulate the picker when the list changes
  if (inputs.join("|") !== known) {
    known = inputs.join("|"); const keep = picker.value(); picker.elt.innerHTML = "";
    picker.option("All inputs"); for (const n of inputs) picker.option(n); if (inputs.includes(keep)) picker.selected(keep);
  }
  background(15); fill(200);
  text(m.connected() ? m.status : m.status.startsWith("no MIDI") ? "no MIDI inputs found" : m.status, 16, 22);   // the connection line
  for (let i = 0; i < log.length; i++) text(log[i], 16, 50 + i * 16);
  for (let n = 0; n < 128; n++) {                                // the playground: change this part
    const x = map(n, 0, 127, 10, width - 10);
    fill(90, 200, 255); rect(x - 2, height - 10, 4, -knob[n] * 1.5);          // change this: bars for CC values 0..127
    if (pop[n] > 0) { fill(255, 120, 80, pop[n] * 2); circle(x, 370, pop[n]); pop[n] -= 2; }   // change this: what a note looks like
  }
}

// The helper calls these for every message, with the device name last. Channel is 1..16.
function noteOn(ch, n, v, dev = "keyboard") { logMsg(...raw(0x90 | (ch - 1), n, v, dev), dev, v); if (wanted(dev)) pop[n] = 40 + v; }       // change this
function noteOff(ch, n, v, dev = "keyboard") { logMsg(...raw(0x80 | (ch - 1), n, v, dev), dev, v); }
function controlChange(ch, cc, val, dev = "keyboard") { logMsg(...raw(0xb0 | (ch - 1), cc, val, dev), dev, val); if (wanted(dev)) knob[cc] = val; }   // change this
function pitchBend(ch, value, dev = "keyboard") { const v = value + 8192; logMsg(...raw(0xe0 | (ch - 1), v & 0x7f, v >> 7, dev), dev, value); }
function midiMessage(status, d1, d2, dev = "keyboard") { logMsg(status, d1, d2, dev, d2); }   // everything else: program, aftertouch, clock...

// Stand-ins, so the sketch does something with no device.
function keyPressed() { if (key.length === 1) noteOn(1, 48 + key.charCodeAt(0) % 36, 100); }
function mouseDragged() { controlChange(1, 1 + floor(mouseY * 8 / height), floor(map(mouseX, 0, width, 0, 127))); }
```

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

Open `starters/python/anymidi_starter/anymidi_starter.pyde`. The generic starter. It runs as is. For the helper, copy `trinkeys.py` from `midi-helpers/python/` next to it.

{/* include: starters/python/anymidi_starter/anymidi_starter.pyde */}

```python title="anymidi_starter.pyde"
# AnyMidi starter: the Explorer's raw log as a sketch. A connection line, a device list to click, the last 12
# messages (time, device, channel, type, number, value, raw bytes), then note circles and CC bars to play with.
# No device: letters are notes, drag the mouse for a knob. Under 60 lines; edit the lines marked "change this".
from __future__ import division, print_function
from anymidi import AnyMidi

m = None
S = {"picked": "All inputs"}
log = []
pop, knob = [0] * 128, [0] * 128   # per note: a shrinking circle; per CC: the last value
TYPES = {0x80: "noteOff", 0x90: "noteOn", 0xA0: "polyTouch", 0xB0: "cc", 0xC0: "program", 0xD0: "aftertouch", 0xE0: "pitchBend"}

def setup():
    global m
    size(900, 560); textFont(createFont("Monospaced", 12)); noStroke()
    m = AnyMidi(this)    # no name: every input
    m.connect()          # console: every port, and which ones opened
def wanted(device): return S["picked"] == "All inputs" or S["picked"] == device
def choices(): return ["All inputs"] + m.devices()

def log_msg(status, d1, d2, device, value):    # one line per message, newest last
    if not wanted(device): return
    if device != "keyboard" and m.last is not None: status, d1, d2 = m.last.status, m.last.data1, m.last.data2   # the bytes as received
    ch = "ch%2d" % ((status & 0x0F) + 1) if status < 0xF0 else "    "
    log.append("%7.2f  %-18.18s  %s  %-10s %3d %5d   [%d, %d, %d]" % (millis() / 1000.0, device, ch, TYPES.get(status & 0xF0, "status %d" % status), d1, value, status, d1, d2))
    if len(log) > 12: del log[0]
def draw():
    m.update()           # the callbacks fire here
    background(15); fill(200)
    text(m.status if m.connected() else "no MIDI inputs found", 16, 22)   # the connection line
    x = 16                                                       # the device list: click one
    for name in choices():
        fill(color(255, 200, 60) if name == S["picked"] else 130); text(name, x, 42); x += textWidth(name) + 24
    fill(200)
    for i, line in enumerate(log): text(line, 16, 70 + i * 16)
    for n in range(128):                                         # the playground: change this part
        px = 10 + n * (width - 20) / 127
        fill(90, 200, 255); rect(px - 2, height - 10, 4, -knob[n] * 1.5)          # change this: bars for CC values 0..127
        if pop[n] > 0:
            fill(255, 120, 80, pop[n] * 2); circle(px, 370, pop[n]); pop[n] -= 2  # change this: what a note looks like

# The helper calls these for every message, device name last. Channel is 1..16.
def note_on(ch, n, v, dev="keyboard"):
    log_msg(0x90 | (ch - 1), n, v, dev, v)
    if wanted(dev): pop[n] = 40 + v                              # change this
def note_off(ch, n, v, dev="keyboard"): log_msg(0x80 | (ch - 1), n, v, dev, v)
def control_change(ch, cc, val, dev="keyboard"):
    log_msg(0xB0 | (ch - 1), cc, val, dev, val)
    if wanted(dev): knob[cc] = val                               # change this
def pitch_bend(ch, value, dev="keyboard"): v = value + 8192; log_msg(0xE0 | (ch - 1), v & 0x7F, v >> 7, dev, value)
def midi_message(status, d1, d2, dev="keyboard"): log_msg(status, d1, d2, dev, d2)   # everything else
# Stand-ins, so the sketch does something with no device.
def keyPressed():
    if key != CODED: note_on(1, 48 + ord(str(key)[0]) % 36, 100)
def mousePressed():
    x = 16
    for name in choices():
        if 30 < mouseY < 48 and x <= mouseX < x + textWidth(name): S["picked"] = name
        x += textWidth(name) + 24
def mouseDragged(): control_change(1, 1 + mouseY * 8 // height, mouseX * 127 // width)
def stop(): m.close()
```

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

Open `starters/java/AnyMidiStarter/AnyMidiStarter.pde`. The generic starter. It runs as is. For the helper, copy `Trinkeys.pde` from `midi-helpers/java/` into the sketch folder.

{/* include: starters/java/AnyMidiStarter/AnyMidiStarter.pde */}

```java title="AnyMidiStarter.pde"
// AnyMidi starter: the Explorer's raw log as a sketch. A connection line, a device list to click, the last 12
// messages (time, device, channel, type, number, value, raw bytes), then note circles and CC bars to play with.
// No device: letters are notes, drag the mouse for a knob. Under 60 lines; edit the lines marked "change this".
AnyMidi m;
String picked = "All inputs";
ArrayList<String> log = new ArrayList<String>();
float[] pop = new float[128];      // one per note number, shrinks every frame
int[] knob = new int[128];         // last value of each control change number

void setup() {
  size(900, 560);
  textFont(createFont("Monospaced", 12));
  noStroke();
  m = new AnyMidi(this);           // no name: every input
  m.connect();                     // console: every port, and which ones opened
}

boolean wanted(String device) { return picked.equals("All inputs") || picked.equals(device); }
String[] choices() { return concat(new String[] { "All inputs" }, m.devices()); }
String typeName(int t) { return t == 0x80 ? "noteOff" : t == 0x90 ? "noteOn" : t == 0xA0 ? "polyTouch" : t == 0xB0 ? "cc" : t == 0xC0 ? "program" : t == 0xD0 ? "aftertouch" : t == 0xE0 ? "pitchBend" : "status " + t; }

void logMsg(int status, int d1, int d2, String device, int value) {   // one line per message, newest last
  if (!wanted(device)) return;
  if (!device.equals("keyboard") && m.last != null) { status = m.last.status; d1 = m.last.data1; d2 = m.last.data2; }   // the bytes as received, not rebuilt
  String ch = status < 0xF0 ? String.format("ch%2d", (status & 0x0F) + 1) : "    ";
  log.add(String.format("%7.2f  %-18.18s  %s  %-10s %3d %5d   [%d, %d, %d]", millis() / 1000.0, device, ch, typeName(status & 0xF0), d1, value, status, d1, d2));
  if (log.size() > 12) log.remove(0);
}

void draw() {
  background(15);
  fill(200);
  text(m.connected() ? m.status() : "no MIDI inputs found", 16, 22);   // the connection line
  float x = 16;                                                        // the device list: click one
  for (String name : choices()) { fill(name.equals(picked) ? color(255, 200, 60) : 130); text(name, x, 42); x += textWidth(name) + 24; }
  fill(200);
  for (int i = 0; i < log.size(); i++) text(log.get(i), 16, 70 + i * 16);
  for (int n = 0; n < 128; n++) {                                      // the playground: change this part
    float px = map(n, 0, 127, 10, width - 10);
    fill(90, 200, 255); rect(px - 2, height - 10, 4, -knob[n] * 1.5);              // change this: bars for CC values 0..127
    if (pop[n] > 0) { fill(255, 120, 80, pop[n] * 2); circle(px, 370, pop[n]); pop[n] -= 2; }   // change this: what a note looks like
  }
}

// The helper calls these for every message, with the device name last. Channel is 1..16.
void noteOn(int ch, int n, int v, String dev) { logMsg(0x90 | (ch - 1), n, v, dev, v); if (wanted(dev)) pop[n] = 40 + v; }        // change this
void noteOff(int ch, int n, int v, String dev) { logMsg(0x80 | (ch - 1), n, v, dev, v); }
void controlChange(int ch, int cc, int val, String dev) { logMsg(0xB0 | (ch - 1), cc, val, dev, val); if (wanted(dev)) knob[cc] = val; }   // change this
void pitchBend(int ch, int value, String dev) { int v = value + 8192; logMsg(0xE0 | (ch - 1), v & 0x7F, v >> 7, dev, value); }
void midiMessage(int status, int d1, int d2, String dev) { logMsg(status, d1, d2, dev, d2); }   // everything else: program, aftertouch, clock...

// Stand-ins, so the sketch does something with no device.
void keyPressed() { if (key != CODED) noteOn(1, 48 + key % 36, 100, "keyboard"); }
void mousePressed() { float x = 16; for (String name : choices()) { if (mouseY > 30 && mouseY < 48 && mouseX >= x && mouseX < x + textWidth(name)) picked = name; x += textWidth(name) + 24; } }
void mouseDragged() { controlChange(1, 1 + mouseY * 8 / height, int(map(mouseX, 0, width, 0, 127)), "keyboard"); }
```

{/* /include */}

</TabItem>
</Tabs>

## The helper

| | |
|---|---|
| `new RotaryTrinkey(this)` | Connects to the first device whose name contains "Rotary Trinkey". `(this, "name")` to change it. |
| `knob.value`, `knob.raw` | Absolute position, 0 to 1 and 0 to 127. |
| `knob.delta` | Clicks since the last frame. Positive is clockwise, 0 when still. A fast spin reads as 2 or 3. |
| `knob.pressed`, `knob.justPressed()`, `knob.justReleased()` | The push switch. |
| `knob.touched`, `knob.justTouched()`, `knob.justTouchReleased()` | The touch pad. |
| `knob.pixel(note)` | Sends a note on and off to the board. The pixel shows that note's colour for a second. |
| `void knobTurned(int delta)`, `void knobPressed()`, `void knobReleased()`, `void touchPressed()`, `void touchReleased()` | Define any in your sketch and the helper calls it. |

Stand-ins with nothing plugged in: LEFT and RIGHT are one click each, ENTER presses, `T` touches.

### From the helpers' README

{/* include: midi-helpers/README.md#Trinkeys */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

Thin helpers over the CircuitPython firmware in `trinkeys/` (its README covers flashing). One file holds
both classes.

```java
SlideTrinkey slide = new SlideTrinkey(this);     // matches "Slide Trinkey"; (this, "name") to change it
RotaryTrinkey knob = new RotaryTrinkey(this);    // matches "Rotary Trinkey"
slide.value;                                     // 0..1, 0 = left, 1 = right
slide.raw;                                       // the CC value 0..127, -1 until the first message (the board sends one at startup)
slide.touched; slide.justTouched(); slide.justReleased();
slide.pixel(note);                               // Note On + Note Off to the board: pixel colour from the note number, one second
knob.value; knob.raw;                            // absolute position 0..1 / 0..127
knob.delta;                                      // clicks since the last frame: + clockwise, - counter-clockwise, 0 when still
knob.pressed; knob.justPressed(); knob.justReleased();
knob.touched; knob.justTouched(); knob.justTouchReleased(); knob.pixel(note);
```
Callbacks: `sliderChanged(float value)`, `knobTurned(int delta)`, `knobPressed()`, `knobReleased()`,
`touchPressed()`, `touchReleased()`. Both boards use the touch names; with both plugged in, read
`slide.touched` / `knob.touched`. Stand-ins: Slide = LEFT/RIGHT move, `T` touches; Rotary = LEFT/RIGHT
one click per press, ENTER presses, `T` touches.

Message map (channel 1, from `trinkeys/README.md`):

| Board | Sends | Listens |
|---|---|---|
| Slide Trinkey M0 | CC 1 slider 0..127 (0 left, 127 right); note 60 touch pad (Note On / Off) | any Note On: pixel colour from the note number, one second |
| Rotary Trinkey M0 | CC 2 absolute 0..127; CC 3 relative, 1 = one click clockwise, 127 = one click counter-clockwise (two's complement, so 2 = two clicks); note 61 knob press; note 62 touch pad | same |

`delta` is the sum of the relative clicks since the previous frame, so a fast spin reads as 2 or 3.

Python: `SlideTrinkey(this)`, `RotaryTrinkey(this)`, `slide.value`, `slide.raw`, `slide.touched`,
`slide.just_touched()`, `slide.just_released()`, `slide.pixel(note)`, `knob.value`, `knob.raw`,
`knob.delta`, `knob.pressed`, `knob.just_pressed()`, `knob.just_released()`, `knob.touched`,
`knob.just_touched()`, `knob.pixel(note)`; callbacks `slider_changed(value)`, `knob_turned(delta)`,
`knob_pressed()`, `knob_released()`, `touch_pressed()`, `touch_released()`; module-level `relative(v)`.
p5: `new SlideTrinkey()`, `new RotaryTrinkey()` with the Java names; `RotaryTrinkey.relative(v)`.

{/* /include */}

## Try first

- A dial on screen that follows `value`. Then one that only ever moves by `delta`, so it never jumps.
- Scroll through a list of colours, press to pick one, send it back to the pixel.
- A metronome whose tempo is the knob.

More on the [ideas page](/examples/project-ideas/#trinkeys-neotrellis-m4-and-the-things-people-brought).

## Without the helper

Two CCs and two notes, so the raw path is HelloMidi: it opens every input and prints every message. Read
[the three bytes, no helpers](/examples/three-bytes-no-helpers/) first.

- Java mode: [`starters/raw/java/HelloMidi/`](pathname:///starters/raw/java/HelloMidi/HelloMidi.pde)
- Python Mode: [`starters/raw/python/hello_midi/`](pathname:///starters/raw/python/hello_midi/hello_midi.pyde)
- p5.js: [`starters/raw/p5/hello-midi/`](pathname:///starters/raw/p5/hello-midi/), or its [sketch.js](pathname:///starters/raw/p5/hello-midi/sketch.js)
