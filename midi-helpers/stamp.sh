# Sourced by the archive builders (processing-library/build.sh, python/zip.sh). Sets TOUCH, a `touch -t`
# stamp applied to every file that goes into an archive, so the bytes depend on the tree alone and a
# rebuild of the same sources is identical. SOURCE_DATE_EPOCH wins; otherwise the yyyy-mm-dd date on the
# "## <version>" line of CHANGELOG.md. Expects ROOT (the midi-helpers folder) and VERSION to be set.
if [ -n "${SOURCE_DATE_EPOCH:-}" ]; then
  TOUCH="$(date -u -r "$SOURCE_DATE_EPOCH" +%Y%m%d%H%M.%S 2>/dev/null || date -u -d "@$SOURCE_DATE_EPOCH" +%Y%m%d%H%M.%S)"
else
  d="$(grep -m1 "^## $VERSION" "$ROOT/CHANGELOG.md" | grep -o -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)"
  [ -n "$d" ] || { echo "CHANGELOG.md: the '## $VERSION' line needs a yyyy-mm-dd date; it stamps the archives"; exit 1; }
  TOUCH="$(echo "$d" | tr -d -)0000"
fi
