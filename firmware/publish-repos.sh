#!/usr/bin/env bash
# Put the firmware folders on GitHub. Dry by default: prints what it would do. --push does it.
#
#   firmware/publish-repos.sh          # show the plan
#   firmware/publish-repos.sh --push   # create the two new repos, open three pull requests, fill the markers
#
# New repos (public, one commit each, from a clean copy of the folder): trinkey-midi, arduino-midiusb-starter.
# Existing repos get a 2026-refresh branch and a pull request, never a push to their default branch:
# puck-js-midi-clicker (master), espruino-zoom-muter (main), circuit-playground-midi-multi-tool (master,
# README.patch only). Afterwards the "repo: pending" markers in the READMEs and site pages become URLs.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"; PUSH=0; [ "${1:-}" = "--push" ] && PUSH=1
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
GH=georgemandis
run() { if [ "$PUSH" = 1 ]; then "$@"; else echo "would: $*"; fi; }

for name in trinkey-midi arduino-midiusb-starter; do
  echo "== new repo $GH/$name"
  if gh repo view "$GH/$name" >/dev/null 2>&1; then echo "   exists already, skipping create"; continue; fi
  rsync -a --exclude .DS_Store --exclude __pycache__ "firmware/$name/" "$WORK/$name/"
  sed -i '' '/^<!-- repo: pending -->$/d' "$WORK/$name/README.md"
  git -C "$WORK/$name" init -q -b main
  git -C "$WORK/$name" add -A
  git -C "$WORK/$name" commit -q -m "$name: first public commit, from the More than Music with MIDI repo" 
  run gh repo create "$GH/$name" --public --source "$WORK/$name" --push \
    --description "$(sed -n '1,8p' "firmware/$name/README.md" | grep -v '^#\|^<!--\|^$' | head -1 | cut -c1-200)"
done

refresh() {  # repo default-branch folder
  local repo=$1 base=$2 folder=$3
  echo "== refresh $GH/$repo ($base) from firmware/$folder"
  git clone -q "git@github.com:$GH/$repo.git" "$WORK/$repo"
  git -C "$WORK/$repo" checkout -q -b 2026-refresh "origin/$base"
  rsync -a --delete --exclude .git --exclude .DS_Store "firmware/$folder/" "$WORK/$repo/"
  if git -C "$WORK/$repo" diff --quiet && [ -z "$(git -C "$WORK/$repo" status --porcelain)" ]; then echo "   no changes"; return; fi
  git -C "$WORK/$repo" add -A
  git -C "$WORK/$repo" commit -q -m "2026 refresh from the More than Music with MIDI repo (firmware/$folder)"
  git -C "$WORK/$repo" --no-pager diff --stat "origin/$base" | tail -3
  run git -C "$WORK/$repo" push -q -u origin 2026-refresh
  run gh pr create --repo "$GH/$repo" --base "$base" --head 2026-refresh \
    --title "2026 refresh" --body "The folder as it stands in the More than Music with MIDI repo: README with the message map and flash steps, licence, source. https://morethanmusic.dev/make-your-own/"
}
refresh puck-js-midi-clicker master puck-js-midi-clicker
refresh espruino-zoom-muter main espruino-zoom-muter

echo "== README patch for $GH/circuit-playground-midi-multi-tool"
git clone -q "git@github.com:$GH/circuit-playground-midi-multi-tool.git" "$WORK/cpx"
git -C "$WORK/cpx" checkout -q -b 2026-readme origin/master
if git -C "$WORK/cpx" apply --check "$ROOT/firmware/circuit-playground-midi-multi-tool/README.patch" 2>/dev/null; then
  git -C "$WORK/cpx" apply "$ROOT/firmware/circuit-playground-midi-multi-tool/README.patch"
  git -C "$WORK/cpx" commit -q -am "README: mode 7 (tap) sends nothing in this firmware; message map as measured in 2026"
  run git -C "$WORK/cpx" push -q -u origin 2026-readme
  run gh pr create --repo "$GH/circuit-playground-midi-multi-tool" --base master --head 2026-readme \
    --title "README: fix the mode 7 claim, message map as measured" --body "From the More than Music with MIDI repo, firmware/circuit-playground-midi-multi-tool/README.patch. https://morethanmusic.dev/make-your-own/circuit-playground/"
else
  echo "   README.patch does not apply to origin/master; apply by hand from firmware/circuit-playground-midi-multi-tool/README.proposed.md"
fi

echo "== markers"
for name in trinkey-midi arduino-midiusb-starter; do
  url="https://github.com/$GH/$name"
  run perl -pi -e "s#^<!-- repo: pending -->\$#Repo: <$url>#" "firmware/$name/README.md"
done
run perl -pi -e 's#\{/\* repo: pending \*/\}#Source: [github.com/georgemandis/trinkey-midi](https://github.com/georgemandis/trinkey-midi).#' website/docs/04-make-your-own/02-trinkeys.md
run perl -pi -e 's#\{/\* repo: pending \*/\}#Source: [github.com/georgemandis/arduino-midiusb-starter](https://github.com/georgemandis/arduino-midiusb-starter).#' website/docs/04-make-your-own/04-arduino-midiusb.md
run perl -pi -e 's# \{/\* repo: pending \*/\}##' website/docs/04-make-your-own/index.md
[ "$PUSH" = 1 ] && echo "done. Review the site pages, then commit and ./deploy.sh" || echo "dry run. Add --push to do it."
