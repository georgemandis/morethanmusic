---
title: Processing, Java mode
description: Install Processing 4, open a starter, press Run. The MIDI is javax.sound.midi, already inside Processing's Java.
sidebar_position: 2
---

# Processing, Java mode

No browser involved. Processing's Java ships `javax.sound.midi`, so there is nothing to add.

## Install Processing 4

1. Download Processing 4 from [processing.org/download](https://processing.org/download). It bundles
   its own Java.
2. Unzip and open it. On macOS, drag it to Applications first. The first launch may need a right-click,
   then Open.
3. Press Run on the empty sketch. A small grey window means you are ready.

Still on Processing 3.5.4? The sketches work there too.

## Get the sketches

The starters, helpers, Explorer and demos are in one repo:
[github.com/georgemandis/morethanmusic](https://github.com/georgemandis/morethanmusic).

```sh
git clone https://github.com/georgemandis/morethanmusic.git
```

No git? The green Code button on that page has Download ZIP. Unzip it anywhere and open sketches
from `starters/java/` with File → Open.

## The helpers

Each starter folder already carries the two tabs it needs, `MidiCore.pde` and the device's tab. Copy
those two into any sketch of your own and they work the same way. There is also a proper library,
`midihelpers`, for Sketch → Import Library. [Helpers](/helpers/) has both.

## Plug in, then Run

Java's MIDI on macOS lists devices once, at start. A device plugged in after Run is invisible until
you stop and run again. The Explorer carries a small jar (CoreMidi4J) that fixes this for itself.
The starters do not carry it.

Every sketch prints the MIDI devices it found in the console. When nothing happens, that is the
first place to look. [Troubleshooting](/troubleshooting/) has the rest.

## Open a starter

Your [device page](/devices/) names the folder. [Hello world](/examples/hello-world/) walks through
the PipSqueak one line by line.
