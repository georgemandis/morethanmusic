---
title: Trinkeys
description: CircuitPython firmware for the Slide and Rotary Trinkey. Fifty lines each, no library.
---

# Slide and Rotary Trinkey

Adafruit's Trinkeys are a USB plug with one control on it. The Slide has a slider and a touch pad. The
Rotary has a knob you can also press, and a touch pad. Each runs fifty lines of CircuitPython and shows
up as a MIDI device named `Slide Trinkey M0` or `Rotary Trinkey M0`.

Source: [github.com/georgemandis/trinkey-midi](https://github.com/georgemandis/trinkey-midi).

Source: `firmware/trinkey-midi/` in this site's repo. Device pages: [Slide Trinkey](/devices/slide-trinkey/)
and [Rotary Trinkey](/devices/rotary-trinkey/).

## What they send

Channel 1. One CC with the position at startup.

| Board | Sends | Bytes |
|---|---|---|
| Slide | slider CC 1, 0 left to 127 right | `B0 01 vv` |
| Slide | touch pad note 60 | `90 3C 7F`, `80 3C 00` |
| Rotary | knob CC 2, absolute 0..127 | `B0 02 vv` |
| Rotary | knob CC 3, relative: 1 per click clockwise, 127 counter-clockwise | `B0 03 01`, `B0 03 7F` |
| Rotary | knob press note 61 | `90 3D 7F`, `80 3D 00` |
| Rotary | touch pad note 62 | `90 3E 7F`, `80 3E 00` |

Both listen. A note on sets the pixel colour from the note number for a second, so a sketch can answer.

## Why CircuitPython

No toolchain. The board is a USB drive, the code is a text file on it, saving the file restarts the
board. `usb_midi` is built in, so the whole MIDI side is one line:

```python
midi_out.write(bytes([0xB0 | (CHANNEL - 1), CC_SLIDER, v]))
```

`boot.py` renames the drive so two Trinkeys on one Mac are not both `CIRCUITPY`.

## Flash

1. Double-tap reset. A `TRINKEYBOOT` drive appears.
2. Copy the board's CircuitPython UF2 onto it with `cp -X` (Finder fails on the tiny FAT volume).
   `CIRCUITPY` appears.
3. Copy `boot.py` and `code.py` from the board's folder to the drive. Replug once.

The README in `firmware/trinkey-midi/` has the download links, the exact `cp` lines and a 30-line
CoreMIDI monitor for checking the bytes from the terminal.

## The code

### Slide Trinkey, `slide-trinkey/code.py`

{/* include: firmware/trinkey-midi/slide-trinkey/code.py */}

```python title="code.py"
# Slide Trinkey M0 as a MIDI controller. CircuitPython, no libraries: usb_midi sends the raw bytes.
#
#   slider      -> Control Change CC 1, 0 (left) .. 127 (right), sent when it moves
#   touch pad   -> Note 60 on while touched, note off on release
#   pixels      -> the slider position as a colour; an incoming note on sets the colour from the
#                  note number for a second, so a sketch can talk back
#   at startup  -> one CC 1 with the current position, so sketches start in sync
#
# The device appears as "Slide Trinkey M0" on the MIDI inputs and outputs.
import time
import board, analogio, touchio, digitalio, usb_midi, neopixel_write

CHANNEL = 1        # change this: 1..16
CC_SLIDER = 1      # change this: the control number the slider sends
NOTE_TOUCH = 60    # change this: the note the touch pad sends

midi_out = usb_midi.ports[1]
midi_in = usb_midi.ports[0]
pot = analogio.AnalogIn(board.POTENTIOMETER)
touch = touchio.TouchIn(board.TOUCH)
pixel_pin = digitalio.DigitalInOut(board.NEOPIXEL)
pixel_pin.direction = digitalio.Direction.OUTPUT
PIXELS = 2


def send(status, d1, d2):
    midi_out.write(bytes([status | (CHANNEL - 1), d1, d2]))


def hue(v):
    """0..127 -> (r, g, b): blue at the left, through green, to red at the right."""
    p = v / 127.0
    if p < 0.5:
        t = p * 2
        return 0, int(200 * t), int(200 * (1 - t))
    t = (p - 0.5) * 2
    return int(200 * t), int(200 * (1 - t)), 0


def show(r, g, b):
    neopixel_write.neopixel_write(pixel_pin, bytearray([g, r, b] * PIXELS))


def read_slider():
    total = 0
    for _ in range(8):
        total += pot.value
    return (total // 8) >> 9          # 16-bit reading to 0..127


last = read_slider()
send(0xB0, CC_SLIDER, last)
touched = False
override_until = 0
override = (0, 0, 0)

while True:
    now = time.monotonic()

    v = read_slider()
    if abs(v - last) >= 2 or (v in (0, 127) and v != last):   # hysteresis for pot noise
        last = v
        send(0xB0, CC_SLIDER, v)

    if touch.value != touched:
        touched = touch.value
        if touched:
            send(0x90, NOTE_TOUCH, 127)
        else:
            send(0x80, NOTE_TOUCH, 0)

    msg = midi_in.read(3)
    if msg and len(msg) == 3 and (msg[0] & 0xF0) == 0x90 and msg[2] > 0:
        r, g, b = hue(msg[1])
        k = msg[2] / 127.0
        override = (int(r * k), int(g * k), int(b * k))
        override_until = now + 1.0

    if now < override_until:
        show(*override)
    elif touched:
        show(255, 255, 255)
    else:
        show(*hue(last))

    time.sleep(0.005)
```

{/* /include */}

### Rotary Trinkey, `rotary-trinkey/code.py`

{/* include: firmware/trinkey-midi/rotary-trinkey/code.py */}

```python title="code.py"
# Rotary Trinkey M0 as a MIDI controller. CircuitPython, no libraries: usb_midi sends the raw bytes.
#
#   turn the knob   -> CC 2 = absolute position 0..127 (starts at 64, stops at the ends)
#                      CC 3 = relative: 1 per click clockwise, 127 per click counter-clockwise
#   press the knob  -> Note 61 on / off
#   touch pad       -> Note 62 on / off
#   pixel           -> colour follows the position; white while pressed; an incoming note on
#                      sets the colour from the note number for a second
#   at startup      -> one CC 2 with the starting position
#
# The device appears as "Rotary Trinkey M0" on the MIDI inputs and outputs.
import time
import board, rotaryio, digitalio, touchio, usb_midi, neopixel_write

CHANNEL = 1          # change this: 1..16
CC_POSITION = 2      # change this
CC_RELATIVE = 3      # change this
NOTE_BUTTON = 61     # change this
NOTE_TOUCH = 62      # change this
STEP = 1             # change this: how far one click moves the position (try 4 for a coarse knob)

midi_out = usb_midi.ports[1]
midi_in = usb_midi.ports[0]
encoder = rotaryio.IncrementalEncoder(board.ROTA, board.ROTB)
switch = digitalio.DigitalInOut(board.SWITCH)
switch.switch_to_input(pull=digitalio.Pull.DOWN)
switch_rest = switch.value           # whatever it reads at startup is "released"
touch = touchio.TouchIn(board.TOUCH)
pixel_pin = digitalio.DigitalInOut(board.NEOPIXEL)
pixel_pin.direction = digitalio.Direction.OUTPUT


def send(status, d1, d2):
    midi_out.write(bytes([status | (CHANNEL - 1), d1, d2]))


def hue(v):
    """0..127 -> (r, g, b) around the colour wheel."""
    h = (v / 128.0) * 6
    i = int(h) % 6
    f = h - int(h)
    q, t = int(200 * (1 - f)), int(200 * f)
    return [(200, t, 0), (q, 200, 0), (0, 200, t), (0, q, 200), (t, 0, 200), (200, 0, q)][i]


def show(r, g, b):
    neopixel_write.neopixel_write(pixel_pin, bytearray([g, r, b]))


position = 64
last_encoder = encoder.position
send(0xB0, CC_POSITION, position)
pressed = False
touched = False
override_until = 0
override = (0, 0, 0)

while True:
    now = time.monotonic()

    e = encoder.position
    if e != last_encoder:
        delta = e - last_encoder
        last_encoder = e
        for _ in range(abs(delta)):
            send(0xB0, CC_RELATIVE, 1 if delta > 0 else 127)
        new = max(0, min(127, position + delta * STEP))
        if new != position:
            position = new
            send(0xB0, CC_POSITION, position)

    p = switch.value != switch_rest
    if p != pressed:
        pressed = p
        send(0x90 if pressed else 0x80, NOTE_BUTTON, 127 if pressed else 0)

    if touch.value != touched:
        touched = touch.value
        send(0x90 if touched else 0x80, NOTE_TOUCH, 127 if touched else 0)

    msg = midi_in.read(3)
    if msg and len(msg) == 3 and (msg[0] & 0xF0) == 0x90 and msg[2] > 0:
        r, g, b = hue(msg[1])
        k = msg[2] / 127.0
        override = (int(r * k), int(g * k), int(b * k))
        override_until = now + 1.0

    if now < override_until:
        show(*override)
    elif pressed or touched:
        show(255, 255, 255)
    else:
        show(*hue(position))

    time.sleep(0.002)
```

{/* /include */}
