---
title: "The three bytes, no helpers"
description: The same first sketch with no helper tab at all, so you see the raw MIDI bytes in Java, Python Mode and p5.js.
sidebar_position: 2
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import LiveSketch from '@site/src/components/LiveSketch';

# The three bytes, no helpers

The helpers are convenient, but they're also a layer between you and the thing I actually want you to
see: three numbers arriving. So here's the same idea with no helper tab at all. HelloMidi lists every
MIDI device, opens every input, prints each message as `[status, data1, data2]`, and draws a circle
sized by the third byte and coloured by the second. It's under fifty lines in each language.

Plug in anything, press things, and watch the numbers. That's MIDI.

## Open it

In p5.js, open [starters/raw/p5/hello-midi/](pathname:///starters/raw/p5/hello-midi/) and click
once. In Python Mode it's `starters/raw/python/hello_midi/hello_midi.pyde`, in Java mode
`starters/raw/java/HelloMidi/HelloMidi.pde`. One file each, nothing else in the folder. No device?
Each key you press is a fake note on.

## The whole sketch

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

Loads nothing but p5, so it also works double-clicked from a folder or pasted into the web editor as is.
The helper-based starters live next to it at [/examples](pathname:///examples/).
The same `requestMIDIAccess` walk, with more words, is in George's CSS-Tricks article
[Dip Your Toes Into Hardware With WebMIDI](https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/).

<LiveSketch src="/starters/raw/p5/hello-midi/" title="HelloMidi, p5.js" />

{/* include: starters/raw/p5/hello-midi/sketch.js */}

```javascript title="sketch.js"
// HelloMidi: raw Web MIDI in p5.js, no helper. One call, navigator.requestMIDIAccess(), then every input's
// onmidimessage hands you the raw bytes. A connection line, a device picker, the last 12 messages, and a circle
// whose size is data2 and colour is data1. Click or press a key once to connect (browsers want a gesture first).
// No device: keys are fake notes.
//
// A MIDI message is three bytes. status = kind + channel (0x90 = note on, channel 1; 0xB2 = control change,
// channel 3). data1 = which note or knob. data2 = how hard, or the knob's value.
let access = null, picker, note = "click or press a key to connect MIDI", log = [], status = -1, data1 = 0, data2 = 0;
const TYPES = { 0x80: "noteOff", 0x90: "noteOn", 0xa0: "polyTouch", 0xb0: "cc", 0xc0: "program", 0xd0: "aftertouch", 0xe0: "pitchBend" };

function setup() {
  const cnv = createCanvas(900, 520);
  textFont("monospace"); textSize(12); colorMode(HSB, 127, 100, 100); noStroke();   // hue 0..127: a note number IS a hue
  picker = createSelect(); picker.option("All inputs");                            // the device picker, above the canvas
  cnv.elt.parentNode.insertBefore(picker.elt, cnv.elt);
  for (const ev of ["pointerdown", "keydown"]) window.addEventListener(ev, connect, { once: true });   // first gesture anywhere
}

function connect() {
  if (access) return;
  navigator.requestMIDIAccess().then((a) => { access = a; a.onstatechange = listen; listen(); })   // statechange: devices come and go
    .catch((e) => { note = "no Web MIDI here (Chrome, Edge or Opera needed); keys still work"; console.log(e); });
}
function listen() {                                                        // every input, and the picker rebuilt
  const names = [];
  for (const input of access.inputs.values()) { input.onmidimessage = (e) => onMidi(e.data, input.name); names.push(input.name); }
  const keep = picker.value(); picker.elt.innerHTML = ""; picker.option("All inputs");
  for (const n of names) picker.option(n); if (names.includes(keep)) picker.selected(keep);
  note = names.length ? `listening to ${names.length} input${names.length > 1 ? "s" : ""}: ${names.join(", ")}` : "no MIDI inputs found; keys still work";
}

function onMidi(b, device = "keyboard") {                                  // b[0] status, b[1] data1, b[2] data2
  if (b.length < 3) return;                                                // 1- and 2-byte messages and SysEx: ignored here
  if (picker.value() !== "All inputs" && device !== picker.value()) return;
  [status, data1, data2] = b;
  const type = TYPES[status & 0xf0] || "status", ch = status < 0xf0 ? "ch" + String((status & 0x0f) + 1).padStart(2) : "    ";
  log.push(`${(millis() / 1000).toFixed(2).padStart(7)}  ${device.slice(0, 18).padEnd(18)}  ${ch}  ${type.padEnd(10)} ${String(data1).padStart(3)} ${String(data2).padStart(3)}   [${status}, ${data1}, ${data2}]`);
  if (log.length > 12) log.shift();
}

function draw() {
  background(0, 0, 10);
  fill(0, 0, 90);
  text(note, 16, 22);                                                      // the connection line
  for (let i = 0; i < log.length; i++) text(log[i], 16, 50 + i * 16);     // newest at the bottom
  if (status < 0) return;
  fill(data1, 80, 100);                                                    // colour = data1 (the note or controller number)
  circle(width / 2, 400, 20 + data2 * 2);                                  // size = data2 (velocity or value)
}

function keyPressed() { onMidi([0x90, key.charCodeAt(0) % 128, 100]); }  // stand-in: a note on
```

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: starters/raw/python/hello_midi/hello_midi.pyde */}

```python title="hello_midi.pyde"
# HelloMidi: raw MIDI in Python Mode, no helper. Opens every MIDI input, shows a connection line, a device list to
# click, the last 12 messages (time, device, channel, type, number, value, raw bytes) and a circle whose size is
# data2 and colour is data1. No device: keys are fake notes. Java's own MIDI classes do the work; Python Mode is
# Jython, so it can use them, with one wrinkle: the JDK hides its MIDI device classes, so methods are called through
# the interface's Method object (jcall below) instead of dev.open().
#
# A MIDI message is three bytes. status = kind + channel (0x90 = note on, channel 1; 0xB2 = control change,
# channel 3). data1 = which note or knob. data2 = how hard, or the knob's value.
from __future__ import division, print_function
from javax.sound.midi import MidiSystem, MidiDevice, Transmitter, Receiver, Sequencer

TYPES = {0x80: "noteOff", 0x90: "noteOn", 0xA0: "polyTouch", 0xB0: "cc", 0xC0: "program", 0xD0: "aftertouch", 0xE0: "pitchBend"}
names, log = [], []
S = {"picked": "All inputs", "status": -1, "data1": 0, "data2": 0}   # the last three bytes seen (written by the MIDI thread)

def jcall(iface, obj, name, *args):      # call obj.name(*args) through the interface: the JDK hides its MIDI classes from Jython
    for m in iface.getMethods():
        if m.getName() == name and m.getParameterCount() == len(args): return m.invoke(obj, list(args))

class Listener(Receiver):                # one per input; Java calls send() on its own thread
    def __init__(self, device): self.device = device
    def send(self, msg, t):
        b = msg.getMessage()             # Java bytes are signed: & 0xFF makes them 0..255
        if len(b) >= 3: on_midi(b[0] & 0xFF, b[1] & 0xFF, b[2] & 0xFF, self.device)   # 1- and 2-byte messages and SysEx: ignored
    def close(self): pass

def setup():
    size(900, 520); textFont(createFont("Monospaced", 12)); colorMode(HSB, 127, 100, 100); noStroke()   # hue 0..127: a note IS a hue
    for info in MidiSystem.getMidiDeviceInfo():
        dev = MidiSystem.getMidiDevice(info)
        if jcall(MidiDevice, dev, "getMaxTransmitters") == 0 or isinstance(dev, Sequencer): continue   # a "transmitter" sends to us: an input
        try:
            jcall(MidiDevice, dev, "open")
            jcall(Transmitter, jcall(MidiDevice, dev, "getTransmitter"), "setReceiver", Listener(info.getName()))
            names.append(info.getName()); print("input: " + info.getName())
        except Exception as e: print("could not open %s (in use by another program?): %s" % (info.getName(), e))
def on_midi(status, data1, data2, device):
    if S["picked"] != "All inputs" and S["picked"] != device: return
    S.update(status=status, data1=data1, data2=data2)
    ch = "ch%2d" % ((status & 0x0F) + 1) if status < 0xF0 else "    "
    log.append("%7.2f  %-18.18s  %s  %-10s %3d %3d   [%d, %d, %d]" % (millis() / 1000.0, device, ch, TYPES.get(status & 0xF0, "status"), data1, data2, status, data1, data2))
    if len(log) > 12: del log[0]
def choices(): return ["All inputs"] + names
def draw():
    background(0, 0, 10); fill(0, 0, 90)
    text("listening to %d input%s: %s" % (len(names), "s" if len(names) > 1 else "", ", ".join(names)) if names else "no MIDI inputs found; keys still work", 16, 22)
    x = 16                                                       # the device list: click one
    for n in choices():
        fill(0, 0, 100 if n == S["picked"] else 55); text(n, x, 42); x += textWidth(n) + 24
    fill(0, 0, 90)
    for i, line in enumerate(log[:]): text(line, 16, 70 + i * 16)   # newest at the bottom
    if S["status"] < 0: return
    fill(S["data1"], 80, 100)                                    # colour = data1 (the note or controller number)
    circle(width / 2, 400, 20 + S["data2"] * 2)                  # size = data2 (velocity or value)
def mousePressed():
    x = 16
    for n in choices():
        if 30 < mouseY < 48 and x <= mouseX < x + textWidth(n): S["picked"] = n
        x += textWidth(n) + 24
def keyPressed(): on_midi(0x90, 60 if key == CODED else ord(key[0]) % 128, 100, "keyboard")   # stand-in: a note on
```

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: starters/raw/java/HelloMidi/HelloMidi.pde */}

