#!/bin/sh
# Deploy morethanmusic.dev: build the site, lay the repo folders beside it, deploy the Worker in wrangler.jsonc.
# The custom domain is in wrangler.jsonc; wrangler creates the DNS record and certificate on the first deploy.
#
#   ./deploy.sh              # build and deploy
#   ./deploy-preview.sh      # the same to the preview Worker on workers.dev
#   pcd2026/deploy.sh        # the redirect Worker on pcd2026.mand.is
set -e
cd "$(dirname "$0")"
./build-site.sh
npx -y wrangler@4.149.0 deploy -c wrangler.jsonc
