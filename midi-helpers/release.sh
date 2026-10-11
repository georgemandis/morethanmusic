#!/bin/bash
# Builds every helper artifact and lays the hosted copies into the site:
#   website/static/mtm-midi-helpers/<version>/   the p5 bundle and ESM entry, the per-device scripts, the
#                                                Processing library zip and its .txt, the Python zip
#   website/static/mtm-midi-helpers/latest/      the same files
# Publishing to JSR, npm or the Processing contributions list is a separate, manual step: see RELEASE.md.
#   midi-helpers/release.sh            # build, check, copy
#   midi-helpers/release.sh --check    # build and check only, copy nothing
set -eo pipefail   # a failing suite stops the release even through | tail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
VERSION="$(cat "$HERE/VERSION")"
CHECK=0; [ "$1" = "--check" ] && CHECK=1

# one version everywhere
node -e "const p=require('$HERE/p5/package.json'), j=require('$HERE/p5/jsr.json'); if (p.version!=='$VERSION'||j.version!=='$VERSION') { console.error('p5/package.json or p5/jsr.json is not at $VERSION'); process.exit(1); }"
grep -q "^prettyVersion = $VERSION$" "$HERE/processing-library/library.properties" || { echo "processing-library/library.properties is not at $VERSION"; exit 1; }
grep -q "^## $VERSION" "$HERE/CHANGELOG.md" || { echo "CHANGELOG.md has no ## $VERSION entry"; exit 1; }

"$HERE/p5/build.sh"
"$HERE/test/p5/run.sh" | tail -1
"$HERE/processing-library/build.sh"
"$HERE/processing-library/test.sh" quick | tail -1
"$HERE/python/zip.sh"

DIST="$HERE/dist/$VERSION"
rm -rf "$HERE/dist"; mkdir -p "$DIST"
cp "$HERE"/p5/midi-helpers.js "$HERE"/p5/midi-helpers.mjs "$HERE"/p5/pipsqueak.js "$HERE"/p5/midifighter.js "$HERE"/p5/launchpad.js \
   "$HERE"/p5/circuitplayground.js "$HERE"/p5/anymidi.js "$HERE"/p5/trinkeys.js "$DIST/"
cp "$HERE/processing-library/build/midihelpers.zip" "$HERE/processing-library/build/midihelpers.txt" "$DIST/"
cp "$HERE/python/build/mtm-midi-helpers-python-$VERSION.zip" "$DIST/"
cp "$HERE/LICENSE" "$DIST/"
(cd "$DIST" && shasum -a 256 * > SHA256SUMS)
echo "dist/$VERSION: $(ls "$DIST" | tr '\n' ' ')"
[ "$CHECK" = 1 ] && { echo "check only, nothing copied"; exit 0; }

STATIC="$ROOT/website/static/mtm-midi-helpers"
rm -rf "$STATIC/$VERSION" "$STATIC/latest"
mkdir -p "$STATIC"
cp -R "$DIST" "$STATIC/$VERSION"
cp -R "$DIST" "$STATIC/latest"
echo "$VERSION" > "$STATIC/latest/VERSION"
echo "copied to website/static/mtm-midi-helpers/$VERSION and latest"