```java title="HelloMidi.pde"
// HelloMidi: raw MIDI in Processing, no helper library. Opens every MIDI input, shows a connection line, a device
// list to click, the last 12 messages (time, device, channel, type, number, value, raw bytes) and a circle whose
// size is data2 and colour is data1. No device: keys are fake notes. Everything is javax.sound.midi, in Java already.
//
// A MIDI message is three bytes. status = kind + channel (0x90 = note on, channel 1; 0xB2 = control change,
// channel 3). data1 = which note or knob. data2 = how hard, or the knob's value.
import javax.sound.midi.*;

ArrayList<String> names = new ArrayList<String>(), log = new ArrayList<String>();
String picked = "All inputs";
volatile int status = -1, data1 = 0, data2 = 0;   // the last three bytes seen (written by the MIDI thread, read by draw())

void setup() {
  size(900, 520);
  textFont(createFont("Monospaced", 12));
  colorMode(HSB, 127, 100, 100);                  // hue 0..127: a note number IS a hue
  noStroke();
  for (MidiDevice.Info info : MidiSystem.getMidiDeviceInfo()) try {
    MidiDevice dev = MidiSystem.getMidiDevice(info);
    if (dev.getMaxTransmitters() == 0 || dev instanceof Sequencer) continue;   // a "transmitter" sends to us: an input
    final String name = info.getName();
    dev.open();
    dev.getTransmitter().setReceiver(new Receiver() {                          // Java calls send() on its own thread
      public void send(MidiMessage m, long time) { onMidi(m.getMessage(), name); }
      public void close() { }
    });
    names.add(name);
    println("input: " + name);
  } catch (MidiUnavailableException e) { println("could not open " + info.getName() + " (in use by another program?)"); }
}

String typeName(int t) { return t == 0x80 ? "noteOff" : t == 0x90 ? "noteOn" : t == 0xA0 ? "polyTouch" : t == 0xB0 ? "cc" : t == 0xC0 ? "program" : t == 0xD0 ? "aftertouch" : t == 0xE0 ? "pitchBend" : "status"; }

synchronized void onMidi(byte[] b, String device) {   // b[0] status, b[1] data1, b[2] data2. Java bytes are signed: & 0xFF
  if (b.length < 3) return;                           // 1- and 2-byte messages and SysEx: ignored here
  if (!picked.equals("All inputs") && !picked.equals(device)) return;
  status = b[0] & 0xFF; data1 = b[1] & 0xFF; data2 = b[2] & 0xFF;
  String ch = status < 0xF0 ? String.format("ch%2d", (status & 0x0F) + 1) : "    ";
  log.add(String.format("%7.2f  %-18.18s  %s  %-10s %3d %3d   [%d, %d, %d]", millis() / 1000.0, device, ch, typeName(status & 0xF0), data1, data2, status, data1, data2));
  if (log.size() > 12) log.remove(0);
}

void draw() {
  background(0, 0, 10);
  fill(0, 0, 90);
  text(names.isEmpty() ? "no MIDI inputs found; keys still work" : "listening to " + names.size() + " input" + (names.size() > 1 ? "s" : "") + ": " + join(names.toArray(new String[0]), ", "), 16, 22);
  float x = 16;                                                        // the device list: click one
  for (String n : choices()) { fill(0, 0, n.equals(picked) ? 100 : 55); text(n, x, 42); x += textWidth(n) + 24; }
  fill(0, 0, 90);
  synchronized (this) { for (int i = 0; i < log.size(); i++) text(log.get(i), 16, 70 + i * 16); }   // newest at the bottom
  if (status < 0) return;
  fill(data1, 80, 100);                                                // colour = data1 (the note or controller number)
  circle(width / 2, 400, 20 + data2 * 2);                              // size = data2 (velocity or value)
}

String[] choices() { String[] c = names.toArray(new String[0]); return concat(new String[] { "All inputs" }, c); }
void mousePressed() { float x = 16; for (String n : choices()) { if (mouseY > 30 && mouseY < 48 && mouseX >= x && mouseX < x + textWidth(n)) picked = n; x += textWidth(n) + 24; } }
void keyPressed() { onMidi(new byte[] { (byte) 0x90, (byte) (key % 128), (byte) 100 }, "keyboard"); }   // stand-in: a note on
```

