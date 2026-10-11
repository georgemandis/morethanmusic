---
name: Slide Trinkey
description: Adafruit's USB stick with a slider, a touch pad and two pixels. One CC, one note, George's CircuitPython on it.
order: 5
maker: Adafruit, with George's firmware
usb_name: '"Slide Trinkey M0"'
ports: 1 in, 1 out
sends: CC 1 for the slider, note 60 for the touch pad, channel 1.
receives: Any note on. The pixels take that note's colour for a second.
buy: https://www.adafruit.com/product/5021
photo: none
firmware: "[firmware/trinkey-midi](pathname:///firmware/trinkey-midi/README.md), CircuitPython"
helper: Trinkeys
starters:
  p5: starters/p5/anything-else
  python: starters/python/anymidi_starter/anymidi_starter.pyde
  java: starters/java/AnyMidiStarter/AnyMidiStarter.pde
starter_notes:
  p5: This is the generic starter. It draws every note and CC the stick sends.
  python: The generic starter. It runs as is. For the helper, copy `trinkeys.py` from `midi-helpers/python/` next to it.
  java: The generic starter. It runs as is. For the helper, copy `Trinkeys.pde` from `midi-helpers/java/` into the sketch folder.
raw:
  java: starters/raw/java/HelloMidi/HelloMidi.pde
  python: starters/raw/python/hello_midi/hello_midi.pyde
  p5: starters/raw/p5/hello-midi
---

A USB stick with a slide potentiometer, a capacitive touch pad and two NeoPixels. It plugs straight
into a USB-A port. George's CircuitPython firmware makes it a class-compliant MIDI device: no driver,
no library on either end. One slider, one touch pad, that's it, which makes it a good first device.

<!-- facts -->

<!-- map -->

Everything is on channel 1. The board sends one CC 1 with the slider's position at startup, so a sketch
starts in sync. Flashing and the pin names are in the [trinkey-midi README](pathname:///firmware/trinkey-midi/README.md).

## Start here

There is no dedicated starter yet. The generic one draws every note and CC it hears, so move the slider
and watch CC 1 move. Then use the helper below.

<!-- starters -->

## The helper

| | |
|---|---|
| `new SlideTrinkey(this)` | Connects to the first device whose name contains "Slide Trinkey". `(this, "name")` to change it. |
| `slide.value` | 0 to 1, 0 at the left. |
| `slide.raw` | The CC value 0 to 127, or -1 before the first message. |
| `slide.touched`, `slide.justTouched()`, `slide.justReleased()` | The touch pad. The "just" ones are true for one frame. |
| `slide.pixel(note)` | Sends a note on and off to the board. The pixels show that note's colour for a second. |
| `void sliderChanged(float value)`, `void touchPressed()`, `void touchReleased()` | Define any in your sketch and the helper calls it. |

Stand-ins with nothing plugged in: LEFT and RIGHT move the slider, `T` touches.

<!-- helper -->

## Try first

- One number on screen, huge. Then a colour. Then a speed.
- A horizontal position. The slider is a crossfader.
- Touch to send a note back and watch the pixels answer.

More on the [ideas page](@ideas#trinkeys-neotrellis-m4-and-the-things-people-brought).

## Without the helper

One CC and one note, so the raw path is HelloMidi: it opens every input and prints every message. Read
[the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
