#!/bin/sh
# Build the site and deploy it to the preview Worker (morethanmusic-preview, workers.dev only, no domain).
set -e
cd "$(dirname "$0")"
./build-site.sh
npx -y wrangler@4.149.0 deploy -c wrangler.preview.jsonc
