# arduino-midiusb-starter

Repo: <https://github.com/georgemandis/arduino-midiusb-starter>

One button, one knob, one LED. The smallest USB MIDI device worth plugging in, for any Arduino-style
board with native USB. No driver on the computer: the MIDIUSB library makes the board a
class-compliant MIDI device, and every operating system already knows what to do with one.

Grew out of the Circuit Playground code from the 2018 Web MIDI workshops (SPA Conference and
Teardown), where `3-arduino-code.md` pointed at two sketches. The colour mixer from that page is in
`examples/`. The multi-tool it also pointed at has its own repo:
[circuit-playground-midi-multi-tool](https://github.com/georgemandis/circuit-playground-midi-multi-tool).

## What it sends and receives

Channel 1. The device appears under the board's USB name ("Arduino Leonardo", "Circuit Playground
Express"), not the sketch's.

| Thing | Message | Bytes |
|---|---|---|
| button pressed | note 60 on, velocity 127 | `90 3C 7F` |
| button released | note 60 off | `80 3C 00` |
| knob moved | CC 1, position 0..127 | `B0 01 vv` |
| incoming note on, any channel | built-in LED on | `9n nn vv` with vv > 0 |
| incoming note off, or note on with velocity 0 | built-in LED off | `8n nn 00` or `9n nn 00` |

Constants at the top of the sketch, each marked `// change this`: channel, note, CC number, the two
pins.

## Wiring

- Button between pin 2 and GND. The sketch uses the internal pull-up, so no resistor.
- Potentiometer: middle leg to A0, outer legs to GND and the board's logic voltage (5V on a Leonardo,
  3V on a SAMD board).
- No button or knob to hand: short pin 2 to GND with a wire for the note. The knob reading floats and
  sends CC noise until A0 is tied to GND or 3V.

## Boards that work

Anything the MIDIUSB library supports, which is anything with the USB controller in the chip:

| Board | `--fqbn` for arduino-cli | Core |
|---|---|---|
| Arduino Leonardo | `arduino:avr:leonardo` | `arduino:avr` |
| Arduino Micro | `arduino:avr:micro` | `arduino:avr` |
| Circuit Playground Classic (32u4) | `arduino:avr:circuitplay32u4cat` | `arduino:avr` |
| Circuit Playground Express (SAMD21) | `adafruit:samd:adafruit_circuitplayground_m0` | `adafruit:samd` |
| Slide Trinkey, Rotary Trinkey | `adafruit:samd:adafruit_slidetrinkey_m0`, `adafruit:samd:adafruit_rotarytrinkey_m0` | `adafruit:samd` |

An Uno or a Nano (ATmega328) does not work: no native USB. Those need a serial-to-MIDI bridge on the
computer, which is exactly the driver this avoids.

## Flash with arduino-cli

```sh
brew install arduino-cli                       # or https://arduino.github.io/arduino-cli/
arduino-cli core update-index
arduino-cli core install arduino:avr            # Leonardo, Micro, Circuit Playground Classic
arduino-cli lib install MIDIUSB
arduino-cli board list                          # find the port, /dev/cu.usbmodemXXXX on macOS
arduino-cli compile --fqbn arduino:avr:leonardo arduino-midiusb-starter
arduino-cli upload  --fqbn arduino:avr:leonardo -p /dev/cu.usbmodem14101 arduino-midiusb-starter
```

For a SAMD board swap the core and the fqbn:

```sh
arduino-cli config add board_manager.additional_urls https://adafruit.github.io/arduino-board-index/package_adafruit_index.json
arduino-cli core update-index
arduino-cli core install adafruit:samd
arduino-cli compile --fqbn adafruit:samd:adafruit_circuitplayground_m0 arduino-midiusb-starter
arduino-cli upload  --fqbn adafruit:samd:adafruit_circuitplayground_m0 -p /dev/cu.usbmodem14101 arduino-midiusb-starter
```

If the upload cannot find the port, double-tap the reset button. The board enters its bootloader and
the port comes back for a few seconds.

## Flash with the Arduino IDE

1. Tools, Board, Boards Manager: install "Arduino AVR Boards" (or "Adafruit SAMD Boards" after adding
   the Adafruit URL under Preferences, Additional boards manager URLs).
2. Sketch, Include Library, Manage Libraries: install MIDIUSB.
3. Open `arduino-midiusb-starter/arduino-midiusb-starter.ino`, pick the board and the port, Upload.

## Check it

Open the Explorer on the site, or on macOS build the 30-line monitor in
`../trinkey-midi/tools/midimon.swift`. The board is listed as a source and a destination. Press the
button: `90 60 127` then `80 60 0`. Turn the knob: `B0 1 n`. Send it a note on from the Explorer's
send panel: the LED lights.

## examples/circuit-playground-midi-color-mixer

The 2018 workshop sketch, kept as it was. A Circuit Playground as a receiver: a note on sets one colour
channel on all ten NeoPixels.

| Incoming | Sets |
|---|---|
| note on, channel 1 (status 144) | red = note + velocity |
| note on, channel 2 (status 145) | green = note + velocity |
| note on, channel 3 (status 146) | blue = note + velocity |

Note plus velocity, so the range is 0..254 rather than 0..127. That was a workaround for seven-bit
bytes and it stayed. Needs the Adafruit Circuit Playground library as well as MIDIUSB:

```sh
arduino-cli lib install "Adafruit Circuit Playground"
arduino-cli compile --fqbn arduino:avr:circuitplay32u4cat examples/circuit-playground-midi-color-mixer
```

## Verified

Compiled with arduino-cli 1.5.1 on 2026-10-04 for `arduino:avr:leonardo`, `arduino:avr:circuitplay32u4cat`
and `adafruit:samd:adafruit_circuitplayground_m0`. Not yet run on a board since the rewrite; the three
send functions are the ones the multi-tool has used in workshops since 2018, with the channel made
one-based.

## Licence

MIT. See `LICENSE`.
