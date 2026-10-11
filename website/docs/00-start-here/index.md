---
title: Start here
slug: /
description: Plug a MIDI device in, see what it sends, make a sketch react. Nothing to install for the first path.
---

# More than Music with MIDI

A MIDI controller is a box that sends numbers. Three per message. MIDI dates from 1983, every
operating system speaks it today with no driver, and the numbers can mean whatever you want. A joystick
can steer a simulation. Sixteen arcade buttons can be a sequencer, a game of Simon, or a door lock.

This site is for anyone with a MIDI thing who wants it to do something. The examples are in p5.js
and Processing. [Something else](/pick-your-tool/something-else/) lists the other routes.

## Three bytes

<div className="bytes" aria-label="A MIDI message: three bytes">
  <div className="status"><b>90</b><span>status: note on, channel 1</span></div>
  <div className="data1"><b>3C</b><span>data 1: note 60, middle C</span></div>
  <div className="data2"><b>7F</b><span>data 2: velocity 127</span></div>
</div>

The status byte says what happened and on which channel. Note On is 144, Control Change is 176.
Data 1 says which note or which knob. Data 2 says how hard, or where the knob is, 0 to 127.

Buttons send notes. Knobs, sliders and sensors send control changes. That is most of it.
[Introduction to MIDI](./introduction-to-midi.md) has the whole table.

## Plug in

Plug the device in before you open anything. On macOS, Processing's Java only sees devices that were
there when the sketch started. The browser does not mind either way.

## Open the Explorer

[Open the Explorer](pathname:///explorer/web/) in Chrome, Edge, Opera or Brave and press `c`. The
browser asks for MIDI once. Touch the device. Every message shows up decoded, with the raw three
bytes next to it, and the device's exact name at the top. Keep that name. The helpers find the
device by it.

No Web MIDI in your browser? The Processing edition does the same thing from the IDE. [The
Explorer](/the-explorer/) page has both.

## Pick a tool

| | Install | Open |
|---|---|---|
| p5.js in the browser | nothing | [p5.js](/pick-your-tool/p5/) |
| Processing, Java | Processing 4 | [Processing Java](/pick-your-tool/processing-java/) |
| Processing, Python Mode | Processing 4 and the mode | [Python Mode](/pick-your-tool/processing-python/) |
| Node, plain JavaScript, Python, a microcontroller | depends | [Something else](/pick-your-tool/something-else/) |

Then open your [device page](/devices/). Each one has the message map and a starter sketch in all
three languages. Press Run, push something, change a line. The `change this` comments mark the lines
worth changing.

## Firefox and Safari

Safari has no Web MIDI, on macOS or iOS. Firefox 108 and later has it behind a site permission: the
first MIDI request offers to install it, accept and reload. iPhones and iPads have none. On any of those, take
the [Processing Java](/pick-your-tool/processing-java/) path. It needs no browser at all.

## No device yet

Every starter runs without one. PipSqueak: arrow keys and space. Midi Fighter: `1234` `qwer` `asdf`
`zxcv`. Circuit Playground: `1` to `8` and the mouse. Launchpad: click a cell, `c` clears. Anything
else: letters are notes, drag the mouse for a knob. Each device page lists its own. The Explorer has
fake devices: add `?fake=3` to its URL for a PipSqueak, `1` to `7` for the rest. [Devices](/devices/)
says where to buy the real ones.
