---
title: "The Explorer"
description: Lists every MIDI device and decodes every message live. A web page, and a Processing sketch for browsers without Web MIDI.
---

import LiveSketch from '@site/src/components/LiveSketch';

# The Explorer

The Explorer lists every MIDI device on your computer and decodes each message as it arrives. Open it
before you write anything, because it tells you the device's exact name and what each button and axis
sends. It's drawn big on purpose, so it reads from across a room.

## The web edition

Nothing to install. Open [/explorer](pathname:///explorer/web/) in a
[browser with Web MIDI](/pick-your-tool/p5/#a-browser-that-speaks-midi), press `c`, touch the device.
It is a full-page tool, so use that link for real work. The version below is a preview.

<LiveSketch src="/explorer/web/" title="MIDI Explorer, web edition" />

## The Processing edition

The same screen as a Processing 4 sketch, for Safari, phones, or any machine without Web MIDI. Get
the `explorer/MidiExplorer` folder, open `MidiExplorer.pde`, press Run:

- From the repo: [explorer/MidiExplorer on GitHub](https://github.com/georgemandis/morethanmusic.dev/tree/main/explorer/MidiExplorer),
  or clone the whole thing ([how](/pick-your-tool/processing-java/#get-the-sketches)).
- From this site, file by file: [MidiExplorer.pde](pathname:///explorer/MidiExplorer/MidiExplorer.pde)
  and the other tabs in that folder, plus `code/coremidi4j-1.6.jar` for hot-plugging.

For grid controllers there is also [grid-explorer.html](pathname:///grid-controllers/grid-explorer.html).
It draws the Midi Fighter or Launchpad as a grid and its "Learn layout" button records which note each
button sends.

From its README:

{/* include: explorer/web/README.md */}

{/* pulled from explorer/web/README.md by website/refresh.mjs; edit the source, not this */}

## MIDI Explorer, web edition

The browser twin of `explorer/MidiExplorer`. One HTML file, one p5.js sketch, raw Web MIDI, no
bundler, nothing to install. Open it in Chrome, Edge or Opera on any machine, or Firefox 108 and later
after it asks to install a site permission. Safari has no Web MIDI and gets a message saying so.

Same screen as the Processing edition. Inputs, outputs and the send panel on the left. Pictures
over the log on the right. Dark, big type, readable from the back row.

### Open it

- From the live site: `/explorer/web/`.
- From the repo over http: any static server, say `python3 -m http.server` in the repo root, then
  `http://localhost:8000/explorer/web/`.
- By double-clicking `index.html`. Chrome allows Web MIDI on `file://`. p5 loads from a CDN and
  falls back to `vendor/p5.min.js`, so it works offline.

Click Connect MIDI, or press `c`. Chrome asks once for MIDI with SysEx. Decline SysEx and the page
retries without it. The Launchpad mode buttons are then off. Devices plugged in later appear on
their own.

Bookmark `index.html?connect=1` for the projector. It connects on load, no click.

### What you get

Everything the Processing edition does, same keys:

| Key | Does |
|---|---|
| `c` | connect to MIDI |
| `1`–`9` | show only input N (again, or `0`, for all). A blue banner over the pictures and the log says so |
| `shift`+`1`–`9` | mute or unmute input N (also the mute button on each row) |
| `o` | next send target |
| `s` | pause the log |
| `backspace` | clear the log and reset every picture |
| `=` / `-` | bigger or smaller text |
| `enter` | tap the panel's note, or send the CC |

Channel, number and value in the send panel are numbers you click and type into. Enter applies,
up and down step, shift steps 10. Below them a preset for the selected output: Launchpad palette
strip with Programmer, Live and Clear; Midi Fighter LED grid; Circuit Playground hue bar (mode-10
colour triplet) and one-octave keyboard (mode 8); PipSqueak flash LED; Trinkey light pixel. The
Launchpad shows as (MIDI port) and (DAW port). The DAW port starts muted, the MIDI port becomes the
send target, and the pad is set to Programmer mode on discovery. Live mode comes back when you leave.

Fake device for testing, `?fake=N`, no key: `a`–`p` cells, arrows stick, space button, `[` `]`
slider, knob or CC 1, `x` accelerometer burst.

Pictures by device name: Launchpad Mini MK3 (9×9, programmer numbering), Midi Fighter Classic (4×4,
detects Four Banks Internal), PipSqueak (stick, raw and normalized values, button), Circuit
Playground (pads, CC 1 sensor lane, accelerometer from notes 10–30, note strip), Slide and Rotary
Trinkey, and a note strip plus CC lanes for anything else. Clicking a cell sends that note to the
device's output, press for on, release for off.

### URL options

| Parameter | Effect |
|---|---|
| `?connect=1` | connect without the click |
| `?fake=N` | start with fake device N (1 Launchpad to 7 Rotary Trinkey) |
| `?demo=1` | send the fake device a burst |
| `?x=17&y=20&button=25` | PipSqueak controller numbers for a stock unit. `buttonnote=60` for a note button. `xcenter`, `ycenter`, `yinvert` too |

The defaults are George's PipSqueaker: CC 10 is x, CC 7 is y, button is Note 60, same as
`../MidiExplorer/data/pipsqueak-config.json`. A stock PipSqueak needs `?x=17&y=20&button=25`.

### How it is built

`sketch.js` is a port of the Processing tabs. `MidiMsg` decodes bytes. `MidiIO` wraps
`navigator.requestMIDIAccess` and keeps `InputPort` and `OutputPort` lists keyed by `name #n` so
identical units stay apart. The `Picture` classes draw the devices. `SendPanel` and `MessageLog`
draw the sidebar and the log. `FakeDevice` turns keys into messages on the same queue. Incoming
messages are queued in `onmidimessage` and drained once per frame so a flood cannot stall drawing.
Buttons register a `Hit` rectangle every frame. `mousePressed` walks the list.

The midi-helpers p5 bundle is not used. The listing and logging had to be raw Web MIDI to work with
any device, and the pictures already existed in Java.

### Verified

Headless Chrome 154 on macOS, `file://` and `http://`: clean console, the connect state, the no-MIDI
paths, every fake picture with the demo burst. Headless Chrome denies MIDI permission, so the
real-device path is checked in a normal Chrome window. See `../HARDWARE-CHECKLIST.md`, section 8.

### Assumptions

1. p5 fonts. p5 1.x quotes a font name with spaces or commas, so a CSS font stack is rejected and
   the browser falls back to serif. The sketch uses the generic `monospace` and `sans-serif`
   families: Menlo and Helvetica on macOS, Consolas and Segoe UI on Windows.
2. SysEx permission. The page asks for SysEx so it can switch a Launchpad into Programmer mode. If
   a user declines, everything else works.
3. PipSqueak config lives in the URL, not a JSON file. A page opened from `file://` cannot read a
   sibling file without a fetch some browsers block.
4. Nothing is stored. No localStorage. Mute and filter state is never restored.

{/* /include */}

## From the Explorer's own README

{/* include: explorer/README.md */}

{/* pulled from explorer/README.md by website/refresh.mjs; edit the source, not this */}

## MIDI Explorer (Processing)

See what your controller sends. Send something back.

A Processing 4 sketch. It lists every MIDI input and output, decodes each message into a log,
draws the device when it knows the name, and has a send panel for LEDs. It is the "what is this
thing actually sending" tool for the workshop, and the thing on the projector at show and tell.

Nothing to install. It uses `javax.sound.midi`, which ships with Processing's Java, plus one jar in
`MidiExplorer/code/` (CoreMidi4J, Apache-2.0) so devices plugged in after Run show up. Plain
Processing sketches without that jar only see devices connected before you pressed Run. Java's
CoreMIDI provider lists them once and never again. That applies to every other sketch in this
workshop: plug in first, then Run.

Layout: header with device count and message rate. Left: inputs, outputs, send panel. Right:
device pictures over the log.

### Open it

1. Install [Processing 4](https://processing.org/download). Tested with 4.5.6.
2. Open `explorer/MidiExplorer/MidiExplorer.pde`. The other tabs load with it.
3. Run. With CoreMidi4J the device list refreshes every three seconds. Without the jar, `r`
   relaunches the sketch in place, same window, log kept.

From a terminal, with Processing.app in `/Applications`:

```sh
explorer/run.sh                                   # build with the Processing CLI, run with its Java
explorer/run.sh --fake=2 --demo                   # a fake Midi Fighter and a burst of messages
explorer/run.sh --fake=1 --demo --shot=/tmp/lp.png   # screenshot after two seconds, then quit
```

`--fake=N` picks the fake device (1 Launchpad, 2 Midi Fighter, 3 PipSqueak, 4 Circuit Playground,
5 generic, 6 Slide Trinkey, 7 Rotary Trinkey). `--demo` sends it a burst. `--shot=path` saves the
window and exits. Command line only. The IDE's Run button starts normally.

### What you see

Header: inputs, outputs, messages per second. With nothing connected it says NO MIDI DEVICES in
red.

Inputs: every MIDI input, all listened to. Green dot while listening, yellow flash on a message.
Click a row, or press 1 to 9, to see only that device. A blue banner across the pictures and the
log says so. Click again, press 0, or hit the all button, for everything. The mute button hides a
device without closing it. Its row then reads "muted · click to listen" in red. Nothing is saved
between runs. If the log is empty while a muted or filtered-out device is sending, a yellow line
at the bottom of the log names it.

Outputs: every MIDI output. Click one to make it the send target.

Pictures, one per listening input, picked by the device's USB name:

| Name contains | Picture |
|---|---|
| `LPMiniMK3 MIDI` or `Launchpad` (not `DAW`) | 9×9 Launchpad grid, programmer numbering: pads are notes `row*10+col` (11 bottom-left, 88 top-right), top row CC 91–98, right column CC 19–89, logo CC 99. The pad shows up as two inputs, Launchpad Mini MK3 (MIDI port) and (DAW port). The DAW port starts muted. The MIDI port becomes the send target. On discovery the sketch puts the pad into Programmer mode so pads match the picture, with a one-line notice. Live mode comes back on quit |
| `Fighter` | 4×4 Midi Fighter Classic grid. Starts in Default mode (notes 36–51, 48 top-left). Switches to Four Banks Internal when it sees a bank-select note 0–3 |
| `PipSqueak`, `useMIDI`, `MidiBaby` | stick field with the dot where the stick is, raw and normalized values, angle, magnitude, button. Any other CC is listed underneath |
| `Circuit`, `Playground`, `CPX`, `CPlay` | the round board with eight cap-touch pads, a sensor lane for CC 1, accelerometer bars decoded from notes 10–30, a note strip |
| `Slide Trinkey` | a slider (CC 1), a touch pad (note 60), a light pixel button |
| `Rotary Trinkey` | a knob (CC 2), a press ring (note 61), a click counter (CC 3), a touch pad (note 62), a light pixel button |
| anything else | a 128-slot note strip, one lane per CC seen, bend and pressure bars |

Clicking a cell in a picture sends that message. For real hardware it goes to the output with the
same name, so clicking a Launchpad pad or Midi Fighter button on screen lights that LED. For the
fake device it comes in as input.

Log: every message, newest at the bottom. Wall-clock time, device, channel (1–16), type, note or CC
with names, value, then the raw bytes twice: decimal as status, data 1, data 2, and the same in
hex. That is the whole protocol, three numbers. Messages you send are cyan with an arrow. Mouse
wheel scrolls back. `s` pauses.

Send panel: pick an output, Note or CC. Channel, number and value are numbers you click and type
into. Enter applies, Esc cancels, up and down step, shift steps 10, Tab moves on. The − and +
buttons step by one, shift-click by 10. The note name sits next to the number. Note On leaves the
LED lit, Note Off clears it, Tap (or Enter) does on then off. Below that, a preset for the selected
output. Launchpad: Programmer, Live, Clear and a palette strip. Pick a colour, then click pads in
the picture to paint them. Midi Fighter: a 4×4 LED toggle grid plus all on and all off. Circuit
Playground: a hue bar that sends the mode-10 colour triplet (Note On on channels 1, 2, 3 for red,
green, blue, note plus velocity) and a one-octave keyboard for mode 8. PipSqueak: flash LED.
Trinkeys: light pixel. Anything else: Panic (CC 123 and CC 120).

### Keys

| Key | Does |
|---|---|
| `1`–`9` | show only input N (again, or `0`, for all) |
| `shift`+`1`–`9` | mute or unmute input N (also the mute button on each row) |
| `0` | show all devices |
| `r` | rescan now. Without CoreMidi4J: relaunch in place |
| `o` | next send target |
| `s` | pause the log |
| `backspace` | clear the log and reset every picture (also the clear button on the log) |
| `=` / `-` | bigger or smaller text. Use it on the projector |
| `enter` | tap the panel's note, or send the CC |

### Testing with no hardware

No key for the fake device. From a terminal: `explorer/run.sh --fake=N --demo`. Then `a`–`p` press
cells, arrows push the stick, space is the stick button, `[` `]` move the slider, knob or CC 1,
`x` fires an accelerometer burst. Click or drag the picture. Everything after the device (queue,
decoder, pictures, log) is the same code real devices use. The fake shows up in Inputs marked
`(fake)`.

### PipSqueak configuration

`MidiExplorer/data/pipsqueak-config.json` describes George's PipSqueaker (firmware 2.7.0-beta.3):
stick on CC 10 (x) and CC 7 (y), rest near 67 and 70, button is Note 60. The sketch loads it at
startup and the picture's subtitle names the file. For a stock unit (x CC 17, y CC 20, button CC 25,
as in `pipsqueak/pipsqueak_py/pipsqueak.py`) copy `pipsqueak-config.example.json` over it. The
button is a CC (`{"cc": 25, "threshold": 64}`) or a note (`{"note": 60}`).

The unit flashes its LED red for 200 ms on Note On 60, so the PipSqueak picture has a flash LED
button that sends note 60 to its own output. The Trinkey pictures have the same kind of light pixel
button, note 60 for the slide, 61 for the rotary.

Launched outside the IDE, `data/` resolves from the working directory. `run.sh` changes into the
sketch folder first for that reason.

### How it is built

`MidiIO.pde` lists devices (CoreMidi4J by reflection, else `MidiSystem.getMidiDeviceInfo()`),
treats anything with transmitters as an input and anything with receivers as an output, and hides
Java's two software devices. Messages arrive on Java's MIDI thread, so a `Receiver` only queues the
bytes. `draw()` drains them. Identical names (four Midi Fighters) become `Midi Fighter Classic #1`,
`#2`, and so on.

`Decode.pde` is the whole protocol in one class: status nibble to type, low nibble to channel.

`Pictures.pde` has one class per device plus two shared widgets, `NoteStrip` and `CCLanes`.

`Panels.pde` draws the sidebar, send panel and log. Buttons register a `Hit` rectangle every
frame. `mousePressed()` walks the list. No GUI library.

`FakeDevice.pde` turns keys and mouse into messages on the same queue.

On exit every port is closed. A Launchpad we put in Programmer mode goes back to Live mode.

`grid-controllers/grid-explorer.html` stays as the Chrome explorer for the grid controllers. This
is not a rewrite of it. The device maps are the same.

### Seen on real hardware (2026-10-02 and 03, George's desk)

| Device | Name Java reports | What it sent |
|---|---|---|
| PipSqueak | `PipSqueaker` | CC 10 (x) and CC 7 (y) on channel 1, button Note 60. Not the stock map. `data/pipsqueak-config.json` describes it |
| Circuit Playground | `Circuit Playground` | mode 5: random Note On on channel 2 at about 16 a second. The firmware's channel byte is 1, which is channel 2 in this sketch's 1-based numbering |
| Slide Trinkey | `Slide Trinkey M0` | George's firmware: slider CC 1, touch pad Note 60, channel 1 |
| Rotary Trinkey | `Rotary Trinkey M0` | knob CC 2 absolute, CC 3 relative (1 cw, 127 ccw), press Note 61, touch Note 62, channel 1 |
| Midi Fighter Classic | `Midi Fighter Classic` | found and drawn. Not pressed yet |
| Launchpad Mini MK3 | `LPMiniMK3 MIDI Out` / `LPMiniMK3 DAW Out` (inputs), `… In` (outputs). With CoreMidi4J the device name comes first | found once. Not tested |

Hot-plug, mute, filter, clear and the presets were exercised with these ports open and no errors.
Nothing has lit an LED yet. See `HARDWARE-CHECKLIST.md`.

### Assumptions

Things decided with nobody around to ask. Fix them in the hardware checklist pass.

1. Device names on macOS. Java reports the CoreMIDI port name. Matching is by substring
   (`LPMiniMK3`, `Fighter`, `PipSqueak`, `Circuit`, `Playground`, `Slide Trinkey`, `Rotary
   Trinkey`). The Launchpad's DAW port is named and muted on purpose. An unknown name gets the
   generic picture. The log works regardless.
2. Circuit Playground channel. The multi-tool firmware does `0x90 | 1`, so its messages arrive on
   channel 2 in the 1-based numbering shown here, even though the firmware comments say channel 1.
3. Circuit Playground modes. Modes 2, 3 and 4 (light, sound, temperature) all send CC 1, so the
   sketch shows one sensor lane and cannot tell which mode the board is in. Mode 6 sends three Note
   Ons every 200 ms with note = `round(axis + 20)` and never a Note Off. The picture reads notes
   10–30 with velocity 127 as x, y, z in arrival order. Those overlap cap-touch notes 10, 11 and
   13. Mode 7 (tap) sends nothing in the published firmware. Buttons and the slide switch are not
   sent. They change modes on the device.
4. Midi Fighter channel. The picture takes notes on any channel and remembers the last one it saw
   (default 3) for LED sends.
5. Launchpad numbering is Programmer mode. Live mode numbers pads per layout, so the sketch
   switches the pad to Programmer mode when it finds the output.
6. Hot-plug. Java's own CoreMIDI provider never refreshes after JVM start. Confirmed on this Mac.
   `MidiExplorer/code/coremidi4j-1.6.jar` fixes it. The sketch calls it by reflection so it still
   compiles without the jar, and then `r` relaunches instead. The footer says which mode you are in.
7. Fonts. Menlo for the log (then Monaco, Consolas, Monospaced) and Helvetica Neue for titles. Text
   scales with `=` and `-`. Defaults are tuned for 1600×1000 on a projector.
8. `processing cli --run` opened no window on this Mac (Processing 4.5.6). The sketch got a
   `PSurfaceNone` and drew nothing. `--build` works, so `run.sh` compiles with the CLI and launches
   the classes with Processing's bundled Java 17. The IDE's Run button is fine.
9. `registerMethod("dispose", …)` needs a `public` inner class. Processing calls it by reflection
   and fails with `IllegalAccessException` on a package-private class. `MidiIO` is `public class`.
10. No midi-helpers dependency. `midi-helpers/java/MidiCore.pde` did not exist when this was
    written, so the sketch has its own MIDI layer in `MidiIO.pde`.
11. Launchpad palette colours in the send panel are rough. Greys 0–3, then fourteen hues in four
    shades. The index sent is exact, the swatch is not. Clicking a pad sends on channel 1 (static
    colour) whatever the channel field says.
12. The fake device has no output. The send panel cannot target it.

### Status

Compiles with `processing cli --build` (Processing 4.5.6, Java 17). Runs with no devices connected
and shows the empty state. Self-test screenshots (`run.sh --fake=N --demo --shot=…`) checked for
every picture and the empty state. No exceptions on start or exit. Real-hardware checks are in
`HARDWARE-CHECKLIST.md`.

{/* /include */}
