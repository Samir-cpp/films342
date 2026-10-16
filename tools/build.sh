#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tools/setup.sh --exports
GODOT_BIN="$(cat .tools/godot-path)"
export HOME="$PWD/.tools/home"
export XDG_DATA_HOME="$PWD/.tools/data"
export XDG_CACHE_HOME="$PWD/.tools/cache"
mkdir -p builds/{linux,windows}
touch builds/.gdignore
for target in Linux Windows macOS; do
 case "$target" in
  Linux) output="builds/linux/TheDirector.x86_64" ;;
  Windows) output="builds/windows/TheDirector.exe" ;;
  macOS) output="builds/TheDirector-macOS.zip" ;;
 esac
 "$GODOT_BIN" --headless --path . --export-release "$target" "$output" > ".tools/export-$target.log" 2>&1
 if grep -E 'SCRIPT ERROR|Parse Error|ERROR:' ".tools/export-$target.log"; then exit 1; fi
 echo "Exported $target -> $output"
done
chmod +x builds/linux/TheDirector.x86_64
cp README.md LICENSE docs/GODOT_COPYRIGHT.txt builds/linux/
cp assets/fonts/OFL.txt builds/linux/
cp README.md LICENSE docs/GODOT_COPYRIGHT.txt builds/windows/
cp assets/fonts/OFL.txt builds/windows/
(cd builds/linux && zip -q -r ../TheDirector-Linux.zip .)
(cd builds/windows && zip -q -r ../TheDirector-Windows.zip .)
python3 - <<'PACK'
import zipfile,pathlib
with zipfile.ZipFile("builds/TheDirector-macOS.zip","a",zipfile.ZIP_DEFLATED) as z:
 for source,name in [("docs/GODOT_COPYRIGHT.txt","GODOT_COPYRIGHT.txt"),("assets/fonts/OFL.txt","OFL.txt"),("LICENSE","LICENSE"),("README.md","README.md")]:
  z.write(source,name)
PACK
python3 tools/package_source.py
(cd builds && sha256sum TheDirector-*.zip > SHA256SUMS.txt)
echo 'Desktop archives and source package ready under builds/'
