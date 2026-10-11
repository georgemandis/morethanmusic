# trinkey-midi

<!-- repo: pending -->

CircuitPython firmware that turns Adafruit's Slide Trinkey M0 and Rotary Trinkey M0 into USB MIDI
controllers. No library on the board, no driver on the computer: `usb_midi` writes the three bytes
and the Trinkey shows up as a class-compliant MIDI device on macOS, Windows and Linux.

Written for the Processing Community Day 2026 MIDI workshop in New York. CircuitPython 10.3.1.

## What they send and receive

Everything is on channel 1. Each board sends one CC with its position at startup so a sketch starts in
sync.

| Board | USB name | Drive label | Sends |
|---|---|---|---|
| Slide Trinkey M0 | `Slide Trinkey M0` | `SLIDEPY` | slider CC 1, 0 at the left to 127 at the right; touch pad note 60 |
| Rotary Trinkey M0 | `Rotary Trinkey M0` | `ROTARYPY` | knob CC 2 absolute 0..127 and CC 3 relative (1 per click clockwise, 127 per click counter-clockwise); knob press note 61; touch pad note 62 |

Byte by byte:

| Thing | Bytes |
|---|---|
| slider moved | `B0 01 vv` |
| slide touch pad down, up | `90 3C 7F`, `80 3C 00` |
| knob turned | `B0 02 vv` and one `B0 03 01` or `B0 03 7F` per click |
| knob pressed, released | `90 3D 7F`, `80 3D 00` |
| rotary touch pad down, up | `90 3E 7F`, `80 3E 00` |

Both boards listen. A note on from the computer sets the NeoPixel colour from the note number for one
second, scaled by velocity, so a sketch can talk back. Otherwise the pixel follows the slider or knob
position and turns white while a pad or the knob is held.

The numbers are constants at the top of each `code.py`, marked `# change this`.

## Flash, by hand

A new Trinkey runs Adafruit's Arduino demo (serial only, printing `Touch:` and `Slider:`): no MIDI port,
no drive. Per board:

1. Enter the bootloader: double-tap the reset button, or open its serial port at 1200 baud and close
   it. A `TRINKEYBOOT` drive appears.
2. Copy the board's CircuitPython UF2 onto `TRINKEYBOOT`. Downloads:
   <https://circuitpython.org/board/adafruit_slide_trinkey_m0/> and
   <https://circuitpython.org/board/adafruit_rotary_trinkey_m0/>. On recent macOS use `cp -X`; plain
   `cp` and Finder fail with "Permission denied" trying to write extended attributes to the tiny FAT
   volume. The drive disappears and `CIRCUITPY` appears.
3. Copy the board's two files to the root of `CIRCUITPY`. The board restarts as a MIDI device. Unplug
   and replug once so the drive label changes.

```sh
# slide
cp -X ~/Downloads/adafruit-circuitpython-adafruit_slide_trinkey_m0-en_US-10.3.1.uf2 /Volumes/TRINKEYBOOT/
cp slide-trinkey/boot.py slide-trinkey/code.py /Volumes/CIRCUITPY/
# rotary
cp -X ~/Downloads/adafruit-circuitpython-adafruit_rotary_trinkey_m0-en_US-10.3.1.uf2 /Volumes/TRINKEYBOOT/
cp rotary-trinkey/boot.py rotary-trinkey/code.py /Volumes/CIRCUITPY/
```

One board at a time. Two in the same state both mount as `CIRCUITPY`. After `boot.py` has run once the
drives are `SLIDEPY` and `ROTARYPY` and both can stay plugged in.

## Check it

`tools/midimon.swift` is a 30-line CoreMIDI monitor for the macOS terminal:

```sh
swiftc -O -o /tmp/midimon tools/midimon.swift && /tmp/midimon 10
```

It lists every source and destination, then prints each message for ten seconds. Move the slider: CC 1
climbs 0..127. Touch the pad: note 60 on, then off. Turn the knob: CC 2 and CC 3. Press it: note 61.
Its pad: note 62. Anywhere else, use the Explorer on the site. `HARDWARE-CHECKLIST.md` is the list
that was ticked off at the workshop table.

## In a sketch

With the site's helpers: `new SlideTrinkey(this)` or `new RotaryTrinkey(this)`, or the generic
`new AnyMidi(this, "Slide")`, then read `cc(1)` or `cc(2)`; `noteOn(ch, note, vel)` fires for the pads
and the knob press. Without a helper, the device name to open is the USB name in the table above.

## Assumptions

- Pin names from the CircuitPython board definitions: `board.POTENTIOMETER`, `board.TOUCH`,
  `board.NEOPIXEL` (Slide); `board.ROTA`, `board.ROTB`, `board.SWITCH`, `board.TOUCH`, `board.NEOPIXEL`
  (Rotary). A wrong one shows in `boot_out.txt` and the serial console, and the pixel stays dark.
- Knob switch polarity is not assumed: whatever it reads at power-up is "released". Do not hold it
  while plugging in. If the knob counts backwards, swap `ROTA` and `ROTB` in `rotary-trinkey/code.py`.
- `usb_midi` is on by default on SAMD21 builds. A board with no MIDI port: add
  `import usb_midi; usb_midi.enable()` to `boot.py`.
- NeoPixels use the built-in `neopixel_write`, not the `neopixel` library, so `lib/` stays empty.
- The USB name is Adafruit's board name. To call it something else, add
  `supervisor.set_usb_identification("You", "Slide Thing")` to `boot.py` (CircuitPython 8 and later).
  The site's helpers match on "Slide" and "Rotary", so keep those words or change the helper.

## Licence

MIT. See `LICENSE`.
