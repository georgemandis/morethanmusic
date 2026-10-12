---
title: A Zoom mute button from a Puck.js
sidebar_label: "Zoom muter (2023)"
date: 2023-09-09
venue: george.mand.is
kind: article
summary: The clicker from the 2017 talks, reflashed as a one-button Bluetooth keyboard that toggles the microphone. Twenty lines of Espruino.
video: https://www.youtube.com/watch?v=KDszbcDRIL4
links:
  article: https://george.mand.is/2023/09/building-a-mute-button-toggler-for-zoom-with-espruino-and-puckjs/
  repo: https://github.com/georgemandis/espruino-zoom-muter
  video: https://www.youtube.com/watch?v=KDszbcDRIL4
---

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
