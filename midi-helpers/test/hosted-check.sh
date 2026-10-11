#!/bin/bash
# Tests midi-helpers/hosted-check.sh against copies of the hosted folder: the untouched copy passes, an
# edited script fails naming the file, a zip with an extra entry fails naming the zip, a wrong latest/VERSION
# fails. Needs a prior midi-helpers/release.sh --check (dist/ present).
#   midi-helpers/test/hosted-check.sh
set -eo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
V="$(cat "$HERE/VERSION")"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
expect() { # expect pass|fail "label" STATIC_DIR [substring the output must contain]
  local want="$1" label="$2" dir="$3" must="${4:-}" out code=0
  out="$(STATIC="$dir" "$HERE/hosted-check.sh" 2>&1)" || code=$?
  if [ "$want" = pass ] && [ "$code" != 0 ]; then echo "FAIL $label: exit $code: $out"; fail=1; return; fi
  if [ "$want" = fail ] && [ "$code" = 0 ]; then echo "FAIL $label: passed, expected a failure"; fail=1; return; fi
  if [ -n "$must" ] && ! grep -q -- "$must" <<<"$out"; then echo "FAIL $label: output lacks '$must': $out"; fail=1; return; fi
  echo "ok   $label"
}
cp -R "$HERE/../website/static/mtm-midi-helpers" "$T/clean"
expect pass "untouched hosted copy passes" "$T/clean"

cp -R "$T/clean" "$T/edited"; printf '\n// drift\n' >> "$T/edited/latest/midi-helpers.js"
expect fail "an edited hosted script fails" "$T/edited" "midi-helpers.js"

cp -R "$T/clean" "$T/zip"; echo x > "$T/extra.txt"; (cd "$T" && zip -q "$T/zip/$V/mtm-midi-helpers-python-$V.zip" extra.txt)
expect fail "a zip with an extra entry fails" "$T/zip" "mtm-midi-helpers-python-$V.zip"

cp -R "$T/clean" "$T/ver"; echo 0.0.1 > "$T/ver/latest/VERSION"
expect fail "a wrong latest/VERSION fails" "$T/ver" "VERSION"

[ "$fail" = 0 ] && echo "hosted-check tests passed"; exit $fail
