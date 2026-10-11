# circuit-playground-midi-multi-tool

Repo: <https://github.com/georgemandis/circuit-playground-midi-multi-tool> (public since 2019; the
source lives there, not here)

The Circuit Playground firmware from the 2018 and 2019 Web MIDI workshops. Ten modes, one sensor on
duty at a time, mode picked with the slide switch and the two buttons. The device pages on the site
read the `.ino` for their message maps, and the site's Circuit Playground helper is written against it.

This folder holds a README fix for that repo, not a copy of the code:

| File | What |
|---|---|
| `README.upstream.md` | the repo's README as of commit `3ba8b2a`, for reference |
| `README.proposed.md` | the replacement: a message-map table with channel and bytes, the mode 7 correction, arduino-cli flash steps, current Adafruit links instead of Amazon affiliate ones |
| `README.patch` | the unified diff between the two |

## The mode 7 claim

The upstream README says mode 7 "converts the accelerometer tap detection to a MIDI message". The
`.ino` arms the tap interrupt in `setup()`, and in mode 7 the interrupt flashes the pixels and prints
to serial, but the lines in `case 6` that would send `noteOn(2, 1, 127)` are commented out under
"Accelerometer detect tap: TBD". A tap is felt and shown on the board. No MIDI leaves it. The proposed
README says so and tells the reader which block to uncomment.

Two other things the upstream README leaves out and the proposed one states: every message goes out on
channel 2 (`noteOn(1, ...)` with `0x90 | channel`, zero-based on the wire), and the colour mixer adds
note and velocity, so its range is 0..254.

## Apply it

```sh
cd ~/Projects/circuit-playground-midi-multi-tool
git apply /path/to/firmware/circuit-playground-midi-multi-tool/README.patch
git commit -am "README: message map with channel and bytes, mode 7 sends no MIDI, arduino-cli steps"
git push
```

Or copy `README.proposed.md` over the repo's `README.md`. The patch was checked against
`README.upstream.md` with `patch --dry-run` on 2026-10-04. The sketch itself compiles unchanged with
arduino-cli 1.5.1 for `arduino:avr:circuitplay32u4cat` (73% of the Classic's flash).

## Licence

The upstream repo is MIT. These files are notes about it, same licence.
