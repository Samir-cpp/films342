#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -f .tools/godot-path ]]; then bash tools/setup.sh; fi
GODOT_BIN="$(cat .tools/godot-path)"
export HOME="$PWD/.tools/home"
export XDG_DATA_HOME="$PWD/.tools/data"
export XDG_CACHE_HOME="$PWD/.tools/cache"
exec "$GODOT_BIN" --path . "$@"
