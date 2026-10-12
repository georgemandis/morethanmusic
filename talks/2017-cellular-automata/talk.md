---
title: Cellular automata on a Launchpad
sidebar_label: "Cellular automata (2017)"
date: 2017-10-02
venue: george.mand.is
kind: article
summary: A blog post, a two-minute video and a repo. Wolfram's Rule 30 across a Novation Launchpad MK2, with the bottom row as the seed you can tap.
video: https://www.youtube.com/watch?v=tlUewcmKpAg
links:
  article: https://george.mand.is/2017/10/playing-with-cellular-automata-javascript-and-midi/
  video: https://www.youtube.com/watch?v=tlUewcmKpAg
  repo: https://github.com/georgemandis/cellular-automata-javascript-midi
  demos: https://georgemandis.github.io/cellular-automata-javascript-midi/
---

## What it is

Tero Parviainen's FullStack talk used a one-dimensional cellular automaton to pick notes. This puts
one on a Launchpad MK2. The rules can be changed from input fields on the page; the default is Rule
30. Tap a cell to turn it on or off, tap the bottom row to change the next generation's seed, and
the bottom-right button clears it. The post also points at Chris Wilson's Game of Life for Web MIDI
on an older Launchpad.

The repo and the demo page are still up. It went into the deck as "Generative Automata", into the
CSS-Tricks article, and came back in 2026 as the Game of Life on a Midi Fighter at
[PCD 2026](./2026-pcd-nyc.md).

## Sources

- https://george.mand.is/2017/10/playing-with-cellular-automata-javascript-and-midi/ (2017-10-02)
- Talk folder: `demos/midi-launchpad-generative-automata/` git log, initial commit 2017-10-02; `demos/index.html` lists "Generative Automata"
- YouTube tlUewcmKpAg, uploaded 2017-10-02, 103 seconds
- https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/ , "What kind of things can I build?"
