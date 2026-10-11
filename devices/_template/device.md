---
name: Device name
description: One line for the sidebar and search. What it is, what it sends.
order: 99
maker: Who makes it
usb_name: What the Explorer prints at the top, or the substring the helper matches
ports: 1 in, 1 out
sends: Notes for the pads, CC 1 for the knob
receives: Notes to light the pads, or none
buy: https://example.com/product
photo: none
firmware: none
helper: AnyMidi
starters:
  p5: starters/p5/anything-else
  python: starters/python/anymidi_starter/anymidi_starter.pyde
  java: starters/java/AnyMidiStarter/AnyMidiStarter.pde
raw:
  java: starters/raw/java/HelloMidi/HelloMidi.pde
  python: starters/raw/python/hello_midi/hello_midi.pyde
  p5: starters/raw/p5/hello-midi
---

One paragraph. What the thing is, what is on it, why you would want to make it do something.

<!-- facts -->

<!-- map -->

Where the numbers came from: a date, a unit, the Explorer. Anything a custom unit might change. Point
at [the Explorer](@explorer).

## Start here

One line on what the starter draws. The `change this` comments mark the lines to make your own.

<!-- starters -->

## The helper

| | |
|---|---|
| `new AnyMidi(this)` | What it connects to. |
| `m.cc(n)`, `m.note(n)` | What you read every frame. |
| `void noteOn(…)` | Callbacks the helper calls by name. |

<!-- helper -->

## Try first

- Three small things to build, one line each.
- Each one a step up from the starter.
- Link the [ideas page](@ideas) if it has a section for this device.

## Without the helper

What the raw sketch decodes inline, in one sentence. Read [the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
