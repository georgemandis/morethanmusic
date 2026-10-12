#!/bin/sh
# Build the site into website/build and lay the repo's sketch and demo folders beside it, the way every
# Worker serves them. deploy.sh, deploy-preview.sh and website/check-links.sh all start here.
set -e
cd "$(dirname "$0")"

node website/refresh.mjs && echo "website/docs refreshed"
(cd website && npm run build)

# Every top-level repo folder is served beside the site at its own path (/explorer/, /starters/p5/...).
# website/layout.mjs merges them in without replacing anything the site built, and skips the folders
# that are not pages (docs/, pcd2026/, site/), build output and the loose root files that are not for
# the site. Plain Node, because Cloudflare's build image has no rsync.
node website/layout.mjs
echo "built website/build"
