#!/usr/bin/env bash
# Serve the production build the way the Worker will (wrangler dev, so _redirects apply) and check
# every page: each URL in the build's sitemap, the old workshop URLs (and where they land), every link
# into the repo folders, and every sketch the docs embed. A URL passes when it ends on a 2xx after
# following redirects. The sidebar must list the ten sections in the spec's order. Then, if Chrome is installed, each
# embedded sketch is loaded headless (check-embeds.mjs) and must fire load and leave the console empty.
#
#   website/check-links.sh             # build and lay out first (../deploy-preview.sh --build-only), then check
#   website/check-links.sh --no-build  # check the build that is already there
#   website/check-links.sh --live https://morethanmusic.dev            # a deployed host, no build, no local server
#   PCD_BASE=https://pcd2026.mand.is website/check-links.sh --live ...  # and the old host must 301 onto it
#   SKIP_CHROME=1 website/check-links.sh   # skip the Chrome step on purpose; a missing Chrome otherwise fails
set -u
cd "$(dirname "$0")/.."
PORT="${PORT:-8799}"
OUT="${TMPDIR:-/tmp}/check-links.$$"
mkdir -p "$OUT"

if [ "${1:-}" = "--live" ]; then
  # A deployed host: no build, no local server. PCD_BASE adds the old workshop host, which must 301 here.
  BASE="${2:?usage: check-links.sh --live https://host}"; BASE="${BASE%/}"
  trap 'rm -rf "$OUT"' EXIT
  curl -s -o "$OUT/sitemap.xml" "$BASE/sitemap.xml" || { echo "FAIL no sitemap at $BASE"; exit 1; }
  curl -s -o "$OUT/index.html" "$BASE/"
else
  if [ "${1:-}" != "--no-build" ]; then
    ./build-site.sh >"$OUT/build.log" 2>&1 || { tail -40 "$OUT/build.log"; echo "build failed"; exit 1; }
  fi
  if curl -s -o /dev/null "http://localhost:$PORT/"; then
    echo "FAIL something already answers on port $PORT; stop it or set PORT"; exit 1
  fi
  npx -y wrangler@4.149.0 dev -c wrangler.preview.jsonc --port "$PORT" --log-level error >"$OUT/wrangler.log" 2>&1 &
  WR=$!
  # npx forks wrangler, which forks workerd: kill whatever holds the port, not only $WR
  trap 'kill $WR 2>/dev/null; lsof -ti tcp:$PORT 2>/dev/null | xargs kill 2>/dev/null; wait $WR 2>/dev/null; rm -rf "$OUT"' EXIT
  for i in $(seq 1 60); do
    curl -s -o /dev/null "http://localhost:$PORT/" && break
    sleep 1
  done
  BASE="http://localhost:$PORT"
  cp website/build/sitemap.xml website/build/index.html "$OUT/"
fi

# Every doc page the site built, from the sitemap.
mapfile -t SITEMAP < <(grep -o '<loc>[^<]*</loc>' "$OUT/sitemap.xml" | sed -E 's#<loc>https?://[^/]+##; s#</loc>##')
# The sections of the resource, by URL.
SECTIONS=(/ /start-here/introduction-to-midi/ /pick-your-tool/ /the-explorer/ /devices/ /make-your-own/ /helpers/ /examples/ /troubleshooting/ /talks/ /talks/pcd-2026-nyc/ /about/)
# Old URLs from the PCD 2026 deck, QR codes and printed notes. They redirect; the target must exist.
OLD=(/explorer /explorer/ /examples /examples/ /helpers.js /projects-live /projects-live/
  /before-you-start/ /start-here/ /agenda/ /introduction-to-midi/ /the-explorer/ /hello-world/
  /three-bytes-no-helpers/ /project-ideas/ /demos/ /references/
  /your-device/ /your-device/pipsqueak/ /your-device/circuit-playground/ /your-device/midi-fighter/
  /your-device/launchpad/ /your-device/anything-else/ /examples/pipsqueak/ /examples/launchpad/)
# Every sketch a doc page embeds.
mapfile -t EMBEDS < <(grep -rho 'LiveSketch src="[^"]*"' website/docs | sed -E 's/.*src="([^"]*)"/\1/' | sort -u)
# Every link into the repo folders served beside the site (pathname:///explorer/, READMEs, zips).
mapfile -t PATHNAMES < <(grep -rhoE "pathname:///[^)\"' ]+" website/docs | sed 's#pathname://##' | sort -u)
# Where the old URLs must land (path only). A redirect to the wrong page would still be a 2xx.
LANDS=("/before-you-start/ /" "/start-here/ /" "/agenda/ /talks/pcd-2026-nyc/" "/introduction-to-midi/ /start-here/introduction-to-midi/"
  "/hello-world/ /examples/hello-world/" "/demos/ /examples/demos/" "/references/ /examples/references/"
  "/your-device/pipsqueak/ /devices/pipsqueak/" "/your-device/ /devices/" "/explorer /explorer/web/" "/examples/launchpad/ /starters/p5/launchpad/"
  "/helpers.js /mtm-midi-helpers/latest/midi-helpers.js" "/projects-live /examples/demos/")
