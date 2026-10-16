#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
VERSION=4.6.3
mkdir -p .tools/bin .tools/home .tools/data
export HOME="$ROOT/.tools/home"
export XDG_DATA_HOME="$ROOT/.tools/data"
export XDG_CACHE_HOME="$ROOT/.tools/cache"
GODOT_BIN="${GODOT_BIN:-$(command -v godot || true)}"
if [[ -z "$GODOT_BIN" ]]; then
 archive="Godot_v${VERSION}-stable_linux.x86_64.zip"
 url="https://github.com/godotengine/godot/releases/download/${VERSION}-stable"
 curl -fL --retry 2 "$url/$archive" -o ".tools/$archive"
 curl -fL --retry 2 "$url/SHA512-SUMS.txt" -o .tools/SHA512-SUMS.txt
 python3 tools/verify_download.py ".tools/$archive" .tools/SHA512-SUMS.txt
 unzip -oq ".tools/$archive" -d .tools/bin
 GODOT_BIN="$ROOT/.tools/bin/Godot_v${VERSION}-stable_linux.x86_64"
 chmod +x "$GODOT_BIN"
fi
[[ "$($GODOT_BIN --version)" == "$VERSION.stable."* ]] || { echo "Use Godot $VERSION stable (or set GODOT_BIN)." >&2; exit 1; }
printf '%s\n' "$GODOT_BIN" > .tools/godot-path
if [[ "${1:-}" == "--exports" ]]; then
 target="$XDG_DATA_HOME/godot/export_templates/$VERSION.stable"
 if [[ ! -f "$target/linux_release.x86_64" || ! -f "$target/windows_release_x86_64.exe" || ! -f "$target/macos.zip" ]]; then
  archive="Godot_v${VERSION}-stable_export_templates.tpz"
  url="https://github.com/godotengine/godot/releases/download/${VERSION}-stable"
  curl -fL --retry 2 "$url/$archive" -o ".tools/$archive"
  curl -fL --retry 2 "$url/SHA512-SUMS.txt" -o .tools/SHA512-SUMS.txt
  python3 tools/verify_download.py ".tools/$archive" .tools/SHA512-SUMS.txt
  mkdir -p "$target"
  unzip -joq ".tools/$archive" 'templates/linux_release.x86_64' 'templates/windows_release_x86_64.exe' 'templates/macos.zip' 'templates/version.txt' -d "$target"
 fi
fi
python3 tools/validate_data.py
"$GODOT_BIN" --headless --editor --path "$ROOT" --import --quit > .tools/import.log 2>&1
if grep -E 'SCRIPT ERROR|Parse Error|ERROR:' .tools/import.log; then exit 1; fi
printf 'Setup OK: %s\n' "$($GODOT_BIN --version)"
