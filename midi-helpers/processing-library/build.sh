#!/bin/bash
# Builds the Processing library from the tabs in ../java: build/midihelpers/ is the folder a user drops into
# their sketchbook's libraries/, build/midihelpers.zip is what the Contribution Manager installs, and
# build/midihelpers.txt is the properties file that sits beside the zip when it is listed.
#   processing-library/build.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
VERSION="$(cat "$ROOT/VERSION")"
BUILD="$HERE/build"
LIB="$BUILD/midihelpers"
. "$ROOT/test/java/core.sh"   # sets CORE
grep -q "^prettyVersion = $VERSION$" "$HERE/library.properties" || { echo "library.properties prettyVersion must be $VERSION (see VERSION)"; exit 1; }
command -v zip >/dev/null || { echo "zip not found"; exit 1; }

rm -rf "$BUILD"; mkdir -p "$BUILD/classes" "$LIB/library" "$LIB/examples"
node "$HERE/generate.mjs" "$BUILD/src/midihelpers"
javac -nowarn --release 17 -d "$BUILD/classes" -cp "$CORE" "$BUILD/src/midihelpers"/*.java
cp -R "$BUILD/src" "$LIB/src"
cp "$HERE/library.properties" "$LIB/library.properties"
cp "$ROOT/LICENSE" "$LIB/LICENSE"
cp "$HERE/README.md" "$LIB/README.md"
cp -R "$HERE/examples/." "$LIB/examples/"

# Fixed timestamps so a rebuild of the same sources gives the same bytes. SOURCE_DATE_EPOCH wins, then the last commit.
. "$ROOT/stamp.sh"   # sets TOUCH from CHANGELOG.md's date for this version (or SOURCE_DATE_EPOCH)
printf 'Manifest-Version: 1.0\nImplementation-Title: midihelpers\nImplementation-Version: %s\n' "$VERSION" > "$BUILD/classes/MANIFEST.MF"
mkdir -p "$BUILD/classes/META-INF"; mv "$BUILD/classes/MANIFEST.MF" "$BUILD/classes/META-INF/MANIFEST.MF"
find "$BUILD/classes" "$LIB" -exec touch -t "$TOUCH" {} +
(cd "$BUILD/classes" && TZ=UTC zip -q -X -r "$LIB/library/midihelpers.jar" META-INF $(ls -d */ | grep -v META-INF))
touch -t "$TOUCH" "$LIB/library/midihelpers.jar" "$LIB/library"
cp "$HERE/library.properties" "$BUILD/midihelpers.txt"
(cd "$BUILD" && TZ=UTC zip -q -X -r midihelpers.zip midihelpers)
echo "built $LIB ($(unzip -l "$LIB/library/midihelpers.jar" | grep -c '\.class$') classes), $BUILD/midihelpers.zip ($(du -k "$BUILD/midihelpers.zip" | cut -f1) KB)"
