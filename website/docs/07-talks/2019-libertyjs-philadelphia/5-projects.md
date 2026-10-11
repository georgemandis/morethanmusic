---
sidebar_label: "Let's Build Things!"
sidebar_position: 5
slug: /talks/2019-libertyjs-philadelphia/projects/
---

{/* copied from talks/2019-libertyjs-philadelphia/site/5-projects.md by `node website/refresh.mjs talks`; edit the source, not this */}

:::note
As given in 2019, kept as it was. Only the links and images were pointed at this site. [The entry](../2019-libertyjs-philadelphia.md) says where it was given and why.
:::

# Let's Build Things!

## Hello World

Let's familiarize ourselves with the API by learning how to:

- Request MIDI access from the browser
- Traverse the available devices
- Setup listeners for devices registered as MIDI inputs
- Send messages to devices registered as MIDI outputs

Here is a CodePen to get started:  
[https://codepen.io/georgemandis/pen/erKKNN](https://codepen.io/georgemandis/pen/erKKNN)


## Color Mixer

Using **Mode #10** on our Circuit Playgrounds we'll manipulate the onboard RGB NeoPixel LEDs to mix colors using a web interface. We'll do this by sending "noteOn" messages to channels 1-3 for red, green and blue values respectively. In this mode the device is set to listen for status bytes from 144, 145 and 146 — "noteOn" messages for MIDI channels 1-3.

There is a CodePen setup to test this code here:  
[https://codepen.io/georgemandis/pen/xjzXgd](https://codepen.io/georgemandis/pen/xjzXgd)

Because we're limited to two 7-bit messages instead of a single 8-bit message there's a curious "bug" with this approach... Can you identify it? Can you fix it?


## Simple Synthesizer

For this project we'll build a basic synthesizer using WebMIDI, a web-based interface and the onboard speaker in our Circuit Playground using **Mode 8**.


## Quiz Buzzer

Using **Mode 7** let's turn our Circuit Playgrounds into buzzers that let a contestant "buzz-in" on a quiz show. 

Can we connect multiple controllers and detect who's buzzes in first?

## Morse Code Translator

This project can take two approaches. We can attempt to translate "taps" into Morse Code using **Mode 7** or take phrases from a web interface and translate them into morse code signals using the onboard speaker.

Here is a helpful Gist that demonstrates a quick and simple Morse Code translator:  
[gist.github.com/lauri-kaariainen/8089926](https://gist.github.com/lauri-kaariainen/8089926)

## Fruit Piano

Using **Mode 1** and alligator clips and fruit (or any conductive material!) we'll build an "alterantive" piano.

## Thermometer

Using **Mode 4** we can get the temperature in celsius using the onboard thermometer. Using this can we make a very localized "weather" app? If you're feeling ambitious, can you make it a self-contained application using [Electron](https://electronjs.org/)?

## Tactile Flash Cards

Using principles from the previous Fruit Piano project, let's explore a non-musical application for this same setup. Instead of playing notes when a piece of fruit is touched, what if the browser showed you a word representing the object? Could you translate that word into multiple languages and turn this interface into a sort of "tactile flashcard" for language learning?

## More Ideas

For most of these projects you can start by looking at this starter code on CodePen:
[https://codepen.io/georgemandis/pen/erKKNN](https://codepen.io/georgemandis/pen/erKKNN)


Or alternately on Glitch:  
[http://glitch.com/~webmidi-starter](http://glitch.com/~webmidi-starter)


You can also look at lots of examples via links in the [resources & documentation](./references.md) section.
