---
title: Something else
description: The device does not care what reads it. Routes outside Processing and p5, and where they stand.
sidebar_position: 4
---

# Something else

The device does not care what is listening. Anything that can open a MIDI port gets the same three
bytes. These are the routes George has used. The examples for them are not cleaned up yet; the
talks they were built for link to what exists.

## Plain JavaScript, no p5

Web MIDI is a browser API, not a p5 one. `navigator.requestMIDIAccess()` and an `onmidimessage`
handler is the whole thing. The 2019 CSS-Tricks article walks through it:
[Dip Your Toes Into Hardware With WebMIDI](https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/).
The p5 helper's MIDI plumbing, `MidiCore` inside `midi-helpers.js`, is plain JavaScript too and runs
without p5 on the page.

Two libraries George has used for the plain-JavaScript demos: [WebMidi.js](https://github.com/djipco/webmidi),
which wraps the API with named notes and events, and [MIDIVal](https://midival.github.io/), written in
TypeScript. The browser support table is at [caniuse.com/midi](https://caniuse.com/midi). The shims
and plugins from the 2017 talks, which stood in for browsers without Web MIDI, are not needed for
Chrome, Edge or Firefox now.

## Node

The demos from the 2017 talks ran Node servers next to the browser, reading the device with the
`midi` and `easymidi` packages from npm. They are listed, as given, under
[Talks and workshops](/talks/).

## Python outside Processing

CPython reads MIDI with `mido`. Nothing here yet beyond the Python Mode helpers, which are Jython
and will not import into CPython as they are.

## Building the device

The other direction: a board that reads a sensor and sends the three bytes itself. That is
[Make your own](/make-your-own/).
