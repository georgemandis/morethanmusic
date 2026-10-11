---
title: "Anything else"
description: "The NeoTrellis, a keyboard, a foot pedal, whatever you brought. The generic helper reads it; the Explorer tells you what it sends."
sidebar_position: 7
---

{/* generated from devices/anything-else/device.md by `node website/refresh.mjs devices`; edit the source, not this */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# Anything else

The [Trinkeys](./slide-trinkey.md), the NeoTrellis, a keyboard you brought from home, a drum pad, a foot pedal. If the operating
system sees it as a MIDI device, the generic helper can read it and the Explorer will show you what it
sends.

| | |
|---|---|
| Maker | Anyone |
| USB name | Whatever the Explorer prints at the top. |
| Ports | Whatever it has. Most controllers are 1 in, 1 out. |
| Sends | Notes and CCs. The Explorer tells you which numbers. |
| Receives | Sometimes. Try the Explorer's send panel on anything with lights. |

## Find out what it sends

1. Plug it in and open [the Explorer](/the-explorer/).
2. Press, turn, slide or tilt everything once. Write down the note and CC numbers.
3. Note the device name at the top. That is the substring you give the helper.

## On the table

| Device | What it is | What it sends |
|---|---|---|
| [Slide Trinkey](./slide-trinkey.md) | Adafruit USB stick with a slider, a touch pad and two pixels. Shows up as "Slide Trinkey M0". | Slider is CC 1, 0 at the left to 127 at the right. Touch pad is note 60. Send it a note on and the pixels take that note's colour for a second. Firmware in [firmware/trinkey-midi/](pathname:///firmware/trinkey-midi/README.md). |
| [Rotary Trinkey](./rotary-trinkey.md) | A click knob with a push switch, a touch pad and one pixel. Shows up as "Rotary Trinkey M0". | Knob is CC 2 as an absolute 0..127 position and CC 3 as relative clicks (1 clockwise, 127 counter-clockwise). Pressing the knob is note 61, the touch pad note 62. Same colour trick on incoming notes. |
| NeoTrellis M4 | Adafruit's 4×8 grid of RGB-lit buttons with an accelerometer | Probably notes for the buttons and CCs for tilt. Check the Explorer. It is a grid, so the Midi Fighter ideas transfer. |
| Yours | Anything | Same drill. Explorer first. |

## Start here

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

<LiveSketch src="/starters/p5/anything-else/" title="AnyMidi starter, p5.js" />

Code: `starters/p5/anything-else/sketch.js`. Paste it into the
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

Open `starters/python/anymidi_starter/anymidi_starter.pyde`.

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

Open `starters/java/AnyMidiStarter/AnyMidiStarter.pde`. It draws every note and CC it sees.

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
| `new AnyMidi(this)`, `new AnyMidi(this, "name substring")` | The first input on the system, or the first whose name contains the substring. |
| `m.note(n)`, `m.cc(n)`, `m.down(n)` | The last value seen for that note or controller, 0..127, or -1 if it has never arrived. Whether a note is held. |
| `m.lastNote`, `m.lastCC`, `m.lastCCValue`, `m.last` | The most recent thing that happened, for sketches that react to whatever arrives. |
| `m.send(status, d1, d2)`, `m.noteOn(ch, n, vel)`, `m.controlChange(ch, cc, val)` | Output, for devices with lights. |
| `void noteOn(…)`, `void noteOff(…)`, `void controlChange(…)`, `void midiMessage(…)` | Define any in your sketch and the helper calls it with channel, number and value. |

### From the helpers' README

{/* include: midi-helpers/README.md#AnyMidi */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

For the NeoTrellis, whatever people bring, and a desk with four devices on it.

```java
AnyMidi m = new AnyMidi(this);                               // every input, first output
AnyMidi m = new AnyMidi(this, "name substring");             // one input and one output
m.connect(); m.status(); m.devices();                        // "listening to 4 inputs: PipSqueak, ..." / the input names
m.note(n); m.cc(n);                  // last value seen on any input, 0..127, -1 if never. A note's value is its velocity, 0 after Note Off
m.down(n);                           // note held?
m.lastNote; m.lastVelocity; m.lastCC; m.lastCCValue; m.lastChannel; m.lastDevice; m.pitchBend; m.pressure; m.count; m.last
m.send(status, d1, d2); m.noteOn(ch, n, vel); m.noteOff(ch, n); m.controlChange(ch, cc, val);
m.programChange(ch, p); m.pitchBend(ch, value); m.sysex(bytes);
```
With no name it listens to every input at once, so moving any device on the desk shows up. `status()`
reads `listening to N inputs: names`, or `connected to X` with a name. Sending goes to the first output,
or the named one.

Callbacks: the three generic ones, plus `pitchBend(int channel, int value)` (-8192..8191) and
`midiMessage(int status, int data1, int data2)` for anything else. Every one of them also accepts a
trailing `String device`, so `void noteOn(int channel, int note, int velocity, String device)` tells
you which input it was. Define whichever arity you want. `m.last` is a `MidiMsg` with `status, type,
channel, data1, data2, millis, sysex, device` and a readable `toString()`. The Explorer prints it.

Python: `AnyMidi(this)` or `AnyMidi(this, "name")`, `m.status`, `m.devices()`, `m.note(n)`, `m.cc(n)`,
`m.down(n)`, `m.last_note`, `m.last_cc`, `m.last_device`, `m.pitch_bend`, `m.count`, `m.last` (with
`.device`), `m.send`, `m.note_on`, `m.note_off`, `m.control_change`, `m.send_pitch_bend`, `m.sysex`.
Callbacks take the trailing `device` if you declare it: `def note_on(channel, note, velocity, device)`.

{/* /include */}

## The p5.js helpers

The same helpers for the browser: one script per device, or the bundle
`midi-helpers/p5/midi-helpers.js`, served from this site.

{/* include: midi-helpers/README.md#p5 */}

{/* pulled from midi-helpers/README.md by website/refresh.mjs; edit the source, not this */}

The same API for the browser, as plain classic scripts: no modules, no bundler, no dependencies. Each
device script defines one global constructor and carries its own copy of the Web MIDI plumbing
(`MidiCore`), guarded so it is defined once however many scripts you load. `midi-helpers.js` has all of
them. Works from `file://`, GitHub Pages and the workshop host. Sources are in `p5/src/`; `p5/build.sh`
concatenates them into the committed scripts.

```html
<script src="https://cdn.jsdelivr.net/npm/p5@1/lib/p5.min.js"></script>
<script src="midi-helpers.js"></script>   <!-- or pipsqueak.js alone -->
<script>
const stick = new PipSqueak();            // never touches hardware until connect()
function setup() { createCanvas(600, 600); stick.connectOnClick(); }
function draw() {
  background(20);
  circle(300 + stick.x * 250, 300 - stick.y * 250, stick.pressed ? 60 : 30);
}
function stickPressed() { console.log("click"); }
</script>
```

In the p5.js web editor (editor.p5js.org, in Chrome, Edge or Opera): open `index.html` in the sketch
files panel and add, after the p5 tag,

```html
<script src="https://morethanmusic.dev/mtm-midi-helpers/latest/midi-helpers.js"></script>
```

Write the sketch as above. Press Play, click the canvas once. The browser asks for MIDI permission the
first time and the helper connects. The editor's preview iframe allows Web MIDI: `PreviewFrame.jsx` on the
develop branch lists `midi` in the iframe's `allow` attribute, with `allow-same-origin` and
`allow-scripts` in its sandbox. A real click-through is still on the hardware checklist. If anything is
off, use the editor's full-screen preview or download the sketch and open it in Chrome.

Connecting. Web MIDI wants a user gesture, so every helper has `connectOnClick()`. It waits for the first
click, touch or key anywhere on the page, calls `connect()`, and keeps a status string in `helper.status`
(`click to connect MIDI`, `connecting...`, `connected to X`, `no MIDI device matching 'pipsqueak'`, `Web
MIDI unavailable: ...`). On p5 1.x it also registers a `post` hook that draws that status bottom-left until
a device connects. On p5 2.x, or for your own look, call `helper.drawHint()` at the end of `draw()` or
pass a function: `stick.connectOnClick((status) => text(status, 10, 20))`. `await stick.connect()` works
too, from `mousePressed()` say, and resolves to true or false. Not found never throws. The constructor
never touches hardware.

Frame sync. Each helper runs its own `requestAnimationFrame` loop, so `pressed` and `justPressed()`
change at most once per frame, between draws. Set `helper.autoUpdate = false` and call `helper.update()`
yourself if you need control (instance mode, tests).

Callbacks are global functions: `noteOn(channel, note, velocity)`, `noteOff(...)`, `controlChange(channel,
number, value)` from every helper; `stickPressed()` / `stickReleased()`; `padPressed(index)` /
`padReleased(index)` / `bankChanged(bank)` (Midi Fighter); `padPressed(x, y)` / `padReleased(x, y)` /
`buttonPressed(id)` / `buttonReleased(id)` (Launchpad); `touchPressed(pad)` / `touchReleased(pad)` /
`accelChanged()`; `pitchBend(channel, value)` / `midiMessage(status, d1, d2)` (AnyMidi). The generic
ones get the device name as one more argument: `function noteOn(channel, note, velocity, device)`.
JavaScript cannot overload `padPressed`, so a sketch with both grid devices passes `{ callbacks: {...} }`
to one of them.
Any helper takes `{ callbacks: { padPressed(i) {...} } }` to skip the global lookup (instance mode).

Keyboard stand-ins work while nothing is connected: arrows + SPACE (PipSqueak), `1234 qwer asdf zxcv`
(Midi Fighter), `1`..`8` (Circuit Playground touch pads), arrows / `T` / Enter (Trinkeys).

Per device, the surface is the Java one with JS idioms. Constructors take an options object or a name
string: `new PipSqueak({ name, x: {...}, y: {...}, button: {...}, deadzone, smoothing })` (same JSON
shape as everywhere else), `new MidiFighter({ name, channel, mode, map })`, `new Launchpad({ name })`,
`new CircuitPlayground({ name })`, `new AnyMidi("name")` / `new AnyMidi()` (every input).

- `stick.x`, `stick.y`, `stick.angle` (null in the deadzone), `stick.magnitude`, `stick.pressed`,
  `stick.justPressed()`, `stick.justReleased()`, `stick.recenter()`, `stick.flash()`, `stick.send(status,
  d1, d2)`. On the constructor: `PipSqueak.normalize(rawX, rawY, config)`, `PipSqueak.normalizeAxis`,
  `PipSqueak.mergeConfig`.
- `mf.pressed(i)`, `mf.justPressed(i)`, `mf.justReleased(i)`, `mf.bank` (0..3), `mf.mode`, `mf.led(i, on,
  bank)`, `mf.leds([...])` or a 16-bit mask, `mf.clear()`, `mf.setMap(json)`; `MidiFighter.noteForIndex(i,
  mode, bank)`, `MidiFighter.indexForNote(note, mode)`.
- `pad.pressed(x, y)`, `pad.justPressed(x, y)`, `pad.buttonPressed(id)`, `pad.set(x, y, c)` where `c` is a
  p5 color, `"#ff0080"`, `[r, g, b]`, a palette index 0..127, or a name (`"red"`, `"cyan"`, ...),
  `pad.setRGB`, `pad.flash`, `pad.pulse`, `pad.button(id, c)`, `pad.clear()`, `pad.text(str, c, speed,
  loop)`, `pad.stopText()`, `pad.close()`. The Launchpad asks for SysEx permission (programmer mode,
  RGB). Refused, it still connects and snaps RGB colours to the nearest palette entry. `pagehide`
  restores Live mode. `Launchpad.toColor(c)`, `Launchpad.xyToNote` and the rest are exposed.
- `cpx.touch(i)`, `cpx.accel.x/y/z`, `cpx.light`, `cpx.sound`, `cpx.temperature`, `cpx.sensor`,
  `cpx.mode`, `cpx.pixels(r, g, b)`, `cpx.clear()`.
- `m.status`, `m.devices()`, `m.note(n)`, `m.cc(n)`, `m.down(n)`, `m.lastNote`, `m.lastCC`,
  `m.lastDevice`, `m.pitchBend`, `m.count`, `m.last` (with `.device`), `m.send`, `m.noteOn`, `m.noteOff`,
  `m.controlChange`, `m.programChange`, `m.sendPitchBend`, `m.sysex`.
- `slide.value`, `slide.raw`, `slide.touched`, `slide.justTouched()`, `slide.pixel(note)`; `knob.value`,
  `knob.raw`, `knob.delta`, `knob.pressed`, `knob.justPressed()`, `knob.touched`, `knob.pixel(note)`.

The p5 ES modules in `grid-controllers/` and `pipsqueak/` are untouched; these scripts port their protocol
logic. Differences: Midi Fighter banks are 0..3 here (1..4 there), `setRGB` takes 0..255 (0..127 there),
and there is no event emitter. Use the global callbacks or poll in `draw()`.

{/* /include */}

## Try first

- One CC, one number on screen, huge. Then a colour, then a speed.
- A piano keyboard as 61 buttons. Each note a column, velocity its height.
- Two controls as x and y.

More on the [ideas page](/examples/project-ideas/#trinkeys-neotrellis-m4-and-the-things-people-brought).

## Without the helper

For an unknown device the raw path is HelloMidi: it opens every input and prints every message, which
is most of what AnyMidi does. [The three bytes, no helpers](/examples/three-bytes-no-helpers/).
