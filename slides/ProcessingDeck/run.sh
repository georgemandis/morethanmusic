#!/bin/sh
# Build ProcessingDeck with the Processing CLI, run it with the Java inside Processing.app.
#
#   slides/ProcessingDeck/run.sh                        # 1280x720 window (press f for full screen)
#   slides/ProcessingDeck/run.sh --fullscreen            # start full screen
#   slides/ProcessingDeck/run.sh --window=1920x1080 --slide=5 --frags=2 --mode=laser --shot=/tmp/deck.png
#                                                        # start there, save a screenshot after 2.5 s, quit
#
# Same recipe as explorer/run.sh: `processing cli --run` opens no window on 4.5.6 / macOS, so this
# compiles with the CLI and launches the classes. --sketch-path makes the sketch find the markdown one
# folder up, as it does in the IDE.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="${PROCESSING_APP:-/Applications/Processing.app}"
OUT="${TMPDIR:-/tmp}/processing-deck-build"
BUILD_LOG="$("$APP/Contents/MacOS/Processing" cli --sketch="$HERE" --output="$OUT" --force --build 2>&1)"
echo "$BUILD_LOG"
case "$BUILD_LOG" in *Finished.*) ;; *) echo "build failed, not launching the old classes" >&2; exit 1 ;; esac
# -XstartOnFirstThread lets Processing's own fullScreen() survive on macOS 26, but it deadlocks CoreMidi4J
# (code/coremidi4j-*.jar, the hot-plug device list) before the first frame. The deck goes full screen
# through its own toggle and does not need the flag, so it is used only when the jar is not there.
FIRST_THREAD=""
ls "$HERE"/code/coremidi4j-*.jar >/dev/null 2>&1 || FIRST_THREAD="-XstartOnFirstThread"
exec "$APP/Contents/app/resources/jdk/bin/java" $FIRST_THREAD \
  -cp "$OUT:$HERE/code/*:$APP/Contents/app/resources/core/library/*" \
  -Xdock:name=ProcessingDeck processing.core.PApplet --sketch-path="$HERE" ProcessingDeck "$@"
