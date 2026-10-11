---
title: Circuit Playground
description: The ten-mode Arduino firmware behind the Circuit Playground device page, and what its README got wrong.
---

# Circuit Playground multi-tool

Adafruit's round board has an accelerometer, light, sound and temperature sensors, eight touch pads,
ten NeoPixels, a speaker, two buttons and a slide switch. One Arduino sketch puts one sensor at a time
on MIDI duty. It ran the 2018 and 2019 Web MIDI workshops and the PCD 2026 one.

Source: [github.com/georgemandis/circuit-playground-midi-multi-tool](https://github.com/georgemandis/circuit-playground-midi-multi-tool).
What it sends, mode by mode, is on the [device page](/devices/circuit-playground/). This page is about
the firmware.

## How it is built

The MIDIUSB library gives three calls: `sendMIDI` with a four-byte packet, `read` for incoming, `flush`
to push the buffer out. The sketch wraps them:

```cpp
void noteOn(byte channel, byte pitch, byte velocity) {
  midiEventPacket_t noteOn = {0x09, 0x90 | channel, pitch, velocity};
  MidiUSB.sendMIDI(noteOn);
}
```

The first byte, `0x09`, is USB-MIDI's own header: which jack and what kind of message. The other three
are the MIDI bytes. `channel` here is zero-based and the sketch passes 1, so everything goes out as
channel 2. That is the kind of thing a README has to say and this one did not, until now.

`loop()` is a `switch` on the mode. Each case reads one sensor and sends. The slide switch drops into a
mode-picking loop where the buttons change the mode and the pixels show it. The buttons and the switch
never send MIDI.

## What the README got wrong

Mode 7 is listed as "converts the accelerometer tap detection to a MIDI message". The tap interrupt is
armed and it flashes the pixels, but the `noteOn(2, 1, 127)` that would send is commented out under
"Accelerometer detect tap: TBD". No MIDI leaves the board on a tap. The fix is a proposed README in
`firmware/circuit-playground-midi-multi-tool/` with the full message map, the channel, and arduino-cli
flash steps, as a patch against the repo. Uncomment the block if you want the note.

## Flash

```sh
arduino-cli core install arduino:avr
arduino-cli lib install MIDIUSB "Adafruit Circuit Playground"
git clone https://github.com/georgemandis/circuit-playground-midi-multi-tool
arduino-cli compile --fqbn arduino:avr:circuitplay32u4cat circuit-playground-midi-multi-tool
arduino-cli upload  --fqbn arduino:avr:circuitplay32u4cat -p /dev/cu.usbmodem14101 circuit-playground-midi-multi-tool
```

Express boards use `adafruit:samd:adafruit_circuitplayground_m0` after installing the `adafruit:samd`
core. The Classic is at 73% of its flash with this sketch, so there is room for a mode of your own.

## Make it yours

Change `noteOn(1, ...)` to `noteOn(0, ...)` and it is on channel 1 like everything else here. Add a
`case` for a sensor combination you want, for instance light as CC 1 and the pads as notes in the same
mode, since the one-sensor-at-a-time rule is a choice, not a limit. The [starter](./04-arduino-midiusb.md)
is the same three functions with nothing else in the way.
