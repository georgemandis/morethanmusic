---
title: "The demos"
description: "The things on the table. Twenty-odd small web pages, each wired to one controller, that did the talking in every 2017 and 2018 talk."
slug: /talks/2017-the-demos/
sidebar_label: "The demos (2017)"
sidebar_position: 20170729
---

{/* generated from talks/2017-the-demos/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# The demos

The things on the table. Twenty-odd small web pages, each wired to one controller, that did the talking in every 2017 and 2018 talk.

| | |
|---|---|
| When | July 29, 2017 |
| Where | the demos folder |
| What | demo |
| Demos | [georgemandis.github.io/cellular-automata-javascript-midi](https://georgemandis.github.io/cellular-automata-javascript-midi/) |

## The idea

The talk was a sandwich: ten minutes on what MIDI is, ten on what a message looks like in
JavaScript, then demos until the time ran out. The demos were served from one folder so they could
share a `js` and `css` folder. The folder's `index.html`, a grid of grey tiles, was the launcher.

## What was on the table

The tiles in `demos/index.html`, in order, with the folder each one lives in and the date its repo
was created. The repos were pushed to GitHub as `georgemandis/<name>`. Most are private or renamed
now, so they are named, not linked.

| Tile | Folder | Repo | First commit |
|---|---|---|---|
| Controller Explorer | `midi-exploring-controller` | midi-controller-explorer | 2017-07-29 |
| Simple Synth | `midi-simple-synth` | midi-simple-synth | 2017-07-29 |
| Web Audio + Visuals | `controlchange-web-synth-audio` | midi-controlchange-web-synth-audio | 2017-07-29 |
| CSS Filters | `midi-css-filter-mixer` | midi-lpd8-css-filter-mixer | 2017-07-29 |
| Motion Color Mixer | `midi-hot-hand-color-control` | midi-hot-hand-color-controller | 2017-07-29 |
| Motion Color Game | `midi-hand-game` | midi-hand-game | 2017-07-29 |
| Generative Automata | `midi-launchpad-generative-automata` | [cellular-automata-javascript-midi](https://github.com/georgemandis/cellular-automata-javascript-midi) | 2017-10-02 |
| Goonies Organ | `midi-goonies-organ` | midi-goonies-organ | 2017-07-29 |
| LPD8 Color Mixer | `midi-color-mixer` | midi-lpd8-color-mixer | 2017-07-29 |
| WebRTC Symphony I and II | `webrtc-symphony` | websocket-webrtc-symphony | 2017-07-29 |
| Flash Cards | `midi-tactile-flashcards` | none | not in git |
| Launchpad Maze | `midi-launchpad-maze` | midi-launchpad-mk2-maze-treasure | 2017-07-03 |
| Launchpad Draw | `midi-launchpad-draw` | midi-launchpad-draw | 2017-07-29 |
| Bouncing Balls | `midi-launchpad-balls` | midi-launchpad-mk2-maze-treasure | 2017-07-03 |
| Poetry Box | `midi-poetry-box` | midi-poetry-box | 2017-07-29 |
| Whack-a-Mole | `midi-lpd8-whack-a-mole` | midi-lpd8-whack-a-mole | 2017-07-29 |
| Go (Boardgame) | `midi-launchpad-go`, `midi-launchpad-mk2-go` | [midi-launchpad-mk2-go](https://github.com/georgemandis/midi-launchpad-mk2-go) | 2017-07-29, 2017-11-01 |

Not on the grid but in the folder: `midi-morse-code` (2017-11-01), `midi-permission-demo` (the
browser's permission prompt), `controlchange-web-audio-detune` (2017-07-02, the oldest repo of the
lot), `pitch-to-midi`, `midi-light-sensor`, `teensy-midi-identity-2` (a Teensy sketch with a custom
USB descriptor so it shows up under its own name), and `midi-jsfoo-workshop`.

## A few of them

The Websocket Symphony opened every 2017 talk. Everyone joined a wifi network called Sputnik,
opened sputnik.local, and each phone became a note. Symphony II spread the tracks of a MIDI file
across the room.

The Hot Hand is a ring with three accelerometers that Source Audio sells to guitarists. It became
the Motion Color Mixer and the Motion Color Game.

The Goonies Organ came from an idea about escape rooms: a skull, a treasure, a photo of the skeleton
organ, and a sheet of music drawn with VexFlow.

The Controller Explorer is the one that lasted. Select an input, show the numbers. It is
[the Explorer](/the-explorer/) on this site.

The deck itself was a demo. A Puck.js sent a control change over Bluetooth MIDI for a single, double
or triple click, and a foot controller did the rest. The clicker's code is at
[puck-js-midi-clicker](https://github.com/georgemandis/puck-js-midi-clicker).

## Sources

- Talk folder: `demos/index.html`, `demos/README.md`, each `demos/*/.git` log and remote, `midi-talk-notes-ideas.taskpaper`, `MMTM Talk Notes from Russia 2017.txt`, `notes/jsfoo-conversation-notes-outline.md`, `slide-deck-breakdown.html` (2017-06-29)
- https://george.mand.is/javascript-webmidi-tiny-computers (the clicker: "It can send 3 different MIDI control change messages depending on the type of click: single, double or triple")
- GitHub status checked 2026-10-04
