---
title: "A Zoom mute button from a Puck.js"
description: "The clicker from the 2017 talks, reflashed as a one-button Bluetooth keyboard that toggles your microphone. Twenty lines of Espruino, and a reminder that the Puck was once a MIDI instrument."
slug: /talks/2023-zoom-muter/
sidebar_label: "Zoom muter (2023)"
sidebar_position: 20230909
---

{/* generated from talks/2023-zoom-muter/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# A Zoom mute button from a Puck.js

The clicker from the 2017 talks, reflashed as a one-button Bluetooth keyboard that toggles your microphone. Twenty lines of Espruino, and a reminder that the Puck was once a MIDI instrument.

| | |
|---|---|
| When | September 9, 2023 |
| Where | george.mand.is |
| What | article |
| Article | [george.mand.is/2023/09/building-a-mute-button-toggler-for-zoom-with-espruino-and-puckjs](https://george.mand.is/2023/09/building-a-mute-button-toggler-for-zoom-with-espruino-and-puckjs/) |
| Repo | [github.com/georgemandis/espruino-zoom-muter](https://github.com/georgemandis/espruino-zoom-muter) |
| Video | [youtube.com/watch?v=KDszbcDRIL4](https://www.youtube.com/watch?v=KDszbcDRIL4) |

<iframe src="https://www.youtube-nocookie.com/embed/KDszbcDRIL4" title="A Zoom mute button from a Puck.js, george.mand.is" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What it is

The Puck.js that advanced my slides in 2017 sat in a drawer until a coworker had an idle thought.
The post from 2023-09-09 turns it into a Bluetooth keyboard that presses the Zoom mute shortcut when
the button goes down and presses it again when the button comes up. Hold to talk. "All-in-all,
about 20 lines of code."

It is on this timeline because of the paragraph in the middle. The post explains that a Bluetooth
device announces what kind of thing it is, and that MIDI is one of the things it can claim to be:
"I have (mostly undeserved) credit for contributing to the BLE MIDI module for the Espruino
ecosystem." That module is what let the Puck show up as a MIDI instrument in 2017, and the post
points back at the clicker's code and the talk playlist for anyone who wants to know why.

The future-improvements list suggests reusing "the single/double/triple click code I implemented
for the MIDI clicker" to give the muter modes for different meeting apps. That has not happened. The
muter is in the Make your own section of this site.

## Sources

- https://george.mand.is/2023/09/building-a-mute-button-toggler-for-zoom-with-espruino-and-puckjs/ (2023-09-09)
- https://www.espruino.com/BLE+MIDI
- https://github.com/georgemandis/espruino-zoom-muter , https://github.com/georgemandis/puck-js-midi-clicker
- YouTube KDszbcDRIL4 (embedded in the post)
