---
title: "Dip Your Toes Into Hardware With WebMIDI"
description: "The talk as an article. What MIDI and WebMIDI are, why you would bother, the three bytes, the hardware, and bananas wired to a Circuit Playground."
slug: /talks/2019-css-tricks-article/
sidebar_label: "CSS-Tricks article (2019)"
sidebar_position: 20191212
---

{/* generated from talks/2019-css-tricks-article/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# Dip Your Toes Into Hardware With WebMIDI

The talk as an article. What MIDI and WebMIDI are, why you would bother, the three bytes, the hardware, and bananas wired to a Circuit Playground.

| | |
|---|---|
| When | December 12, 2019 |
| Where | CSS-Tricks |
| What | article |
| Article | [css-tricks.com/dip-your-toes-into-hardware-with-webmidi](https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/) |
| Demos | [codepen.io/georgemandis/pen/XqYNNN](https://codepen.io/georgemandis/pen/XqYNNN) |

## What it is

Chris Coyier's CSS-Tricks published this on December 12, 2019. It is the talk written down, in the
order the talk had settled into by then: what MIDI and WebMIDI are, why you would want to do this
("it exercises a different part of your brain"), what you can build (the cellular automata, Go,
whack-a-mole, mixing colours by waving your hand), what you need (a controller and a browser, with
Web MIDI at about 73 percent of browsers, nearly all of it Chromium), a hello world, the anatomy of
a message, and then the hardware: a Korg nanoKey2, an Akai LPD8, the Hot Hand, a Launchpad, a
Circuit Playground Classic, and the bananas.

The hello world is the same CodePen the workshops used, "WebMIDI Basic Test". The summary makes the
case I had been making from stages for two years: WebMIDI is the lowest-friction way into hardware
from a web page, because the API is tiny and the protocol does not care what you mean by the
numbers.

The midi.mand.is landing page points here under the heading "The Article": "For an in-depth look at
the WebMIDI API and how it works please read the article I wrote for CSS Tricks."

## Sources

- https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/ , by George Mandis, December 12, 2019
- https://george.mand.is/javascript-webmidi-tiny-computers ("The Article")
- https://codepen.io/georgemandis/pen/XqYNNN (also linked from every workshop site's "WebMIDI Code" page)
