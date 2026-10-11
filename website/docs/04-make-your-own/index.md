---
title: Make your own
description: Turn a board into a MIDI device. Read a sensor, send three bytes, show up without a driver.
---

# Make your own

Every device on this site does the same thing. It reads something, a slider, a pad, a tilt, and sends
three bytes over USB or Bluetooth. The computer sees a MIDI device and asks no questions. You can do
this with a board you already own, in an afternoon.

## Pick a board

It needs native USB (the USB controller is in the chip) or Bluetooth. That rules out an Uno or a Nano
and rules in most of what Adafruit and Arduino sell now.

| Board | Language | What it became | Page |
|---|---|---|---|
| Circuit Playground Classic or Express | Arduino, MIDIUSB library | ten-mode controller: touch, light, sound, temperature, tilt, speaker, colour mixer | [Circuit Playground](./01-circuit-playground.md) |
| Slide Trinkey, Rotary Trinkey | CircuitPython, built-in `usb_midi` | a slider and a knob, with a touch pad each, pixel talks back | [Trinkeys](./02-trinkeys.md) |
| Puck.js | Espruino JavaScript, `ble_midi` module | a Bluetooth clicker: one button, counted clicks | [Puck.js](./03-puck-js.md) |
| Leonardo, Micro, any 32u4 or SAMD board | Arduino, MIDIUSB library | the starter: one button, one knob, one LED | [Arduino MIDIUSB](./04-arduino-midiusb.md) |

The code for each is in the `firmware/` folder of this site's repo, laid out as a repo of its own with
a README, flash steps and a licence.

## Read sensors

Read in a loop. Scale the reading to 0..127: a 10-bit analog read shifted right by 3, a 16-bit one by
9. Send when the value changes, not every time round the loop, or the sketch on the other end drowns
in identical messages. A little hysteresis on a noisy pot (ignore changes of one) saves a lot of
traffic. Send the current state once at startup so a sketch that opens the device later starts in
sync.

## Send three bytes

A MIDI message is a status byte and two data bytes.

| Message | Status | Data 1 | Data 2 |
|---|---|---|---|
| note on | `0x90` + channel | note 0..127 | velocity 1..127 |
| note off | `0x80` + channel | note | 0 |
| control change | `0xB0` + channel | controller 0..127 | value 0..127 |

The channel on the wire is zero-based: `0x90` is channel 1 as the Explorer shows it, `0x91` channel 2.
Data bytes stay under 128; the top bit means status. Buttons and pads are notes. Anything continuous
is a CC. A press without a release is a stuck note, so send the off.

In each language:

```cpp title="Arduino, MIDIUSB"
midiEventPacket_t p = {0x0B, 0xB0 | (channel - 1), controller, value};   // the first byte is USB-MIDI's header
MidiUSB.sendMIDI(p);
MidiUSB.flush();
```

```python title="CircuitPython"
usb_midi.ports[1].write(bytes([0xB0 | (channel - 1), controller, value]))
```

```javascript title="Espruino"
require("ble_midi").send(channel - 1, controller, value);
```

## Be class-compliant

Nothing to install on the computer. USB MIDI is a device class, like keyboards and storage, and the
operating system has had the driver since 1999. The MIDIUSB library, CircuitPython's `usb_midi` and
Espruino's `ble_midi` all speak it. [Why it shows up without a driver](./05-why-no-driver.md) has the
detail, including how to change the name the Explorer shows.

## Write it down

Put the message map in the README as a table: what, status, bytes. Put the numbers in constants at the
top of the code with a `change this` comment. Every folder in `firmware/` does this, and every device
page on this site was written from one of those tables.
