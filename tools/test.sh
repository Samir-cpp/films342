#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tools/setup.sh
GODOT_BIN="$(cat .tools/godot-path)"
export HOME="$PWD/.tools/home"
export XDG_DATA_HOME="$PWD/.tools/test-data"
export XDG_CACHE_HOME="$PWD/.tools/cache"
"$GODOT_BIN" --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit 2>&1 | tee .tools/tests.log
"$GODOT_BIN" --headless --path . -- --smoke-ui 2>&1 | tee .tools/ui-smoke.log
if grep -E 'SCRIPT ERROR|Parse Error|ERROR:' .tools/tests.log .tools/ui-smoke.log; then exit 1; fi
grep -q 'UI_SMOKE_OK' .tools/ui-smoke.log
