---
sidebar_label: "Our Circuit Playgrounds"
sidebar_position: 3
slug: /talks/2019-libertyjs-philadelphia/circuit-playground/
---

{/* copied from talks/2019-libertyjs-philadelphia/site/3-circuit-playground.md by `node website/refresh.mjs talks`; edit the source, not this */}

:::note
The 2019 workshop site, kept as it was. Links and images point here now. [The entry](../2019-libertyjs-philadelphia.md) has the context.
:::

# Our Circuit Playgrounds
Code has been uploaded to our Circuit Playground using the Arduino software to turn them into MIDI controllers! They are somewhat elaborate controllers with 10 differents "modes" including:

- **Mode 1:** Converting capactive inputs to MIDI signals
- **Mode 2:** Converting the onbaord light sensor to MIDI signals
- **Mode 3:** Converting the onboard sound sensor to MIDI signals
- **Mode 4:** Relaying the temperature (in celsius) via a MIDI signal
- **Mode 5:** Sending a cascade of random MIDI notes with variable speed
- **Mode 6:** Converting the accelerometer X/Y/Z parameters to MIDI signals
- **Mode 7:** Converting the accelerometer "tap" detetion to a MIDI signal
- **Mode 8:** Playing incoming MIDI notes over the internal speaker
- **Mode 9:** Play random notes over the internal speaker (non-MIDI mode)
- **Mode 10:** Mix RGB colors with the onboard LEDs using incoming MIDI signals

## Changing Modes

To change or view the current mode your Circuit Playground is in toggle the slide switch so that one or more NeoPixel LEDs lights up and stays on:

![Circuit Playground Slide Switch](/img/talks/2019-libertyjs-philadelphia/circuit-playground-switch.jpg)

With the slide switch toggled you should be able to change modes by pressing the left and right buttons on your device. As the mode increases or decreases the ring of NeoPixels will light up accordingly and a pitch should play:

![Circuit Playground Buttons](/img/talks/2019-libertyjs-philadelphia/circuit-playground-buttons.jpg)

To begin utilizing the mode you've selected toggle the switch back to its original state. Your device should begin functioning per your selected mode as described above!

## Hacking Modes

Although it's outside the scope of this workshop, you can download the source code that turns our Circuit Playgrounds into these multi-modal MIDI devices here:

[https://github.com/georgemandis/circuit-playground-midi-multi-tool](https://github.com/georgemandis/circuit-playground-midi-multi-tool)

You'll need to download and use the [Arduino IDE software](https://www.arduino.cc/) to flash your code back to the device. Some familiarity with C would also be helpful.
