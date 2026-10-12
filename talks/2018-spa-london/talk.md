---
title: SPA Software in Practice 2018, London
sidebar_label: "SPA 2018"
date: 2018-07-02
date_end: 2018-07-04
venue: SPA Software in Practice, at the British Computer Society
city: London, UK
kind: workshop
summary: The second workshop, and the one that took the Circuit Playground MIDI Multi-Tool to 1.0.0. Ten modes, a banana piano, and a thermometer that reports over MIDI.
links:
  repo: https://github.com/georgemandis/circuit-playground-midi-multi-tool
  event: https://www.spaconference.org/spa2018/
---

## What happened

A one-day workshop at the British Computer Society on July 2, the first day of the conference.
The Circuit Playground MIDI Multi-Tool went to v1.0.0 on GitHub for it, with ten modes: capacitive
touch to MIDI, light sensor, sound sensor, temperature, a cascade of random notes, accelerometer
X/Y/Z, tap detection, playing incoming notes on the speaker, random notes with no MIDI at all, and
RGB mixing on the NeoPixels from incoming messages. The slide switch and the two buttons change
mode.

The projects page assigns a mode to each project and leaves one puzzle open: "Because we're limited
to two 7-bit messages instead of a single 8-bit message there's a curious 'bug' with this approach...
Can you identify it? Can you fix it?"

The site was deployed to GitHub Pages. The LibertyJS site a year later overwrote it at the same
address, and both are offline now.

## Sources

- https://george.mand.is/2018/07/announcing-circuit-playground-midi-controller-multi-tool-v100-for-webmidi-workshops/ (2018-07-03)
- https://george.mand.is/talks/ : SPA Software in Practice, July 2 to 4, 2018, London
- Talk folder: `slidedeck/` git log 2018-07-02 (two commits)
- Workshop folder `spa2018-webmidi-2018/`: git log 2018-07-02 to 2018-07-04, `deploy.sh`, `3-circuit-playground.md`, `5-projects.md`
- Workshop folder `libertyjs-webmidi-2019/deploy.sh` pushes to `spa2018-midi-workshop.git`
- https://github.com/georgemandis/circuit-playground-midi-multi-tool (public)
