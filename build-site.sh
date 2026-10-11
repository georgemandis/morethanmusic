#!/bin/sh
# Build the site into website/build and lay the repo's sketch and demo folders beside it, the way every
# Worker serves them. deploy.sh, deploy-preview.sh and website/check-links.sh all start here.
set -e
cd "$(dirname "$0")"

node website/refresh.mjs && echo "website/docs refreshed"
(cd website && npm run build)

# Every top-level repo folder is served beside the site at its own path (/explorer/, /starters/p5/...).
# Merge without deleting or overwriting: devices/ and talks/ share their path with docs pages at
# /devices/ and /talks/, and those pages must win. Skipped: docs/ (planning), pcd2026/ (the redirect
# Worker), site/ (the retired hand-built workshop site; delete it when convenient). Local build output
# (build/ and dist/ inside midi-helpers, git-ignored) is not a page; check-links.sh checks it stays out.
for d in */; do
  d="${d%/}"
  case "$d" in website|node_modules|docs|pcd2026|site) continue ;; esac
  rsync -a --ignore-existing \
    --exclude node_modules --exclude __pycache__ --exclude '*.class' --exclude .DS_Store \
    --exclude build/ --exclude dist/ \
    "$d/" "website/build/$d/"
done
for f in *; do   # loose top-level files stay reachable; never shadow the site's own files
  [ -f "$f" ] || continue
  case "$f" in wrangler*.jsonc|*.sh|index.html|PLAN.md|RELEASE.md|README.public.md|headshot.html|me.jpg|split-life*.html) continue ;; esac
  [ -e "website/build/$f" ] || cp "$f" "website/build/$f"
done
cp .assetsignore website/build/.assetsignore
echo "built website/build"
