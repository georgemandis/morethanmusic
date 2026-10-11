---
title: Arduino MIDIUSB
description: One button, one knob, one LED. The smallest class-compliant MIDI device worth plugging in.
---

# Arduino MIDIUSB starter

For any Arduino-style board with native USB: Leonardo, Micro, the 32u4 and SAMD Feathers, a Circuit
Playground, a Trinkey with the Arduino core. The MIDIUSB library turns it into a USB MIDI device.
Nothing on the computer.

Source: [github.com/georgemandis/arduino-midiusb-starter](https://github.com/georgemandis/arduino-midiusb-starter).

Source: `firmware/arduino-midiusb-starter/` in this site's repo.

## What it sends and receives

Channel 1.

| Thing | Message | Bytes |
|---|---|---|
| button on pin 2 pressed | note 60 on, velocity 127 | `90 3C 7F` |
| released | note 60 off | `80 3C 00` |
| knob on A0 moved | CC 1, 0..127 | `B0 01 vv` |
| incoming note on | built-in LED on | |
| incoming note off, or velocity 0 | LED off | |

## Wire it

A button between pin 2 and ground, no resistor (the sketch turns on the pull-up). A pot with its
middle leg on A0 and the outer legs on ground and the board's logic voltage. Nothing to hand: a wire
from pin 2 to ground is the button.

## Flash

```sh
arduino-cli core install arduino:avr
arduino-cli lib install MIDIUSB
arduino-cli board list
arduino-cli compile --fqbn arduino:avr:leonardo arduino-midiusb-starter
arduino-cli upload  --fqbn arduino:avr:leonardo -p /dev/cu.usbmodem14101 arduino-midiusb-starter
```

Other boards: `arduino:avr:micro`, `arduino:avr:circuitplay32u4cat`, or with the `adafruit:samd` core
`adafruit:samd:adafruit_circuitplayground_m0`, `adafruit:samd:adafruit_slidetrinkey_m0`,
`adafruit:samd:adafruit_rotarytrinkey_m0`. If the port vanishes, double-tap reset and upload again
within a few seconds.

## The code

{/* include: firmware/arduino-midiusb-starter/arduino-midiusb-starter/arduino-midiusb-starter.ino */}

```cpp title="arduino-midiusb-starter.ino"
// Arduino MIDIUSB starter. One button, one knob, one LED. The smallest class-compliant MIDI device
// worth plugging in. Any board with native USB and the MIDIUSB library: Leonardo, Micro, Circuit
// Playground (Classic or Express), Feather 32u4 or M0, Zero, MKR, Trinkey.
//
//   button (pin 2 to ground)    -> note 60 on with velocity 127 when pressed, note off on release
//   knob (A0)                   -> CC 1 with the position 0..127, sent when it changes
//   incoming note on            -> the built-in LED lights; a note off or velocity 0 turns it off
//
// Everything is on channel 1. The device appears under the board's USB name, so "Arduino Leonardo"
// or "Circuit Playground Express", not the sketch's name. See README.md for changing that.
#include <MIDIUSB.h>

const byte CHANNEL = 1;      // change this: 1..16
const byte NOTE = 60;        // change this: the note the button sends
const byte CC = 1;           // change this: the controller number the knob sends
const int BUTTON_PIN = 2;    // change this: any digital pin. Button between the pin and GND.
const int POT_PIN = A0;      // change this: any analog pin. Middle leg of the pot here, outer legs to 3V/5V and GND.

// MIDIUSB wants 4 bytes per message: a USB-MIDI header (message type in the low nibble), then the three
// MIDI bytes. The channel goes on the wire zero-based, so channel 1 is 0x90, channel 2 is 0x91.
void noteOn(byte channel, byte pitch, byte velocity) {
  midiEventPacket_t p = {0x09, (byte)(0x90 | (channel - 1)), pitch, velocity};
  MidiUSB.sendMIDI(p);
  MidiUSB.flush();
}

void noteOff(byte channel, byte pitch) {
  midiEventPacket_t p = {0x08, (byte)(0x80 | (channel - 1)), pitch, 0};
  MidiUSB.sendMIDI(p);
  MidiUSB.flush();
}

void controlChange(byte channel, byte control, byte value) {
  midiEventPacket_t p = {0x0B, (byte)(0xB0 | (channel - 1)), control, value};
  MidiUSB.sendMIDI(p);
  MidiUSB.flush();
}

bool pressed = false;
int lastKnob = -1;

void setup() {
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // Button: LOW is pressed because of the pull-up.
  bool now = digitalRead(BUTTON_PIN) == LOW;
  if (now != pressed) {
    pressed = now;
    if (pressed) noteOn(CHANNEL, NOTE, 127);
    else noteOff(CHANNEL, NOTE);
    delay(5);                          // debounce
  }

  // Knob: 10-bit reading to 7 bits. Only send when it moves, or every sketch on the other end drowns.
  int knob = analogRead(POT_PIN) >> 3;
  if (knob != lastKnob) {
    lastKnob = knob;
    controlChange(CHANNEL, CC, knob);
  }

  // Incoming: header 0x09 is note on, 0x08 is note off. Any channel.
  midiEventPacket_t rx = MidiUSB.read();
  if (rx.header == 0x09 && rx.byte3 > 0) digitalWrite(LED_BUILTIN, HIGH);
  if (rx.header == 0x08 || (rx.header == 0x09 && rx.byte3 == 0)) digitalWrite(LED_BUILTIN, LOW);
}
```

{/* /include */}

## From here

The same `examples/` folder holds the 2018 colour mixer: a Circuit Playground that receives a note on
and sets red, green or blue on all ten pixels by channel. The [multi-tool](./01-circuit-playground.md)
is this starter grown ten modes. Open the [Explorer](pathname:///explorer/web/) first to see your
bytes, then the [Circuit Playground device page](/devices/circuit-playground/) for a sketch to point at them.