# Doc pages loaded in Chrome along with the embeds, for hydration errors and the iframes' own console.
PAGES=(/ /the-explorer/ /devices/pipsqueak/ /examples/hello-world/ /talks/ /troubleshooting/)

fail=0; n=0
# A short list means the grep or the sitemap broke, not that the site shrank.
[ "${#SITEMAP[@]}" -ge 20 ] || { echo "FAIL sitemap has ${#SITEMAP[@]} urls"; fail=$((fail + 1)); }
[ "${#EMBEDS[@]}" -ge 10 ] || { echo "FAIL only ${#EMBEDS[@]} embedded sketches found"; fail=$((fail + 1)); }
[ "${#PATHNAMES[@]}" -ge 10 ] || { echo "FAIL only ${#PATHNAMES[@]} pathname links found"; fail=$((fail + 1)); }
check() {
  local url="$1" code
  code=$(curl -s -L --max-redirs 5 -o /dev/null -w '%{http_code}' "$BASE$url")
  n=$((n + 1))
  case "$code" in 2??) ;; *) echo "FAIL $code $url"; fail=$((fail + 1)) ;; esac
}
for u in "${SITEMAP[@]}" "${SECTIONS[@]}" "${OLD[@]}" "${EMBEDS[@]}" "${PATHNAMES[@]}"; do check "$u"; done
for pair in "${LANDS[@]}"; do
  from="${pair% *}"; to="${pair#* }"
  got=$(curl -s -L --max-redirs 5 -o /dev/null -w '%{url_effective}' "$BASE$from"); got="${got#$BASE}"
  n=$((n + 1))
  [ "$got" = "$to" ] || { echo "FAIL $from lands on $got, expected $to"; fail=$((fail + 1)); }
done
# The old workshop host, once it redirects here: each old URL must end on its new page on this host.
if [ -n "${PCD_BASE:-}" ]; then
  for pair in "${LANDS[@]}" "/ /talks/pcd-2026-nyc/" "/midi-helpers/p5/midi-helpers.js /midi-helpers/p5/midi-helpers.js" "/starters/p5/pipsqueak/ /starters/p5/pipsqueak/" "/explorer/web/ /explorer/web/"; do
    from="${pair% *}"; to="${pair#* }"
    got=$(curl -s -L --max-redirs 6 -o /dev/null -w '%{http_code} %{url_effective}' "${PCD_BASE%/}$from")
    n=$((n + 1))
    [ "$got" = "200 $BASE$to" ] || { echo "FAIL pcd2026 $from -> $got, expected 200 $BASE$to"; fail=$((fail + 1)); }
  done
fi
echo "$n urls checked, $fail failed"

# The sidebar: the ten sections in the spec's order.
WANT="Start here|Pick your tool|The Explorer|Devices|Make your own|Helpers|Examples|Troubleshooting|Talks and workshops|About"
GOT=$(node -e '
const s = require("fs").readFileSync(process.argv[1], "utf8");
const nav = (s.match(/<nav[^>]*aria-label="Docs sidebar"[^>]*>[\s\S]*?<\/nav>/) || [""])[0];
const re = /<li class="theme-doc-sidebar-item-(?:category|link)[^"]*-level-1[^"]*"[^>]*>[\s\S]*?<a[^>]*>([\s\S]*?)<\/a>/g;
console.log([...nav.matchAll(re)].map((m) => m[1].replace(/<[^>]+>/g, "").trim()).join("|"));' "$OUT/index.html")
if [ "$GOT" = "$WANT" ]; then echo "sidebar order ok"; else echo "FAIL sidebar order: $GOT"; fail=$((fail + 1)); fi

# Each embedded sketch must load and leave the console empty. check-embeds.mjs drives headless Chrome over
# the DevTools protocol (Chrome 154's --dump-dom never returns on a p5 page) and self-tests first.
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
if [ "${SKIP_CHROME:-}" = 1 ]; then
  echo "SKIPPED the Chrome step (SKIP_CHROME=1): embeds and pages not loaded"
elif [ ! -x "$CHROME" ]; then
  echo "FAIL Chrome not found at $CHROME. Set CHROME, or SKIP_CHROME=1 to skip on purpose"; fail=$((fail + 1))
elif CHROME="$CHROME" node website/check-embeds.mjs --self-test; then
  CHROME="$CHROME" node website/check-embeds.mjs "${EMBEDS[@]/#/$BASE}" "${PAGES[@]/#/$BASE}" || fail=$((fail + 1))
else
  echo "FAIL check-embeds.mjs self-test"; fail=$((fail + 1))
fi

[ "$fail" -eq 0 ] && echo "ok" || { echo "$fail failures"; exit 1; }
