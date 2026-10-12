# Arduino Code

Here is the Arduino source code for turning our Circuit Playgrounds into several different types of MIDI devices. We'll need to upload this code using the Arduino IDE software. To make sure our Circuit Playgrounds are being recognized as MIDI controllers by the browser, we can test with this CodePen:

- [https://codepen.io/georgemandis/pen/XqYNNN](https://codepen.io/georgemandis/pen/XqYNNN)

## MIDI Color Mixer

This code turns our Circuit Playground into a MIDI-based color mixer. The onboard Neopixels RGB LEDs are mixed to red, green and blue values which are set by sending messages on particular channels. The device is set to lisetn for status bytes from 144, 145 and 146 — MIDI channels 1-3.

There is a CodePen setup to test this code here:

- [https://codepen.io/georgemandis/pen/xjzXgd](https://codepen.io/georgemandis/pen/xjzXgd)

Download the source code:
- [https://midi.mand.is.s3.amazonaws.com/circuit-playground-midi-color-mixer.zip](https://midi.mand.is.s3.amazonaws.com/circuit-playground-midi-color-mixer.zip)


## Multi-MIDI Tool

This code turns our Circuit Playground into a very elaborate controller with 8 differents "modes" including:

- Converting capactive inputs to MIDI signals
- Converting the onbaord light sensor to MIDI signals
- Converting the onboard sound sensor to MIDI signals
- Relaying the temperature (in celsius) via a MIDI signal
- Sending a cascade of MIDI notes with variable speed
- Converting the accelerometer to MIDI signals
- Converting the accelerometer "tap" detetion to a MIDI signal
- Playing incoming MIDI notes over the internal speaker


Download the source code:
- [https://midi.mand.is.s3.amazonaws.com/circuit-playground-multi-midi.zip](https://midi.mand.is.s3.amazonaws.com/circuit-playground-multi-midi.zip)