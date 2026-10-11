---
name: Midi Fighter
title: Midi Fighter Classic
description: Sixteen arcade buttons, one on/off LED each. Every button is a note; every LED is a note sent back.
order: 3
maker: DJ TechTools
usb_name: '"Midi Fighter Classic"'
ports: 1 in, 1 out
sends: Notes 36 to 51 on channel 3, one per button.
receives: The same notes back on channel 3. Velocity above 0 lights the LED, 0 clears it.
buy: Not sold any more. Second-hand only.
photo: none
firmware: none
helper: Midi Fighter
starters:
  p5: starters/p5/midi-fighter
  python: starters/python/midifighter_starter/midifighter_starter.pyde
  java: starters/java/MidiFighterStarter/MidiFighterStarter.pde
raw:
  java: starters/raw/java/RawMidiFighter/RawMidiFighter.pde
  python: starters/raw/python/raw_midifighter/raw_midifighter.pyde
  p5: starters/raw/p5/midi-fighter
---

Sixteen arcade buttons in a 4×4 grid with an on/off LED under each. Every button is a note and every
LED is a note sent back. That's the whole device, which makes it the easiest one on the table to
understand completely. It's the 2010 Classic, not the 3D, so no colours and no accelerometer. There
are four on the table.

<!-- facts -->

<!-- map -->

## Lighting the LEDs

Send the button's own note back on channel 3. Velocity above 0 lights it, 0 or a note off clears it. No
brightness, no colour. A held button stays lit. The device never reports LED state, so the helper
keeps its own picture of which are on.

## Start here

<!-- starters -->

## The helper

| | |
|---|---|
| `new MidiFighter(this)` | Connects to the first device whose name contains "Midi Fighter". |
| `mf.pressed(i)`, `mf.justPressed(i)` | Cell i, 0 to 15 in reading order. "Just" is true for one frame. |
| `mf.bank` | 0 to 3 when the unit is in bank mode, otherwise 0. |
| `mf.led(i, on)`, `mf.led(i, on, bank)`, `mf.clear()` | Lights are on or off. The bank form writes into a bank you are not looking at. The device shows it when you switch. |
| `void padPressed(int index)`, `void padReleased(int index)` | Define either in your sketch and the helper calls it. |

<!-- helper -->

## Try first

- Toggle lights, which the starter does. Then a press lights its neighbours too: Lights Out.
- A sixteen-step sequencer. Each button a step, a playhead on the LEDs. There is a
  [port](@demos#ports-you-can-take-apart) to take apart.
- Simon. The LEDs play a sequence, you play it back.
- A 4×4 pixel canvas, mirrored big on screen.

More on the [ideas page](@ideas#midi-fighter-classic-16-arcade-buttons-one-led-each) and
the [demos page](@demos#midi-fighter-classic). The on-device menu and how to un-brick one:
[MIDI-FIGHTER-CLASSIC.md](pathname:///grid-controllers/MIDI-FIGHTER-CLASSIC.md).

## Without the helper

Notes 36 to 51 in, the same notes back out for the LEDs. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
