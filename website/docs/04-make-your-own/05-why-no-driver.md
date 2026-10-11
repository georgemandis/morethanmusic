---
title: Why it shows up without a driver
description: USB device classes, the MIDI one from 1999, the four-byte packet, and the name the Explorer shows.
---

# Why it shows up without a driver

Plug in a Trinkey running the code on these pages and macOS, Windows and Linux all list a MIDI device
within a second. No installer, no reboot, no vendor website. Keyboards and USB sticks get the same
treatment. Here is why.

## Device classes

USB devices describe themselves when they enumerate. Part of that description is a class code. Class 3
is a human interface device, which is why any keyboard works. Class 8 is mass storage. Class 1 is
audio, and inside it subclass 3 is MIDI Streaming. The spec for that is the
[USB Device Class Definition for MIDI Devices](https://www.usb.org/sites/default/files/midi10.pdf),
version 1.0, dated November 1999. It has not needed a version 2 for USB MIDI 1.0 traffic.

A device that says "I am class 1, subclass 3" gets the operating system's own driver: CoreMIDI on macOS
and iOS, the class driver on Windows, `snd-usb-audio` on Linux. The device appears to every program
that speaks MIDI, including Chrome's Web MIDI.

The MIDIUSB library, CircuitPython's `usb_midi` and the Teensy's MIDI mode all set those two numbers.
That is the whole trick. "Class-compliant" means "says the class code and then behaves".

## The four-byte packet

USB MIDI does not send the three MIDI bytes bare. Each message is a four-byte packet: one header byte
with the cable number in the high nibble and the message type in the low one, then the three MIDI
bytes, padded if the message is shorter. That is why the Arduino code reads

```cpp
midiEventPacket_t p = {0x09, 0x90 | channel, note, velocity};
```

`0x09` is cable 0, type 9, note on. `0x08` is note off, `0x0B` control change. The type repeats the top
nibble of the status byte, which is redundant and is what the spec asks for. CircuitPython hides the
header; `usb_midi.ports[1].write(bytes([...]))` takes the three bytes and wraps them.

Cables are why a Launchpad shows two ports: one physical device, two virtual MIDI cables, each its own
port in the OS.

## Bluetooth

Bluetooth MIDI is a separate spec (MIDI over Bluetooth Low Energy, 2015). The device offers a GATT
service with UUID `03B80E5A-EDE8-4B33-A751-6CE34EC4C700` and one characteristic. Each packet carries a
header and a timestamp byte before the MIDI bytes, which is the `0x80, 0x80` at the front of what the
Puck sends. macOS, iOS and Android (6 and later) pair it as a MIDI device natively. Windows needs a
helper app. Espruino's `ble_midi` module sets the service and the advertising bytes.

## What does need a driver

A board without native USB (Uno, Nano) talks serial. Something on the computer has to turn the serial
stream into a MIDI port, like Hairless MIDI or ttymidi, and that something is the driver you avoid by
picking a board with the USB controller in the chip. Older commercial hardware from before the class
driver was common sometimes ships its own driver too. On Windows the class driver opens a device for
one program at a time, so close the Explorer before running the sketch.

## The name the Explorer shows

The product string in the USB descriptor. It belongs to the board definition, not your sketch, which is
why a Leonardo running the starter is "Arduino Leonardo" and a Trinkey is "Slide Trinkey M0". To change
it:

- Arduino: `build.usb_product` in the core's `boards.txt`, or `-DUSB_PRODUCT="\"Thing\""` in a
  `platform.local.txt`. Some cores also expose `USB_MANUFACTURER`.
- CircuitPython 8 and later: `supervisor.set_usb_identification("You", "Thing")` in `boot.py`, before
  USB starts.
- Espruino: `NRF.setAdvertising({}, {name: "Thing"})`, though `ble_midi.init()` sets `PuckCC` after
  it, so call yours after `init()`.

The site's helpers match devices on a substring of this name. Rename a Trinkey and keep "Slide" or
"Rotary" in it, or pass the new name to `AnyMidi`.
