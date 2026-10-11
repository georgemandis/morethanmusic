---
name: Anything else
description: The NeoTrellis, a keyboard, a foot pedal, whatever you brought. The generic helper reads it; the Explorer tells you what it sends.
order: 7
maker: Anyone
usb_name: Whatever the Explorer prints at the top.
ports: Whatever it has. Most controllers are 1 in, 1 out.
sends: Notes and CCs. The Explorer tells you which numbers.
receives: Sometimes. Try the Explorer's send panel on anything with lights.
buy: none
photo: none
firmware: none
helper: AnyMidi
starters:
  p5: starters/p5/anything-else
  python: starters/python/anymidi_starter/anymidi_starter.pyde
  java: starters/java/AnyMidiStarter/AnyMidiStarter.pde
starter_notes:
  java: It draws every note and CC it sees.
---

The [Trinkeys](./slide-trinkey.md), the NeoTrellis, a keyboard you brought from home, a drum pad, a foot pedal. If the operating
system sees it as a MIDI device, the generic helper can read it and the Explorer will show you what it
sends.

<!-- facts -->

## Find out what it sends

1. Plug it in and open [the Explorer](@explorer).
2. Press, turn, slide or tilt everything once. Write down the note and CC numbers.
3. Note the device name at the top. That is the substring you give the helper.

<!-- map -->

## Start here

<!-- starters -->

## The helper

| | |
|---|---|
| `new AnyMidi(this)`, `new AnyMidi(this, "name substring")` | The first input on the system, or the first whose name contains the substring. |
| `m.note(n)`, `m.cc(n)`, `m.down(n)` | The last value seen for that note or controller, 0..127, or -1 if it has never arrived. Whether a note is held. |
| `m.lastNote`, `m.lastCC`, `m.lastCCValue`, `m.last` | The most recent thing that happened, for sketches that react to whatever arrives. |
| `m.send(status, d1, d2)`, `m.noteOn(ch, n, vel)`, `m.controlChange(ch, cc, val)` | Output, for devices with lights. |
| `void noteOn(…)`, `void noteOff(…)`, `void controlChange(…)`, `void midiMessage(…)` | Define any in your sketch and the helper calls it with channel, number and value. |

<!-- helper -->

## The p5.js helpers

The same helpers for the browser: one script per device, or the bundle
`midi-helpers/p5/midi-helpers.js`, served from this site.

{/* include: midi-helpers/README.md#p5 */}

{/* /include */}

## Try first

- One CC, one number on screen, huge. Then a colour, then a speed.
- A piano keyboard as 61 buttons. Each note a column, velocity its height.
- Two controls as x and y.

More on the [ideas page](@ideas#trinkeys-neotrellis-m4-and-the-things-people-brought).

## Without the helper

For an unknown device the raw path is HelloMidi: it opens every input and prints every message, which
is most of what AnyMidi does. [The three bytes, no helpers](@raw-intro).
