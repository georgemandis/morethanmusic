---
title: "A Zoom mute button from a Puck.js"
description: "The clicker from the 2017 talks, reflashed as a one-button Bluetooth keyboard that toggles the microphone. Twenty lines of Espruino."
slug: /talks/2023-zoom-muter/
sidebar_label: "Zoom muter (2023)"
sidebar_position: 20230909
---

{/* generated from talks/2023-zoom-muter/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# A Zoom mute button from a Puck.js

The clicker from the 2017 talks, reflashed as a one-button Bluetooth keyboard that toggles the microphone. Twenty lines of Espruino.

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

The Puck.js that advanced the slides in 2017, reflashed as a Bluetooth keyboard: press to send the
Zoom mute shortcut, release to send it again. Hold to talk. "All-in-all, about 20 lines of code."

A Bluetooth device announces what kind of thing it is, and MIDI is one of the things it can claim to
be. The BLE MIDI module for Espruino is what let the Puck show up as an instrument in 2017. The muter
is under [Make your own](/make-your-own/puck-js/).

## Sources

- https://george.mand.is/2023/09/building-a-mute-button-toggler-for-zoom-with-espruino-and-puckjs/ (2023-09-09)
- https://www.espruino.com/BLE+MIDI
- https://github.com/georgemandis/espruino-zoom-muter , https://github.com/georgemandis/puck-js-midi-clicker
- YouTube KDszbcDRIL4 (embedded in the post)
