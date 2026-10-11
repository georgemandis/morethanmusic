---
title: SPA Software in Practice 2018, London
sidebar_label: "SPA 2018"
date: 2018-07-02
date_end: 2018-07-04
venue: SPA Software in Practice, at the British Computer Society
city: London, UK
kind: workshop
summary: The second workshop, and the one that produced the Circuit Playground MIDI Multi-Tool v1.0.0. Ten modes, a banana piano, and a thermometer that reports over MIDI.
links:
  repo: https://github.com/georgemandis/circuit-playground-midi-multi-tool
  event: https://www.spaconference.org/spa2018/
---

## What happened

"Yesterday I led a WebMIDI workshop for the SPA Software in Practice 2018 conference at the British
Computer Society in London." That post is dated 2018-07-03, so the workshop was July 2, the first
day of the conference. The deck has "updated slides for SPA London 2018" and "last minute updates to
slides" on 2018-07-02, and the workshop site's repo was created the same day.

This is where the Arduino sketch grew up. The post announces the Circuit Playground MIDI Controller
Multi-Tool v1.0.0 on GitHub, with modes for "capacitive touch sensors, accelerometers, lights,
thermometers and others." The site's device page lists all ten: capacitive touch to MIDI, light
sensor, sound sensor, temperature in celsius, a cascade of random notes, accelerometer X/Y/Z, tap
detection, playing incoming notes on the speaker, random notes with no MIDI at all, and RGB mixing on
the NeoPixels from incoming messages. You change mode with the slide switch and the two buttons.
The project page assigns a mode to each project, and asks a question I still like: "Because we're
limited to two 7-bit messages instead of a single 8-bit message there's a curious 'bug' with this
approach... Can you identify it? Can you fix it?"

The post is honest about the day: "It was only my second time trying this as a workshop and I'm
mostly happy with how it went. The attendees were enthusiastic about it and impressed me with some of
the projects they were able to make in the time we had."

The site was deployed to GitHub Pages at `georgemandis/spa2018-midi-workshop`. The LibertyJS site
a year later was deployed to the same repo, so this version was overwritten there before the whole
thing went offline. The pages are re-hosted here from the source markdown.

## Sources

- https://george.mand.is/2018/07/announcing-circuit-playground-midi-controller-multi-tool-v100-for-webmidi-workshops/ (2018-07-03)
- https://george.mand.is/talks/ : SPA Software in Practice, July 2 to 4, 2018, London
- Talk folder: `slidedeck/` git log 2018-07-02 (two commits)
- Workshop folder `spa2018-webmidi-2018/`: git log 2018-07-02 to 2018-07-04, `deploy.sh`, `3-circuit-playground.md`, `5-projects.md`
- Workshop folder `libertyjs-webmidi-2019/deploy.sh` pushes to `spa2018-midi-workshop.git`
- https://github.com/georgemandis/circuit-playground-midi-multi-tool (public)
