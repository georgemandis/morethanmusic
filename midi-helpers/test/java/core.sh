# Sourced by the Java build scripts: finds Processing's core.jar and exports CORE.
# Set PROCESSING_CORE to point at a jar yourself (CI downloads one from Maven Central).
CORE="${PROCESSING_CORE:-}"
if [ -z "$CORE" ]; then
  for c in /Applications/Processing.app/Contents/app/resources/core/library/core-*.jar \
           /Applications/Processing.app/Contents/Java/core/library/core.jar \
           "$HOME/Applications/Processing.app/Contents/app/resources/core/library/core-"*.jar; do
    [ -f "$c" ] && CORE="$c" && break
  done
fi
if [ -z "$CORE" ]; then echo "core.jar not found; set PROCESSING_CORE=/path/to/core.jar"; exit 1; fi
export CORE
