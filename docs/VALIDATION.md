# Validation record — 2026-10-16

Validated in the provided Linux cloud workspace with **Godot 4.6.3 stable**, **GUT 9.6.1** and Python 3. No credentials or application services were needed.

## Observed results

- `python3 tools/validate_data.py`: **PASS**, 29 schema-validated content documents, 543 named records, including 150 event records and 40 synthetic calibration films.
- `bash tools/test.sh`: **PASS**, 3 test scripts, **34 tests, 166 assertions**, no failed/skipped tests or script errors. It includes economy formulas, producer shares/advance recoupment, borrowing, rights exclusivity, late backend on losses, seed replay, full-precision JSON replay, five manual slots, weekly autosave, migration, corrupted/future-save rejection and retirement.
- Visible-form regression: a character is created by invoking the UI's actual Begin button, a screenplay is created through the visible form's Develop button, and Next week advances that career.
- Headless native-scene smoke: **PASS**, 13 menu/career screens and all 10 active-film stages instantiated. This is script/layout construction evidence, not a substitute for human interaction on every OS.
- End-to-end source verification: **PASS**, two completed releases, OTT/TV/music licenses, an award win, catalog income, a sequel and JSON reload. Seed 342 produced first-film quality ~98.9 / gross ~1117.3 lakh and sequel quality ~96.5 / gross ~487.7 lakh using a deliberately strong, legal point-buy profile. Ordinary starting profiles are less capable.
- **Exported Linux binary**: the same `--verify-career` route passed, proving the exported data and runtime support the two-film loop, rather than only the editor copy. It uses a separate `.tools/binary-verification/` data directory.
- Graphical rendering: a native X11 window rendered through Mesa llvmpipe. Main menu, character creation, dashboard, film studio and release calendar were captured and inspected, including the 1280×720 window size. Screenshots are generated under `builds/screenshots/`. The virtual driver reports unsupported VSync; this did not prevent rendering.
- Official Godot export-template SHA-512 verified against the release manifest. The recorded digest is in `docs/export-templates.sha512`.
- Linux x86-64, Windows x86-64 and macOS universal ZIP exports succeeded. All archives pass ZIP CRC checks and SHA-256 verification when produced. Desktop exports exclude GUT and test-only dependencies. The source ZIP includes the editor project and vendored tests.
- Setup was exercised repeatedly without regenerating edited content. Tests use isolated saves. The repository began with no commits or files; all project files are new, with tool caches, saves and build outputs ignored. No remote push or Git commit was made.

## Reproduce

```sh
bash tools/test.sh
bash tools/build.sh
XDG_DATA_HOME="$PWD/.tools/binary-verification" \
  builds/linux/TheDirector.x86_64 --headless -- --verify-career
XDG_DATA_HOME="$PWD/.tools/binary-ui-verification" \
  builds/linux/TheDirector.x86_64 --headless -- --smoke-ui
(cd builds && sha256sum -c SHA256SUMS.txt)
```

The verification flags intentionally create a test career and save files; always give them an isolated XDG data directory. Regular play does not trigger these flags.

## Limits of the evidence

Windows/macOS exports were **not run on their target operating systems**. macOS signing and notarization are not configured. Actual speaker playback was not evaluated: the cloud machine has no audio device; music and tones were generated and the UI was rendered using the dummy audio driver. Hardware gamepad navigation and 4K human inspection are unrun. Source opens at a resolution-independent base and scrolls, but there has been no broad cross-device usability test.

This is a first playable edition. A passing release/award/sequel loop does not establish completion of the larger systems listed as limitations in README.md. Financial values and benchmark scenarios are fictional estimates; this is not historical economic validation or comprehensive gameplay balance testing. Environment configuration saving does not publish an environment or prove restoration in a fresh task.
