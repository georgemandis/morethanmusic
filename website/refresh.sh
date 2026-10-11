#!/usr/bin/env bash
# Re-pulls the included code samples and README sections into docs/. See refresh.mjs for details.
cd "$(dirname "$0")" && exec node refresh.mjs "$@"
