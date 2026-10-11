---
name: PipSqueak
description: A joystick and a button from useMIDI. Two CCs for the axes, one for the button.
order: 1
maker: useMidi
usb_name: contains "PipSqueak", on some units "PipSqueaker"
ports: 1 in, 1 out
sends: CC 17 left and right, CC 20 up and down, CC 25 button. The numbers are a config, not a constant.
receives: Rules saved in the configurator. Stock firmware flashes the LED red on note 60.
buy: https://usemidi.com/product/pipsqueak-black
photo: none
firmware: Stock. Set up at [usemidi.com/configure.html](https://usemidi.com/configure.html)
helper: PipSqueak
starters:
  p5: starters/p5/pipsqueak
  python: starters/python/pipsqueak_starter/pipsqueak_starter.pyde
  java: starters/java/PipSqueakStarter/PipSqueakStarter.pde
raw:
  java: starters/raw/java/RawPipSqueak/RawPipSqueak.pde
  python: starters/raw/python/raw_pipsqueak/raw_pipsqueak.pyde
  p5: starters/raw/p5/pipsqueak
---

A joystick and a button from [useMidi](https://usemidi.com). Thanks to Masson there for providing them.
Two axes, each a control change 0 to 127, and a button that is also a control change. Some on the table
were set up with the [configurator](https://usemidi.com/configure.html), so the helper takes a config
instead of assuming the numbers below.

<!-- facts -->

<!-- map -->

## Start here

It's under 40 lines. Open it, press Run, and push the stick. The `change this` comments mark the lines
to make your own, and [Hello world](@hello-world) walks through this exact sketch line by line.

<!-- starters -->

## The helper

| | |
|---|---|
| `new PipSqueak(this)`, `new PipSqueak(this, "name", config)` | Connects by USB-name substring. The config carries CC numbers, centre and range per axis, the button CC and threshold, deadzone and smoothing. |
| `stick.x`, `stick.y` | -1 to 1. `y` is +1 when pushed up, so subtract it from a screen y. |
| `stick.angle`, `stick.magnitude` | Radians and 0 to 1. The angle is NaN inside the deadzone, so test `magnitude` first. |
| `stick.pressed`, `stick.justPressed()`, `stick.justReleased()` | The button. The "just" ones are true for one frame. |
| `void stickPressed()`, `void stickReleased()` | Define either in your sketch and the helper calls it. |

<!-- helper -->

## Try first

- A dot with a trail. Then colour the trail by angle.
- A character whose speed is the magnitude. Then walls.
- Hold the button to draw, release to lift the pen.
- Steer a parameter, not a position. The [Gray-Scott demo](pathname:///pipsqueak-grayscott/) does this.

More on the [ideas page](@ideas#pipsqueak-joystick--button) and the
[demos page](@demos#pipsqueak).

## Without the helper

Three CCs decoded inline: 17 is x, 20 is y, 25 is the button. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
