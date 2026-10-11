---
title: Teardown 2018, Portland
sidebar_label: "Teardown 2018"
date: 2018-05-11
date_end: 2018-05-13
venue: Teardown, by Crowd Supply
city: Portland, Oregon
kind: workshop
summary: The first workshop. Adafruit sent Circuit Playground Expresses, everyone flashed an Arduino sketch that turned theirs into a MIDI controller, and then we made web pages talk to them.
links:
  event: https://www.crowdsupply.com/teardown/portland-2018
---

## What happened

Teardown is Crowd Supply's hardware conference in Portland, and it was the right room for this.
The submission in the talk folder pitches the talk ("I believe MIDI + JavaScript is an amazing
combination for introducing web developers and beginning programmers to hardware hacking") and the
deck has a commit "for teardown 2018" on 2018-05-13. The workshop got its own site. Its repo's
commits are 2018-05-12 "initial commit", 2018-05-13 "ready to roll" and 2018-05-14 "source".

The agenda page says the Circuit Playground Expresses "have been provided courtesy of Adafruit",
that everyone needed the Arduino IDE to flash them, and that Chrome or Chromium was the browser,
"though it's in the pipeline for Firefox." Two Arduino sketches were handed out as zips: a MIDI
colour mixer that listened on channels 1 to 3 for red, green and blue, and a "Multi-MIDI Tool" with
eight modes. By the SPA workshop two months later the multi-tool had ten modes and a GitHub repo.

The project list for the afternoon: a basic synthesizer, a colour mixer, a quiz buzzer, a Morse code
translator, a fruit piano with alligator clips, and "real-world flash cards". The July post about
the second workshop says SPA "was only my second time trying this as a workshop," which makes this
the first.

The site was a VuePress build deployed to GitHub Pages at `georgemandis/teardown-midi-workshop`. It
is gone, and the Wayback Machine never captured it. The pages are re-hosted here from the source
markdown.

## Sources

- https://george.mand.is/talks/ : Teardown: Portland 2018, May 11 to 13, 2018
- https://george.mand.is/javascript-webmidi-tiny-computers ("I've led this most recently at LibertyjS 2019, Teardown 2018 and SPA Software in Pratice 2018")
- https://george.mand.is/2018/07/announcing-circuit-playground-midi-controller-multi-tool-v100-for-webmidi-workshops/ ("only my second time trying this as a workshop")
- Talk folder: `Teardown 2018 Submission.md`; `slidedeck/` git log 2018-05-13 "for teardown 2018"
- Workshop folder `teardown-webmidi-2018/`: git log, `deploy.sh`, `1-agenda.md`, `3-arduino-code.md`, `5-projects.md`
- GitHub Pages URL and archive.org checked 2026-10-04: 404, no snapshot
