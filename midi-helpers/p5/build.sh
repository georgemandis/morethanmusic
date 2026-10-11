#!/bin/bash
# Builds the standalone p5 scripts: each device script = src/midicore.js + src/<device>.js, and
# midi-helpers.js = everything. Edit the files in src/, then run this. The outputs are committed so a
# plain <script src> works from file://, GitHub Pages or the workers.dev host with no build on the way.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
STAMP="// Built by midi-helpers/p5/build.sh from midi-helpers/p5/src/ - edit the sources, not this file."
DEVICES="pipsqueak midifighter launchpad circuitplayground anymidi trinkeys"
for d in $DEVICES; do
  [ -f "$HERE/src/$d.js" ] || continue
  { echo "$STAMP"; cat "$HERE/src/midicore.js"; echo; cat "$HERE/src/$d.js"; } > "$HERE/$d.js"
done
{
  echo "// midi-helpers.js - every midi-helpers p5 script in one file: MidiCore, PipSqueak, MidiFighter, Launchpad,"
  echo "// CircuitPlayground, AnyMidi, SlideTrinkey, RotaryTrinkey. One tag:  <script src=\"midi-helpers.js\"></script>"
  echo "$STAMP"
  cat "$HERE/src/midicore.js"
  for d in $DEVICES; do [ -f "$HERE/src/$d.js" ] && { echo; cat "$HERE/src/$d.js"; }; done
} > "$HERE/midi-helpers.js"
# The ESM entry: the same bundle inside a module. The classic sources register on `window`, so the module
# hands them a private object that falls back to the real window for everything else (event listeners,
# navigator). Nothing leaks into the page's globals; the constructors come out as named exports.
{
  echo "// midi-helpers.mjs - mtm-midi-helpers as an ES module: import { PipSqueak } from \"mtm-midi-helpers\" (npm) or"
  echo "// \"@georgemandis/mtm-midi-helpers\" (JSR). Same classes as midi-helpers.js; use { callbacks: {...} } instead of global functions."
  echo "$STAMP"
  echo 'const realWindow = typeof globalThis.window === "object" ? globalThis.window : globalThis;'
  echo 'const window = new Proxy({}, {'
  echo '  get: (own, k) => { if (k in own) return own[k]; const v = realWindow[k]; return typeof v === "function" && !("prototype" in v) ? v.bind(realWindow) : v; },   // bind methods, hand classes back as they are'
  echo '  set: (own, k, v) => { own[k] = v; return true; },'
  echo '  has: (own, k) => k in own || k in realWindow,'
  echo '});'
  cat "$HERE/src/midicore.js"
  echo 'const { MidiCore, MidiMsg, MidiHelper } = window;   // the device scripts name these bare, as globals'
  for d in $DEVICES; do [ -f "$HERE/src/$d.js" ] && { echo; cat "$HERE/src/$d.js"; }; done
  echo
  echo 'const { PipSqueak, MidiFighter, Launchpad, CircuitPlayground, AnyMidi, SlideTrinkey, RotaryTrinkey } = window;'
  echo 'export { MidiCore, MidiMsg, MidiHelper, PipSqueak, MidiFighter, Launchpad, CircuitPlayground, AnyMidi, SlideTrinkey, RotaryTrinkey };'
} > "$HERE/midi-helpers.mjs"
echo "built: $(cd "$HERE" && ls *.js *.mjs | tr '\n' ' ')"
