# Changelog

One version number across the three helpers (p5, Processing Java, Python Mode). `VERSION` is the source;
`p5/package.json`, `p5/jsr.json` and `processing-library/library.properties` carry the same number and
`release.sh` refuses to run when they drift. The date on a version's heading stamps every file in
that version's archives, so a rebuild of the same tree is byte-identical.

## 1.0.0 (2026-10-04, unreleased)

First packaged release. Everything below existed as drop-in tabs, modules and scripts for the Processing
Community Day NYC 2026 workshop; this is the same code with install paths.

- p5: `mtm-midi-helpers` on JSR (`@georgemandis/mtm-midi-helpers`) and npm. New ESM entry
  `midi-helpers.mjs` exporting `MidiCore`, `MidiMsg`, `MidiHelper`, `PipSqueak`, `MidiFighter`,
  `Launchpad`, `CircuitPlayground`, `AnyMidi`, `SlideTrinkey`, `RotaryTrinkey`. The classic single-tag
  bundle and per-device scripts are unchanged.
- Processing Java: `midihelpers` library (`import midihelpers.*;`), generated from the tabs, with seven
  examples. The sketch-level functions moved onto the class: `MidiCore.printMidiDevices()`,
  `MidiCore.midiInputs()`, `MidiCore.midiOutputs()`. Package-private members are public in the library.
  The drop-in tabs still work as before.
- Python Mode: the modules as a zip with an install README and `sketch.properties`.
- Hosted copies at `/mtm-midi-helpers/1.0.0/` and `/mtm-midi-helpers/latest/` on the site.
- CI runs the three suites, the library build, the sync check and the site build on every push.

Helpers themselves: no behaviour change since the workshop (2026-10-04).
