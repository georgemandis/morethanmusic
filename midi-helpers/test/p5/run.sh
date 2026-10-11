#!/bin/bash
# Rebuilds the p5 scripts from p5/src and runs the hardware-free node tests. No npm, no dependencies.
HERE="$(cd "$(dirname "$0")" && pwd)"
"$HERE/../../p5/build.sh" >/dev/null || exit 1
command -v node >/dev/null || { echo "node not found"; exit 1; }
node "$HERE/run_tests.js"
