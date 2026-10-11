---
title: About
slug: /about/
description: Why this site exists, who to thank, and how to add a device, a board or a fix.
sidebar_position: 9
---

# About

## Why this exists

MIDI is three numbers. Buttons send notes, everything else sends control changes, and nothing in the
protocol says the numbers have to be about music. George has been making that point from stages since
2017, first with JavaScript and tiny computers, then as workshops with a Circuit Playground on every
desk, then in 2026 as a Processing workshop. [Talks and workshops](/talks/) has every one of them.

Each time, the kit was built for one day. Three of the workshop sites are offline now and live on
here only as copies. This one is meant to stay up: the Explorer at a stable URL, a page per device, the helpers as installable packages, and the
examples grouped by what they teach. If you bought a MIDI thing and want it to do something, this is
the page to start from. [Start here](/).

## Thanks

- Masson at [useMidi](https://usemidi.com), for the PipSqueaks on the table at Processing Community
  Day 2026.
- Processing Community Day NYC 2026, at NYU ITP, for the room.

## Contribute

The site, helpers, devices, examples and firmware pointers live in one repo.

- A device: copy `devices/_template/`, fill the message map from
  [the Explorer](/the-explorer/), add a photo, open a pull request.
  [devices/CONTRIBUTING.md](pathname:///devices/CONTRIBUTING.md) has the fields.
- A board: [Make your own](/make-your-own/) lists the firmware, one folder each in `firmware/`, with a
  README that has the message map and the flash steps.
- A fix: generated pages say which source file they come from. Edit the source, not the page. The
  rest are plain Markdown under `website/docs/`.

## Licence

Code is MIT. Text, photos and the talk material are CC BY 4.0: reuse them with a credit to George
Mandis and a link to this site. Both licences are in the repo as
[LICENSE](https://github.com/georgemandis/morethanmusic/blob/main/LICENSE) and
[LICENSE-CONTENT.txt](https://github.com/georgemandis/morethanmusic/blob/main/LICENSE-CONTENT.txt).

## Who

George Mandis. [george.mand.is](https://george.mand.is).
