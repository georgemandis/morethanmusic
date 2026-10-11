---
title: Troubleshooting
slug: /troubleshooting/
description: Everything learned the hard way. Browsers, Processing, Python Mode, each device, in the order you will hit them.
sidebar_position: 8
---

# Troubleshooting

In the order you are likely to hit them.

## Nothing happens

- Open [the Explorer](/the-explorer/). If the device is not listed, the computer does not see it:
  try another cable or port. If it is listed but silent, touch it and watch the log.
- The helper connects by a substring of the device name. The Explorer prints the exact name. Some
  PipSqueaks enumerate as `PipSqueaker`. A Launchpad Mini MK3 shows up as `LPMiniMK3 MIDI` and
  `LPMiniMK3 DAW`, and the helpers want the MIDI one.
- Every Processing sketch prints the MIDI devices it found in the console when `connect()` runs.
  Read that first.
- Four Midi Fighters at once? Identical names become `Midi Fighter Classic #1`, `#2` and so on. Pass
  the one you want.

## The browser

- Web MIDI needs a click first. Every p5 sketch waits for one on the canvas, and a status line under
  the canvas says what it found.
- Chrome asks once per site. The Launchpad sketches ask a second time, for SysEx, because the pad's
  colours are SysEx. Decline it and the Explorer still reads the pads; its Launchpad mode buttons go off.
- In the p5.js web editor the preview is an iframe. The first click has to land on the canvas, and
  the permission prompt appears in the bar at the top of the editor, not in the preview.
- Firefox 108 and later: the first MIDI request offers to install a site permission. Accept, reload.
- Safari has no Web MIDI, macOS or iOS, so neither do iPhones and iPads. Use [Processing](/pick-your-tool/processing-java/).
- Brave: if a device is missing, check the Shields panel for the site.
- Double-clicking a downloaded `index.html` works in Chrome. `file://` counts as a secure context there.
- On Windows one program at a time can hold a MIDI input. On macOS and Linux a browser tab and a
  Processing sketch usually share, but if one goes quiet, close the other.

## Processing, Java

- Plug in before Run. Java's own CoreMIDI provider on macOS lists devices once, when the JVM starts.
  A device plugged in later is invisible until you stop and run again. The Explorer carries
  `coremidi4j-1.6.jar` in its `code/` folder and calls it by reflection to get around this;
  `explorer/README.md` says how.
- A sketch that calls `fullScreen()` aborts with "API misuse: modification of a menu's items on a
  non-main thread" when launched from a run script or the command line on macOS 26 (seen with
  Processing 4.5.6). Start with `size()` and go fullscreen afterwards with
  `java.awt.GraphicsDevice.setFullScreenWindow` on the sketch's frame, or add `-XstartOnFirstThread`
  to the `java` command. From the IDE's Run button it has not been seen.
- `processing cli --run` opened no window on macOS with Processing 4.5.6: the sketch got a
  `PSurfaceNone` and drew nothing. `--build` works, so build with the CLI and launch the classes
  with Processing's bundled Java. `explorer/run.sh` shows how. The IDE's Run button is fine.
- A helper class you pass to `registerMethod()` must be `public class`. Processing calls it by
  reflection and a package-private inner class throws `IllegalAccessException`.
- Slow on a Retina display? Processing 4 defaults to `pixelDensity(2)` there, so a 1080p sketch
  renders 4K. `pixelDensity(1)` in `settings()` gives the frames back. `tint()` plus `image()` of a
  translucent, scaled `PGraphics` is a software scale too, and costly at 4K.
- Java bytes are signed. 200 comes out as -56 until you mask it with `& 0xFF`. The helpers do this.
- Messages arrive on Java's MIDI thread. Store the bytes and draw from them in `draw()`. Nothing
  that touches Processing belongs in the callback.
- Hot-plugging inside the helpers is not handled. Call `connect()` again; it rescans.

## Python Mode

- A Python sketch opens in Java mode and crashes the editor: it is missing `sketch.properties` with
  `mode=Python` and `mode.id=jycessing.mode.PythonMode` next to it. Processing 4 reads the mode from
  that file, not from the `.pyde` extension. Every sketch in the repo ships one.
- `InaccessibleObjectException` from a sketch that imports `javax.sound.midi` itself: put
  `from org.python.core import Options` and `Options.respectJavaAccessibility = True` before the
  import. Python Mode runs Jython with that switch off, and Java 17 then refuses the reflection. The
  helpers already set it.
- Calling `dev.open()` on a raw `MidiDevice` fails under Jython because the JDK hides its MIDI
  classes. Call through the interface's `Method` object instead. The six-line `jcall` in
  [the raw sketch](/examples/three-bytes-no-helpers/) does it.
- Python helpers have no per-frame hook, so state refreshes the first time you touch it in a frame.
  A sketch that only uses callbacks calls `helper.update()` at the top of `draw()`.
- Keyboard stand-ins in Python read one held key at a time.
- Jython is Python 2.7. No f-strings. Start every sketch with
  `from __future__ import division, print_function`.

## Devices

- Launchpad Mini MK3: two ports, MIDI and DAW. Use the MIDI port. The Explorer mutes the DAW port
  and puts the pad into Programmer mode so pad numbers match its picture, then restores Live mode on
  exit. Pad numbers in Programmer mode are `row*10+col`, 11 bottom left, 88 top right.
- Launchpad colours and text are SysEx. Browsers ask a separate permission for it. Processing never
  asks.
- Circuit Playground with the multi-tool firmware sends on channel 2 in the helpers' 1-based numbering,
  even though the firmware's comments say channel 1. The firmware does `0x90 | 1`. Modes 2, 3 and 4
  (light, sound, temperature) all send CC 1, so nothing can tell them apart from the messages. Mode 6
  sends three Note Ons every 200 ms with the note as the axis value plus 20 and never a Note Off,
  and notes 10, 11 and 13 overlap the cap-touch pads. Mode 7 (tap) sends nothing in the published
  firmware. Buttons and the slide switch change modes on the board and are not sent.
- Midi Fighter Classic banks are 0 to 3 in the helpers. The JS helper and DJ TechTools say 1 to 4.
- PipSqueak: the rest position is off-centre on purpose (around 60 and 68 rather than 64) and the
  helper calibrates for it. A unit set up with the [configurator](https://usemidi.com/configure.html)
  sends other numbers; pass a config. The stock map is CC 17, CC 20 and CC 25 for the button.
- PipSqueak LED: Note On 60 flashes it red for 200 ms. That is George's configuration, not a
  protocol fact.
- Trinkeys report `raw = -1` until the first message, so a sketch can tell "not moved yet" from "at
  zero". The Rotary Trinkey's switch polarity is read at power-up: do not hold the knob while
  plugging in. A board with no MIDI port needs `import usb_midi; usb_midi.enable()` in `boot.py`.
- Anything else: the Explorer's generic picture shows a note strip, one lane per CC seen, and bend
  and pressure bars. The log shows the raw bytes whatever the device.

## This site

- An embedded sketch asks for a click before it connects. Headless browsers and some privacy
  settings deny MIDI; the sketch then runs on its keyboard stand-in and says so.
- The URLs of the PCD 2026 workshop site (`/before-you-start/`, `/your-device/...`, `/hello-world/`)
  redirect to their new pages. A link from the 2026 deck that lands on a 404 is a bug: open an issue
  on the repo or write to George at [george.mand.is](https://george.mand.is).
