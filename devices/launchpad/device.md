---
name: Launchpad
title: Launchpad Mini MK3
description: An 8×8 grid of RGB pads. The pads are notes; the colours go back as SysEx.
order: 4
maker: Novation
usb_name: "LPMiniMK3 MIDI". There is also "LPMiniMK3 DAW". Use MIDI.
ports: Two pairs, MIDI and DAW. The helper picks the MIDI one.
sends: Notes for the pads, CC 19 to 99 for the buttons, in Programmer mode.
receives: A note with a palette index as velocity lights a pad. SysEx for exact RGB, all pads at once and scrolling text.
buy: https://novationmusic.com/products/launchpad-mini-mk3
photo: none
firmware: none
helper: Launchpad
starters:
  p5: starters/p5/launchpad
  python: starters/python/launchpad_starter/launchpad_starter.pyde
  java: starters/java/LaunchpadStarter/LaunchpadStarter.pde
starter_notes:
  p5: The browser asks for MIDI, then SysEx. Say yes to both.
raw:
  java: starters/raw/java/RawLaunchpad/RawLaunchpad.pde
  python: starters/raw/python/raw_launchpad/raw_launchpad.pyde
  p5: starters/raw/p5/launchpad
---

An 8×8 grid of RGB pads, eight buttons across the top, eight down the right side, and a logo button.
The pads are notes and the colours go back as SysEx. Think of it as a 64-pixel display that can feel
you touching it. There are two on the table, so share.

<!-- facts -->

<!-- map -->

## Lighting the pads

A note on sent to a pad with a palette index 0 to 127 as velocity sets a colour. 0 is off. Exact RGB,
all 64 pads at once, and scrolling text are SysEx commands. The helper gives you `set`, `setRGB` and
`text`. The bytes are taken apart in the [Launchpad Marquee notes](pathname:///launchpad-marquee/README.md).

Handy palette indexes: 3 white, 5 red, 9 orange, 13 yellow, 21 green, 37 cyan, 45 blue, 53 magenta.
`pad.set(x, y, c)` also accepts an ordinary Processing colour.

## Start here

<!-- starters -->

## The helper

| | |
|---|---|
| `new Launchpad(this)` | Connects to the "LPMiniMK3 MIDI" ports, switches to Programmer mode, and puts the device back in Live mode when the sketch closes. |
| `pad.pressed(x, y)`, `pad.justPressed(x, y)` | x 0..7 left to right, y 0..7 top to bottom. |
| `pad.set(x, y, c)`, `pad.setRGB(x, y, r, g, b)` | A palette index 0..127 or a Processing colour. Or RGB with each channel 0..255. |
| `pad.button("top3", c)`, `pad.clear()`, `pad.text("hi", c)` | Side buttons by id, everything off, and the firmware's own text scroll. |
| `void padPressed(int x, int y)`, `void padReleased(int x, int y)`, `void buttonPressed(String id)` | Define any in your sketch and the helper calls it. |

<!-- helper -->

## Try first

- Paint. Each press cycles a pad through colours. Then mirror it big on screen.
- Game of Life. Press to seed, logo to step. There is a [port](@demos#ports-you-can-take-apart)
  of the automata demo.
- Two players: one at the keyboard, one at the board. Quest is built on this.
- Snake, steered with the arrow buttons.

More on the [ideas page](@ideas#launchpad-mini-mk3-88-rgb-pads--16-buttons) and the
[demos page](@demos#launchpad-mini-mk3).

## Without the helper

One SysEx for programmer mode, pads as notes, palette colours out. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
