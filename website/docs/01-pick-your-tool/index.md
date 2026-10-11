---
title: Pick your tool
slug: /pick-your-tool/
description: p5.js in the browser, Processing in Java or Python Mode, or something else. Same examples, same helper API.
---

# Pick your tool

Every example on this site comes three ways, and they read the same. Pick one and stay there, or
switch halfway. The [helpers](/helpers/) have the same names in all three: `stick.x`, `mf.pressed(3)`,
`pad.justPressed(x, y)`.

| | Install | Browser | Pick it when |
|---|---|---|---|
| [p5.js in the browser](./p5.md) | nothing | Chrome, Edge, Opera or Brave. Firefox after one permission | you want something on screen in two minutes, or a link to share |
| [Processing, Java](./processing-java.md) | Processing 4 | none needed | you have Processing already, or Safari is your only browser |
| [Processing, Python Mode](./processing-python.md) | Processing 4 and the mode | none needed | you think in Python |
| [Something else](./something-else.md) | depends | | the device should talk to Node, plain JavaScript, Python, or you are building the device |

Two differences to know about. The browser asks permission for MIDI, and only after you click
something, so every p5 sketch waits for a click. Java opens the port when the sketch calls
`connect()`, no questions, but on macOS it only lists the devices that were plugged in before Run.
Plug in first.
