## The ten modes

Everything the board sends is on channel 2: status `0x91` for notes, `0xB1` for control changes.

### Modes that send MIDI

| Mode | What it does |
|---|---|
| 1 | Cap touch. Each of the eight pads is a note: note on with velocity 127 when touched, note off on release. Note number is 1 + the pad's pin (table below). The pixels flash a random colour on each touch, and the buttons nudge the touch sensitivity. |
| 2 | Light. CC 1 with the light level scaled to 0..127, once a second. |
| 3 | Sound. CC 1 with the sound level scaled to 0..127, once a second. |
| 4 | Temperature. CC 1 with degrees Celsius as the value, once a second. |
| 5 | Random notes. A note on with a random note and random velocity, every 50 ms or so. The buttons speed it up and slow it down. |
| 6 | Accelerometer. Three note ons in a row every 200 ms, so five times a second: x, y, then z, each as note = m/s² + 20, velocity 127. 20 is zero g, 30 is about one g. Flat on a table reads roughly 20, 20, 30. |
| 7 | Tap. A tap on the board flashes all ten pixels a random colour and prints to the serial port. No MIDI. The firmware README says it sends a message; the code that would is commented out. See below. |

### Modes that receive MIDI

| Mode | What it does |
|---|---|
| 8 | Speaker. Plays any incoming note on over the built-in speaker, at the note's pitch, for 50 ms. |
| 10 | Colour mixer. A note on on channel 1 sets red, channel 2 sets green, channel 3 sets blue, each to note + velocity (0 to 254), on all ten pixels at once. |

### Neither

| Mode | What it does |
|---|---|
| 9 | Random tones on the speaker and random pixel flashes. No MIDI in or out. For funsies. |

No mode does both.

Touch pads, helper index to firmware pin to note:

| `touch(i)` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| pin | 3 | 2 | 0 | 1 | 12 | 6 | 9 | 10 |
| note | 4 | 3 | 1 | 2 | 13 | 7 | 10 | 11 |

### About mode 7

The firmware README says mode 7 "converts the accelerometer tap detection to a MIDI message". The
helpers' README says it sends nothing. The code: `setup()` arms the tap detector and attaches an
interrupt. In mode 7 the interrupt prints the tap to serial, sets a flag and flashes all ten pixels. The
part of mode 7 that would send `noteOn(2, 1, 127)` sits under "Accelerometer detect tap: TBD" and is
commented out. So the README overstates it. A tap is felt and shown on the board and no MIDI leaves it.
A hardware check is still pending. For a buzzer or a tap, use a touch pad in mode 1.
