---
title: "PCD 2026, New York: the workshop page"
slug: /talks/pcd-2026-nyc/
description: "The page attendees had open at Processing Community Day 2026, New York, October 3. The agenda, what to bring, the eighty minutes, and the day-of notes."
sidebar_label: "PCD 2026, the workshop page"
sidebar_position: 20261003.5
---

# More than Music with MIDI

<div className="talk-hero">
  <p className="talk-title">The workshop page</p>
  <p className="talk-meta">Processing Community Day 2026 · New York · October 3, 2026 · George Mandis</p>
</div>

This is the page attendees had open on the day, with its links pointed at the new site. It was the
home page of pcd2026.mand.is. [The entry](./2026-pcd-nyc.md) has the preview videos and the sources.

## What we're doing

MIDI is how electronic instruments have talked to each other since 1983. Every message is three
bytes, the protocol has no opinion about what they mean, and every operating system already speaks
it. That means a MIDI controller is really just a box that sends numbers, and you get to decide what
the numbers do. A joystick can drive a simulation. Sixteen arcade buttons can be a sequencer, a game
of Simon, or a door lock.

Every sketch comes three ways: p5.js in the browser with nothing to install, Python Mode in the
Processing IDE, and Java mode in the Processing IDE. Pick one and stay there, or switch. They read the
same.

The goal is simple: pick up a device and have it move something on your screen within five minutes.

## What to bring

- A device from the table. There are PipSqueak joysticks, Circuit Playgrounds, Midi Fighters, two
  Launchpads and two Trinkeys, or bring your own. If your computer sees it as a MIDI device, it will
  work. The PipSqueaks are here thanks to Masson at [useMidi](https://usemidi.com).
- Processing 4, installed before build time if you can. See [Processing, Java mode](/pick-your-tool/processing-java/).
- For the p5 side, a browser with Web MIDI: Chrome, Edge, Opera, Brave, or Firefox 108 and up. Safari
  doesn't have it.
- This site open on your phone, next to your laptop.
- The sketches, from [the workshop repo on GitHub](https://github.com/georgemandis/morethanmusic) (then named
  processing-community-day-2026-nyc-midi-workshop; the old address redirects). Clone it or download the ZIP.
  [Get the sketches](/pick-your-tool/processing-java/#get-the-sketches) has the steps.

## The 80 minutes

| Minutes | What | Where to look |
|---|---|---|
| 0–10 | The story: signals, three bytes, bananas, the devices on the table | [Introduction to MIDI](/start-here/introduction-to-midi/) |
| 10–20 | The Explorer, then project ideas | [The Explorer](/the-explorer/), [Project ideas](/examples/project-ideas/) |
| 20–70 | Build time | [Your device](/devices/), [Hello world](/examples/hello-world/) |
| 70–80 | Show and tell | below |

## The path through the site

1. What MIDI is and what a message looks like.
2. The Explorer, to see what a device actually sends.
3. The starter sketch for your device. Press Run.
4. Change it. Every starter marks the lines worth changing.
5. Build something small. There's a list of ideas for each device, smallest first.
6. Show and tell.

## Before you start

Install Processing 4, and Python Mode if you want it. Both are on [Pick your tool](/pick-your-tool/),
with the browser table for the p5 side and the p5.js web editor recipe.

## On the day

- Plug your device in before you press Run. Java's MIDI on macOS doesn't see devices plugged in after
  a sketch starts. If you plug in late, stop the sketch and run it again. The browser version of the
  Explorer doesn't have this limit.
- On Windows only one program at a time can hold a MIDI input. On macOS and Linux a browser tab and a
  sketch can usually share, but if one goes quiet, close the other.
- Every sketch prints the MIDI devices it found in the Processing console. When nothing happens,
  that's the first place to look.

## Show and tell

Nothing needs to be finished! Let's spend the last 10 minutes or so sharing what we built.

If it broke in the last five minutes, don't worry about it. Put the Explorer on screen and show what
your device sends.

## Take it home

- The helpers, starters, projects, Explorer, ports and demos are in the workshop repo:
  [github.com/georgemandis/processing-community-day-2026-nyc-midi-workshop](https://github.com/georgemandis/morethanmusic). Clone it or download the ZIP.
- The helpers are plain sketch tabs built on `javax.sound.midi`. Copy `MidiCore.pde` and the device's
  tab into any sketch and they work the same way. The p5 versions are one script tag.
- The PipSqueaks are from [useMidi](https://usemidi.com). Thanks to Masson for the hardware. Get one and
  set it up at [usemidi.com/configure](https://usemidi.com/configure.html).
- Everything the sketches use is listed in [References](/examples/references/).
