---
name: Rotary Trinkey
description: Adafruit's USB stick with a click knob, a push switch, a touch pad and one pixel. Two CCs, two notes, George's CircuitPython on it.
order: 6
maker: Adafruit, with George's firmware
usb_name: '"Rotary Trinkey M0"'
ports: 1 in, 1 out
sends: CC 2 absolute and CC 3 relative for the knob, note 61 for the press, note 62 for the touch pad, channel 1.
receives: Any note on. The pixel takes that note's colour for a second.
buy: https://www.adafruit.com/product/4964
photo: none
firmware: "[firmware/trinkey-midi](pathname:///firmware/trinkey-midi/README.md), CircuitPython"
helper: Trinkeys
starters:
  p5: starters/p5/anything-else
  python: starters/python/anymidi_starter/anymidi_starter.pyde
  java: starters/java/AnyMidiStarter/AnyMidiStarter.pde
starter_notes:
  p5: This is the generic starter. It draws every note and CC the knob sends.
  python: The generic starter. It runs as is. For the helper, copy `trinkeys.py` from `midi-helpers/python/` next to it.
  java: The generic starter. It runs as is. For the helper, copy `Trinkeys.pde` from `midi-helpers/java/` into the sketch folder.
raw:
  java: starters/raw/java/HelloMidi/HelloMidi.pde
  python: starters/raw/python/hello_midi/hello_midi.pyde
  p5: starters/raw/p5/hello-midi
---

A USB stick with a rotary encoder you solder on yourself, a push switch under the knob, a capacitive
touch pad and one NeoPixel. George's CircuitPython firmware makes it a class-compliant MIDI device: no
driver, no library on either end. The knob sends two things at once, an absolute position and a
relative click, so a sketch can pick whichever is easier.

<!-- facts -->

<!-- map -->

Everything is on channel 1. The board sends one CC 2 with the knob's position at startup. Whatever the
switch reads at power-up counts as released, so don't hold it while plugging in. Flashing and the pin
names are in the [trinkey-midi README](pathname:///firmware/trinkey-midi/README.md).

## Start here

There is no dedicated starter yet. The generic one draws every note and CC it hears, so turn the knob
and watch CC 2 and CC 3. Then use the helper below.

<!-- starters -->

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

<!-- helper -->

## Try first

- A dial on screen that follows `value`. Then one that only ever moves by `delta`, so it never jumps.
- Scroll through a list of colours, press to pick one, send it back to the pixel.
- A metronome whose tempo is the knob.

More on the [ideas page](@ideas#trinkeys-neotrellis-m4-and-the-things-people-brought).

## Without the helper

Two CCs and two notes, so the raw path is HelloMidi: it opens every input and prints every message. Read
[the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
