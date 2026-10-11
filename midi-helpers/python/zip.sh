#!/bin/bash
# Zips the Python Mode modules for download: build/mtm-midi-helpers-python-<version>.zip holds a
# mtm-midi-helpers-python/ folder with the seven modules, README-install.md, sketch.properties and LICENSE.
#   python/zip.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
VERSION="$(cat "$ROOT/VERSION")"
OUT="$HERE/build"
DIR="$OUT/mtm-midi-helpers-python"
command -v zip >/dev/null || { echo "zip not found"; exit 1; }
rm -rf "$OUT"; mkdir -p "$DIR"
cp "$HERE"/*.py "$DIR/"
cp "$HERE/README-install.md" "$DIR/README.md"
cp "$ROOT/LICENSE" "$DIR/LICENSE"
printf 'mode=Python\nmode.id=jycessing.mode.PythonMode\n' > "$DIR/sketch.properties"
. "$ROOT/stamp.sh"   # sets TOUCH from CHANGELOG.md's date for this version (or SOURCE_DATE_EPOCH)
find "$DIR" -exec touch -t "$TOUCH" {} +
(cd "$OUT" && TZ=UTC zip -q -X -r "mtm-midi-helpers-python-$VERSION.zip" mtm-midi-helpers-python)
for f in midicore.py pipsqueak.py midifighter.py launchpad.py circuitplayground.py anymidi.py trinkeys.py README.md LICENSE sketch.properties; do
  unzip -l "$OUT/mtm-midi-helpers-python-$VERSION.zip" | awk '{print $4}' | grep -q -x "mtm-midi-helpers-python/$f" || { echo "missing from zip: $f"; exit 1; }
done
echo "built $OUT/mtm-midi-helpers-python-$VERSION.zip ($(du -k "$OUT/mtm-midi-helpers-python-$VERSION.zip" | cut -f1) KB)"
