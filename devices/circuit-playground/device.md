---
name: Circuit Playground
description: Adafruit's round sensor board, running George's multi-tool MIDI firmware. One sensor per mode.
order: 2
maker: Adafruit, with George's firmware
usb_name: depends on how it was flashed. "Circuit Playground Express" on the ones on the table. The Explorer prints it.
ports: 1 in, 1 out
sends: Channel 2. Notes for touch, random and accelerometer modes, CC 1 for light, sound and temperature.
receives: Notes. Mode 8 plays them on the speaker, mode 10 mixes them into a pixel colour.
buy: https://www.adafruit.com/product/3333
photo: none
firmware: https://github.com/georgemandis/circuit-playground-midi-multi-tool
helper: Circuit Playground
starters:
  p5: starters/p5/circuit-playground
  python: starters/python/circuitplayground_starter/circuitplayground_starter.pyde
  java: starters/java/CircuitPlaygroundStarter/CircuitPlaygroundStarter.pde
raw:
  java: starters/raw/java/RawCircuitPlayground/RawCircuitPlayground.pde
  python: starters/raw/python/raw_circuitplayground/raw_circuitplayground.pyde
  p5: starters/raw/p5/circuit-playground
---

Adafruit's round board, with an accelerometer, light, sound and temperature sensors, eight touch pads,
ten NeoPixels, two buttons and a slide switch. George's firmware turns it into a MIDI controller with
one sensor on duty at a time, depending on the mode. The firmware is from a 2019 Web MIDI workshop and
hasn't changed since.

:::info[Source of truth]
The firmware is public: [github.com/georgemandis/circuit-playground-midi-multi-tool](https://github.com/georgemandis/circuit-playground-midi-multi-tool).
This page comes from reading that `.ino`. Where they disagree, the code wins.
:::

<!-- facts -->

## Pick a mode first

To change or view the current mode your Circuit Playground is in, toggle the slide switch so that one or
more NeoPixel LEDs light up and stay on:

![Circuit Playground slide switch](/img/circuit-playground-switch.jpg)

With the slide switch toggled you can change modes by pressing the left and right buttons on the board.
The number of lit pixels is the mode number, one pixel for mode 1 up to all ten for mode 10, and a
pitch plays on each press:

![Circuit Playground buttons](/img/circuit-playground-buttons.jpg)

Toggle the switch back and the mode starts.

It's one mode at a time, so a sketch that wants both light and touch needs two boards. The buttons
and the switch only pick the mode. They never send MIDI, so if the Explorer shows nothing when you
press a button, that's expected.

<!-- map -->

## Start here

<!-- starters -->

## The helper

| | |
|---|---|
| `new CircuitPlayground(this)` | Connects by USB-name substring. The board's USB name depends on how it was flashed. The Explorer prints it. |
| `cpx.touch(i)`, `cpx.touchJustPressed(i)`, `cpx.anyTouch()` | The eight pads, index 0 to 7 as in the table above. Mode 1. |
| `cpx.light`, `cpx.sound` (0 to 1), `cpx.temperature` (°C), `cpx.sensor` (raw CC 1) | All three follow the same CC 1. Which one means anything depends on the mode the board is in. |
| `cpx.accel.x`, `.y`, `.z` | -1 to 1, one g is 1. Mode 6. |
| `cpx.mode` | `"touch"`, `"accel"`, `"sensor"`, `"notes"` or empty: the kind of traffic last recognised. |
| `cpx.pixels(r, g, b)`, `cpx.clear()` | All ten pixels one colour, for a board in mode 10. |
| `void touchPressed(int pad)`, `void touchReleased(int pad)`, `void accelChanged()` | Define any in your sketch and the helper calls it. The generic `noteOn` and `controlChange` work too. |

<!-- helper -->

## Try first

- Mode 2: a sketch whose background follows the room light. Cover the sensor with your hand.
- Mode 3: clap to spawn a shape. The value is loudness.
- Mode 6: a bouncy ball that rolls the way you tilt the board.
- Mode 1: eight touch pads, eight notes. Wire a fruit to one with a clip lead and play it.
- Mode 10: send notes at it from the Explorer's send panel and mix a colour on the pixels.

More on the [ideas page](@ideas#circuit-playground-georges-multi-tool-firmware).

## Projects for this board

The projects from the 2019 workshop, which used these boards with Web MIDI. They are being rebuilt in
`ports/` and land here as they finish.

### Colour mixer, mode 10

In mode 10 a sketch mixes colours on the onboard NeoPixels by sending note on messages to channels 1,
2 and 3 for red, green and blue. The device listens for status bytes 144, 145 and 146, note ons for
MIDI channels 1 to 3.

Because we're limited to two 7-bit bytes instead of a single 8-bit value there's a curious "bug" with
this approach. Can you identify it? Can you fix it?

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%ixer%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%ixer%/%ixer%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%ixer%/%ixer%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Simple synthesizer, mode 8

The sketch is the keyboard, the board's speaker is the voice. Every note on the sketch sends, the
board plays.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%ynth%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%ynth%/%ynth%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%ynth%/%ynth%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Quiz buzzer, mode 1

Boards as buzzers: who buzzed first? In 2019 this used mode 7, the tap. That sends nothing over MIDI,
so the buzzer is a touch pad in mode 1. Slap the pad.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%uzzer%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%uzzer%/%uzzer%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%uzzer%/%uzzer%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Morse code translator, mode 8 or mode 1

Two directions. Type a phrase and the board beeps it as Morse in mode 8. Or tap it on a touch pad in
mode 1 and the sketch decodes the dots and dashes. A Morse table:
[this gist](https://gist.github.com/lauri-kaariainen/8089926).

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%orse%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%orse%/%orse%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%orse%/%orse%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Fruit piano, mode 1

Mode 1, alligator clips and fruit (or anything conductive). Each pad is a note. The sketch plays it or
draws it.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%iano%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%iano%/%iano%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%iano%/%iano%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Thermometer, mode 4

Mode 4 sends degrees Celsius once a second. A very local weather app. An hour of readings is a graph.

<Tabs groupId="lang" queryString>
<TabItem value="p5" label="p5.js" default>

{/* include: ports/p5/%ircuit%hermo%/sketch.js */}

{/* /include */}

</TabItem>
<TabItem value="python" label="Python Mode">

{/* include: ports/python/%ircuit%hermo%/%hermo%.pyde */}

{/* /include */}

</TabItem>
<TabItem value="java" label="Java">

{/* include: ports/java/%ircuit%hermo%/%hermo%.pde */}

{/* /include */}

</TabItem>
</Tabs>

### Tactile flashcards, mode 1

Same wiring as the fruit piano, different payoff. Instead of a note, touching an object shows you its
name, and a key cycles the language. It lives inside the fruit piano sketch above: run it, press F, and
every pad becomes a word. L switches language. The word list is at the top of the sketch, so swap in
whatever is on the table.

## Without the helper

Channel 2 notes and CC 1 decoded inline, including the accelerometer burst. Under sixty lines, same stand-ins. Read [the three bytes, no helpers](@raw-intro) first.

<!-- raw -->
