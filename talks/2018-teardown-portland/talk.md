---
title: Teardown 2018, Portland
sidebar_label: "Teardown 2018"
date: 2018-05-11
date_end: 2018-05-13
venue: Teardown, by Crowd Supply
city: Portland, Oregon
kind: workshop
summary: The first workshop. Adafruit sent Circuit Playground Expresses, everyone flashed a sketch that turned theirs into a MIDI controller, then made web pages talk to it.
links:
  event: https://www.crowdsupply.com/teardown/portland-2018
---

## What happened

Teardown is Crowd Supply's hardware conference in Portland. The Circuit Playground Expresses were
provided by Adafruit. Everyone needed the Arduino IDE to flash them and Chrome or Chromium to run
the pages; Firefox was "in the pipeline". Two sketches were handed out: a MIDI colour mixer that
listened on channels 1 to 3 for red, green and blue, and a "Multi-MIDI Tool" with eight modes. By
the SPA workshop two months later the multi-tool had ten modes and a GitHub repo.

The afternoon's projects: a basic synthesizer, a colour mixer, a quiz buzzer, a Morse code
translator, a fruit piano with alligator clips, and flash cards.

The workshop site was a VuePress build on GitHub Pages. It is offline and the Wayback Machine never
captured it.

## Sources

- https://george.mand.is/talks/ : Teardown: Portland 2018, May 11 to 13, 2018
- https://george.mand.is/javascript-webmidi-tiny-computers ("I've led this most recently at LibertyjS 2019, Teardown 2018 and SPA Software in Pratice 2018")
- https://george.mand.is/2018/07/announcing-circuit-playground-midi-controller-multi-tool-v100-for-webmidi-workshops/ ("only my second time trying this as a workshop")
- Talk folder: `Teardown 2018 Submission.md`; `slidedeck/` git log 2018-05-13 "for teardown 2018"
- Workshop folder `teardown-webmidi-2018/`: git log, `deploy.sh`, `1-agenda.md`, `3-arduino-code.md`, `5-projects.md`
- GitHub Pages URL and archive.org checked 2026-10-04: 404, no snapshot
