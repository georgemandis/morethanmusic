#!/bin/bash
# Runs the Python Mode module tests under CPython 3 and, when Processing's Python Mode is installed,
# under its Jython 2.7, the runtime the sketches use.
HERE="$(cd "$(dirname "$0")" && pwd)"
status=0
if command -v python3 >/dev/null; then python3 "$HERE/run_tests.py" || status=1; else echo "python3 not found, skipping"; fi
JY="${JYTHON_JAR:-}"
[ -z "$JY" ] && for j in "$HOME/Documents/Processing/modes/PythonMode/mode/jython.jar" "$HOME/Documents/Processing/modes/PythonMode"/*/jython.jar; do [ -f "$j" ] && JY="$j" && break; done
if [ -n "$JY" ]; then java -jar "$JY" "$HERE/run_tests.py" 2>&1 | grep -v '^WARNING' || status=1; else echo "jython.jar not found (install Python Mode in Processing), skipping"; fi
exit $status
