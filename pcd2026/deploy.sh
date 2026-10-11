#!/bin/sh
# Deploy the pcd2026.mand.is redirect Worker. Runs the test first.
set -e
cd "$(dirname "$0")"
node test.mjs
npx -y wrangler@4.149.0 deploy -c wrangler.jsonc
