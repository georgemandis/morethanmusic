---
title: Devices
slug: /devices/
description: One page per device. What it sends, what it receives, a starter in each language, the raw version, the quirks, where to buy.
---

# Devices

One page per device, all from the same template: what it sends, what it receives, a starter sketch in
p5.js, Python Mode and Java, the raw version with no helper, known quirks, and where to buy one.

| Device | What it is | Sends |
|---|---|---|
| [PipSqueak](./pipsqueak.md) | a joystick and a button, from useMidi | two CCs for the axes, one for the button |
| [Circuit Playground](./circuit-playground.md) | Adafruit's round board with George's multi-tool firmware | notes from the pads, CC 1 from the sensors, notes from the accelerometer |
| [Midi Fighter](./midi-fighter.md) | sixteen arcade buttons, one LED each | notes, four banks |
| [Launchpad](./launchpad.md) | 64 RGB pads and 16 buttons | notes for pads, CCs for the buttons, SysEx for colours |
| [Slide Trinkey](./slide-trinkey.md) | a slider on a USB stick, CircuitPython | one CC and a touch note |
| [Rotary Trinkey](./rotary-trinkey.md) | a knob on a USB stick, CircuitPython | two CCs and two notes |
| [Anything else](./anything-else.md) | whatever shows up as a MIDI device | whatever it sends. The Explorer tells you |

Not sure what yours sends? [The Explorer](/the-explorer/) decodes every message and prints the
device's exact name.

## Add a device

Each page is generated from a folder in the repo. Copy `devices/_template/`, fill the message map from
the Explorer, add a photo, open a pull request.
[devices/CONTRIBUTING.md](pathname:///devices/CONTRIBUTING.md) has the fields.
