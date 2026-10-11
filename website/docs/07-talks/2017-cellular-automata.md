---
title: "Cellular automata on a Launchpad"
description: "A blog post, a two-minute video and a repo. Wolfram's Rule 30 running across a Novation Launchpad MK2, with the bottom row as the seed you can tap."
slug: /talks/2017-cellular-automata/
sidebar_label: "Cellular automata (2017)"
sidebar_position: 20171002
---

{/* generated from talks/2017-cellular-automata/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# Cellular automata on a Launchpad

A blog post, a two-minute video and a repo. Wolfram's Rule 30 running across a Novation Launchpad MK2, with the bottom row as the seed you can tap.

| | |
|---|---|
| When | October 2, 2017 |
| Where | george.mand.is |
| What | article |
| Article | [george.mand.is/2017/10/playing-with-cellular-automata-javascript-and-midi](https://george.mand.is/2017/10/playing-with-cellular-automata-javascript-and-midi/) |
| Video | [youtube.com/watch?v=tlUewcmKpAg](https://www.youtube.com/watch?v=tlUewcmKpAg) |
| Repo | [github.com/georgemandis/cellular-automata-javascript-midi](https://github.com/georgemandis/cellular-automata-javascript-midi) |
| Demos | [georgemandis.github.io/cellular-automata-javascript-midi](https://georgemandis.github.io/cellular-automata-javascript-midi/) |

<iframe src="https://www.youtube-nocookie.com/embed/tlUewcmKpAg" title="Cellular automata on a Launchpad, george.mand.is" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What it is

Tero Parviainen gave a talk at FullStack London 2017 on generative music with JavaScript. One slide
used a one-dimensional cellular automaton to pick notes. I found it captivating and immediately
thought of a way to use it in my own talk, so I put it on a Launchpad MK2. The rules can be changed
in real time from input fields on the page. The default is Wolfram's Rule 30. Tap a cell to turn it
on or off; tapping the bottom row changes the next generation. The bottom-right button, labelled
"Record / Arm" on the hardware, clears the seed row.

I will confess, as the post does, that "the demo doesn't do much besides provide something pretty to
look at for a couple minutes." It is still my favourite thing from that year. The post also points at
Chris Wilson's Conway's Game of Life demo for Web MIDI, which does the same trick on an older
Launchpad, and admits his did not work with my newer one.

The repo is public and the demo page is still live. The demo's first commit is 2017-10-02, the same
day as the post and the video. It went into the deck as "Generative Automata" and later into the
CSS-Tricks article as the first example of what you can build. It came back in 2026 as the Game of
Life on a Midi Fighter, which is the [PCD 2026 entry's](./2026-pcd-nyc.md) problem.

## Sources

- https://george.mand.is/2017/10/playing-with-cellular-automata-javascript-and-midi/ (2017-10-02)
- Talk folder: `demos/midi-launchpad-generative-automata/` git log, initial commit 2017-10-02; `demos/index.html` lists "Generative Automata"
- YouTube tlUewcmKpAg, uploaded 2017-10-02, 103 seconds
- https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/ , "What kind of things can I build?"
