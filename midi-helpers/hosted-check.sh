#!/bin/bash
# Checks the hosted helper copies under website/static/mtm-midi-helpers/<version> and /latest against a fresh
# build in dist/<version> (run midi-helpers/release.sh --check first). Zips are compared by their entries and
# the entry contents, not by their bytes: a zip built on another machine differs in file times and order
# while holding the same files. Class files inside the library jar are compared by name only, since javac
# output differs between JDK builds.
#   midi-helpers/hosted-check.sh            # exit 1 on the first difference, naming the file
#   STATIC=/other/dir midi-helpers/hosted-check.sh
set -eo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
V="$(cat "$HERE/VERSION")"
DIST="$HERE/dist/$V"
STATIC="${STATIC:-$HERE/../website/static/mtm-midi-helpers}"
[ -d "$DIST" ] || { echo "no $DIST: run midi-helpers/release.sh --check first"; exit 1; }
fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

# The entries of a zip, then the hash of each non-jar file; a jar lists its own entry names. The zip is
# extracted to a folder first: streaming entries out with unzip -p gave an empty jar on Linux.
zipdigest() {
  local z="$1" d f
  d="$(mktemp -d "$T/zip.XXXXXX")"
  unzip -q -o -d "$d" "$z" < /dev/null
  (cd "$d" && find . -mindepth 1 | sed 's#^\./##' | LC_ALL=C sort)
  while IFS= read -r f; do
    case "$f" in
      *.jar) echo "$f:"; unzip -Z1 "$d/$f" < /dev/null | LC_ALL=C sort | sed 's/^/  /' ;;
      *) echo "$f $(shasum -a 256 < "$d/$f" | cut -c1-64)" ;;
    esac
  done < <(cd "$d" && find . -type f | sed 's#^\./##' | LC_ALL=C sort)
  rm -rf "$d"
}

for dir in "$STATIC/$V" "$STATIC/latest"; do
  [ -d "$dir" ] || { echo "FAIL missing $dir"; fail=1; continue; }
  # the hosted sums describe the hosted files
  (cd "$dir" && shasum -a 256 -c --quiet SHA256SUMS) || { echo "FAIL $dir/SHA256SUMS does not match its files"; fail=1; }
  for f in "$DIST"/*; do
    name="$(basename "$f")"
    [ "$name" = SHA256SUMS ] && continue
    [ -f "$dir/$name" ] || { echo "FAIL $dir/$name is missing"; fail=1; continue; }
    case "$name" in
      *.zip) if ! diff <(zipdigest "$f") <(zipdigest "$dir/$name") > "$T/zipdiff"; then
               echo "FAIL $dir/$name differs from the rebuilt zip:"; head -5 "$T/zipdiff"; fail=1; fi ;;
      *) cmp -s "$f" "$dir/$name" || { echo "FAIL $dir/$name differs from the rebuilt file"; fail=1; } ;;
    esac
  done
done
[ "$(cat "$STATIC/latest/VERSION" 2>/dev/null)" = "$V" ] || { echo "FAIL $STATIC/latest/VERSION is not $V"; fail=1; }
[ "$fail" = 0 ] && echo "hosted copies of $V match the build"
exit $fail