{/* /include */}

</TabItem>
</Tabs>

## What to notice

p5 gives you a `Uint8Array`, already 0 to 255. Java bytes are signed, so 200 comes out as -56 until
you mask it with `& 0xFF`.

Messages arrive in an event in the browser, or on another thread in Java. Store the bytes and draw
from them in `draw()`. Never draw inside the callback. You'll get away with it for a while, and then
you won't.

Python Mode reaches the JDK's MIDI classes through their interfaces, because the Java module system
hides them from Jython. That is the six-line `jcall` at the top of the Python sketch. Copy it.

Web MIDI wants a click before it hands out access, and SysEx is a second, separate permission. Only
the Launchpad needs that one.

## Raw or helpers?

Every device starter has a raw version too, under sixty lines each, decoding its own two or three
messages inline. Each [device page](/devices/) links to its own at the bottom. Here's how I'd
pick between the two, from the starters' README:

{/* include: starters/raw/README.md#Raw or helpers */}

{/* pulled from starters/raw/README.md by website/refresh.mjs; edit the source, not this */}

Start raw to see what is happening. HelloMidi logs each message as a status byte (what kind of message, which
channel) and two data bytes. Plug anything in and watch the numbers. A sketch that needs two or three
messages can decode them inline in a dozen lines.

Switch to `../../midi-helpers/` when the plumbing crowds out the idea. They do what these sketches do by hand
or skip: frame-synced `justPressed()`, callbacks by name, a config for a custom PipSqueak, a learned layout
for an odd Midi Fighter, RGB and text on the Launchpad, telling the accelerometer burst from touch pads,
keyboard stand-ins, click-to-connect in p5.

What the raw sketches show that the helpers hide:
- Java bytes are signed. `b[1] & 0xFF` turns -56 back into 200. p5's `Uint8Array` is already 0..255.
- Messages arrive on another thread (Java) or in an event (p5). Store the bytes, draw in `draw()`.
- Python Mode calls the JDK's MIDI classes through their interfaces (`jcall` in each sketch); the Java module
  system hides those classes from Jython. Six lines, copied into each sketch.
- Web MIDI needs a click first, and SysEx is a separate permission.
- The Launchpad is a different device until you send `F0 00 20 29 02 0D 0E 01 F7` (programmer mode). Send
  `...0E 00 F7` when you are done or it stays dark until replugged. The sketches do that in `dispose()`,
  `stop()` and on `pagehide`.

{/* /include */}
