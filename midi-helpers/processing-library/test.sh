#!/bin/bash
# Checks the built library. Run build.sh first.
#   processing-library/test.sh        # zip layout, every example compiles against the jar with javac,
#                                     # the Java test suite runs against the jar, and when Processing.app is
#                                     # installed one example is built through Processing's own CLI
#   processing-library/test.sh quick  # skip the Processing CLI step
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="$HERE/build"
LIB="$BUILD/midihelpers"
JAR="$LIB/library/midihelpers.jar"
ZIP="$BUILD/midihelpers.zip"
. "$HERE/../test/java/core.sh"   # sets CORE
[ -f "$JAR" ] && [ -f "$ZIP" ] || { echo "no build in $BUILD; run processing-library/build.sh first"; exit 1; }

echo "== zip layout"
for entry in midihelpers/library.properties midihelpers/library/midihelpers.jar midihelpers/LICENSE midihelpers/examples/ midihelpers/src/midihelpers/MidiCore.java; do
  unzip -l "$ZIP" | awk '{print $4}' | grep -q -x "$entry" || { echo "missing from zip: $entry"; exit 1; }
done
unzip -l "$ZIP" | awk '{print $4}' | grep -v '^midihelpers/' | grep -v '^$' | grep -v -E '^(Name|----)$' && { echo "stray entries at the zip root"; exit 1; }
grep -q "^prettyVersion = $(cat "$HERE/../VERSION")$" "$LIB/library.properties" || { echo "library.properties prettyVersion does not match VERSION"; exit 1; }
echo "ok"

echo "== examples compile against the jar (javac)"
T="$BUILD/test"; rm -rf "$T"; mkdir -p "$T"
n=0
for ex in "$HERE"/examples/*/; do
  name="$(basename "$ex")"
  mkdir -p "$T/$name"
  {
    grep -h '^import ' "$ex/$name.pde"
    echo "import processing.core.*; import processing.data.*; import java.util.*;"
    echo "public class $name extends PApplet {"
    # what Processing's preprocessor would do for these examples: public sketch functions, color type to int,
    # int(x) to parseInt(x), and float literals
    grep -v '^import ' "$ex/$name.pde" | perl -pe 's/^void /public void /; s/(^|[^\w.])color(?![\w(])/$1int/g; s/\b(int|float|char|boolean|byte)\(/parse\u$1(/g; s/(?<![\w.])(\d+\.\d+)(?![\w.])/$1f/g'
    echo "}"
  } > "$T/$name/$name.java"
  javac -nowarn --release 17 -d "$T/$name" -cp "$JAR:$CORE" "$T/$name/$name.java" || { echo "example $name does not compile"; exit 1; }
  n=$((n + 1))
done
echo "ok: $n examples"

echo "== test suite against the jar"
mkdir -p "$T/suite"
echo "import processing.core.PApplet; public class Sketch extends PApplet {}" > "$T/suite/Sketch.java"
# the suite was written against the tabs as inner classes of Sketch; as a library they are top-level classes
perl -pe 's/^import java.util.\*;/import java.util.*; import midihelpers.*;/; s/\bSketch\.(\w+)/$1/g; s/\b\w+\.new (\w+)\(/new $1(/g' "$HERE/../test/java/MidiHelpersTest.java" > "$T/suite/MidiHelpersTest.java"
javac -nowarn --release 17 -d "$T/suite" -cp "$JAR:$CORE" "$T/suite/Sketch.java" "$T/suite/MidiHelpersTest.java"
java -cp "$JAR:$CORE:$T/suite" MidiHelpersTest

if [ "$1" != "quick" ]; then
  echo "== Processing CLI build"
  APP=/Applications/Processing.app/Contents/MacOS/Processing
  if [ -x "$APP" ]; then
    S="$T/cli/PipSqueakDot"; rm -rf "$T/cli"; mkdir -p "$S/code"
    cp "$HERE/examples/PipSqueakDot/PipSqueakDot.pde" "$S/"
    cp "$JAR" "$S/code/"   # a jar in the sketch's code folder resolves the import without touching the sketchbook
    "$APP" cli --sketch="$S" --output="$S-out" --force --build 2>&1 | grep -v -E '^WARNING|^$' | tail -5
    [ -f "$S-out/PipSqueakDot.class" ] && echo "ok" || { echo "Processing CLI build FAILED"; exit 1; }
  else
    echo "Processing.app not found, skipped"
  fi
fi
echo "processing-library: all checks passed"
