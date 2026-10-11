# More than Music with MIDI

MIDI is three bytes, and every operating system speaks it with no driver. A MIDI controller is a box
that sends numbers, and the numbers can mean whatever you want. This repo is the site and the kit
behind https://morethanmusic.dev: the MIDI Explorer, helpers for p5.js, Processing Java and Python Mode, a device
catalog, examples, firmware for making your own device, and the talks and workshops behind it since
2017.

Start at https://morethanmusic.dev/. Plug a device in, open the Explorer, pick a tool.

## What is here

| Folder | What |
|---|---|
| `website/` | the site. Docusaurus; `website/README.md` says how it is built and checked |
| `explorer/` | the MIDI Explorer, Processing and web editions. See what a controller sends, send something back |
| `midi-helpers/` | the helpers: `java/` tabs and a Processing library, `python/` modules, `p5/` scripts and an npm/JSR package |
| `devices/` | the device catalog as data. One folder per device; the site pages are generated from it |
| `starters/` | one short sketch per device in Java, Python Mode and p5, and raw versions with no helper |
| `projects/` | the ten PipSqueak ideas built out, each in all three |
| `ports/` | bigger sketches: Launchpad automata and marquee, Midi Fighter sequencer and fireworks, Circuit Playground projects |
| `firmware/` | turning boards into MIDI devices: Trinkeys, Puck.js, Arduino MIDIUSB, the Circuit Playground multi-tool |
| `talks/` | every talk and workshop since 2017, with sources, transcripts and the old workshop sites as they were |
| `slides/` | the Processing Community Day 2026 deck, itself a Processing sketch |
| `grid-controllers/`, `pipsqueak/`, `launchpad-*/`, `midi-fighter/`, `pipsqueak-grayscott/` | the p5 demos the ports came from |

## Run it

Processing: File, Open, a `.pde` or `.pyde` under `starters/`. Plug the device in first. Run.

p5: serve the repo over http from its root, say `python3 -m http.server 8765`, and open
`http://localhost:8765/starters/p5/pipsqueak/`. Click once to connect.

The site: `cd website && npm install && npm start`. `./build-site.sh` builds it the way the host
serves it and `website/check-links.sh` checks every page, redirect and embed.

## Contribute

- A device: copy `devices/_template/`, fill the message map from the Explorer, add a photo, open a pull
  request. `devices/CONTRIBUTING.md` has the fields.
- A board: `firmware/README.md`.
- A fix: generated pages say which source file they come from. Edit the source.

This repo is mirrored from a private working copy, one commit per publish. Pull requests here are
merged by hand into the working copy and published back; nothing is lost in between.

## Licence

Not stated yet. Until it is, the code and text are George Mandis's; ask before reusing beyond reading.

## Where it was

The Processing Community Day 2026 workshop site, pcd2026.mand.is, redirects here. Its page is
https://morethanmusic.dev/talks/pcd-2026-nyc/.
