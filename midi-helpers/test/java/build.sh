#!/bin/bash
# Compiles every midi-helpers/java/*.pde tab the way Processing does, wrapped in a PApplet subclass,
# against the core.jar in the installed Processing app, then runs the hardware-free tests.
#   midi-helpers/test/java/build.sh            # compile + test
#   midi-helpers/test/java/build.sh compile    # compile only
#   midi-helpers/test/java/build.sh ide        # compile + test, then build an all-tabs sketch with Processing's own CLI
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
JAVA_DIR="$HERE/../../java"
OUT="$(cd "${TMPDIR:-/tmp}" && pwd -P)/midi-helpers-build"
CORE="${PROCESSING_CORE:-}"
if [ -z "$CORE" ]; then
  for c in /Applications/Processing.app/Contents/app/resources/core/library/core-*.jar \
           /Applications/Processing.app/Contents/Java/core/library/core.jar \
           "$HOME/Applications/Processing.app/Contents/app/resources/core/library/core-"*.jar; do
    [ -f "$c" ] && CORE="$c" && break
  done
fi
if [ -z "$CORE" ]; then echo "core.jar not found; set PROCESSING_CORE=/path/to/core.jar"; exit 1; fi
rm -rf "$OUT"; mkdir -p "$OUT"
SKETCH="$OUT/Sketch.java"
{
  echo "import processing.core.*; import processing.data.*; import processing.event.*;"
  echo "import java.util.*; import java.io.*;"
  grep -h '^import ' "$JAVA_DIR"/*.pde | sort -u
  echo "public class Sketch extends PApplet {"
  for f in "$JAVA_DIR"/*.pde; do grep -v '^import ' "$f"; done
  echo "}"
} > "$SKETCH"
javac -nowarn -d "$OUT" -cp "$CORE" "$SKETCH" 2>&1 | sed "s#$SKETCH#Sketch.java#"
[ "${PIPESTATUS[0]}" -eq 0 ] || exit 1
echo "compiled $(ls "$JAVA_DIR"/*.pde | xargs -n1 basename | tr '\n' ' ')"
if [ "$1" = "compile" ]; then exit 0; fi
javac -nowarn -d "$OUT" -cp "$CORE:$OUT" "$HERE"/*.java
java -cp "$CORE:$OUT" MidiHelpersTest || exit 1
if [ "$1" = "ide" ]; then
  APP=/Applications/Processing.app/Contents/MacOS/Processing
  [ -x "$APP" ] || { echo "Processing.app not found, skipping the IDE build"; exit 0; }
  IDE="$OUT/AllHelpers"; rm -rf "$IDE" "$IDE-out"; mkdir -p "$IDE"
  cp "$JAVA_DIR"/*.pde "$IDE/"
  cat > "$IDE/AllHelpers.pde" <<'PDE'
PipSqueak stick = new PipSqueak(this); MidiFighter mf = new MidiFighter(this); Launchpad pad = new Launchpad(this);
CircuitPlayground cpx = new CircuitPlayground(this); AnyMidi any = new AnyMidi(this);
void setup() { size(200, 200); stick.connect(); mf.connect(); pad.connect(); cpx.connect(); any.connect(); }
void draw() { float v = stick.x + cpx.accel.z + cpx.light + any.note(1); mf.led(0, mf.pressed(0)); pad.set(0, 0, color(255)); pad.set(1, 1, pad.RED); cpx.pixels(1, 2, 3); }
void padPressed(int i) {} void padPressed(int x, int y) {} void buttonPressed(String id) {} void stickPressed() {} void touchPressed(int p) {}
void noteOn(int ch, int n, int v) {} void controlChange(int ch, int n, int v) {}
PDE
  "$APP" cli --sketch="$IDE" --output="$IDE-out" --build 2>&1 | grep -v -E '^WARNING|^$' | tail -5
  [ -f "$IDE-out/AllHelpers.class" ] && echo "Processing CLI build ok" || { echo "Processing CLI build FAILED"; exit 1; }
fi
