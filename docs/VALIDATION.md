# Version 0.3 PC validation — 2026-10-16

- **48 GUT tests / 2,958 assertions passed**, with no skipped or failed tests. Includes PC navigation/save shortcuts and typing/dialog protection alongside the prior simulation and mobile layout checks.
- Headless UI smoke passes all 14 screens and all ten production stages.
- Native X11/Mesa graphical verification passes at **960×640, 1280×720 and 1920×1080**: actual viewport sizing, compact breakpoint, time-control dimensions, unsubmitted draft preservation and fullscreen/windowed transitions. Run with `DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 bash tools/run.sh --audio-driver Dummy -- --verify-pc-ui --silent-ui` when an X server is available.
- Desktop screens rendered at 1280×720 and inspected. The cloud graphics backend is software Mesa; GPU performance and speaker output are not verified.
- The rebuilt Linux binary passes the two-film career integration check (exclusive licenses, award win, catalog royalties, sequel, JSON reload) and the native graphical PC verifier. All four new desktop/source ZIP archives pass CRC checks.
- Desktop archives are cross-built with pinned Godot 4.6.3. Windows and macOS runtime testing remains unavailable here. macOS is unsigned. Mobile downloads remain the previously tested v0.2 packages; they were not rebuilt for this PC update.

The v0.2 record below describes the retained mobile artifacts and historical checks.

---

# Version 0.2 validation — 2026-10-16

- **46 GUT tests, 2,934 assertions passed**, no failed/skipped tests or script errors. Five test scripts cover the prior economic/career regressions plus next-action recommendations, production-gate pause, quick-start validity, touch layout bounds, 360-pixel portrait and landscape layouts for all ten film stages, zoom/large text, casting filter/tab retention, background save/pause, and keyboard resize preserving an editor or dialog.
- Headless UI smoke passes for **14 screens and all ten film stages**. Updated Linux exported binary completes two releases, rights sales, an award win, catalog royalties, a sequel and JSON reload. Desktop simulation behavior remains deterministic.
- **30 content documents / 543 named records** pass the bundled schemas and gameplay invariants. Player guide content is editable JSON.
- Phone portrait/landscape screens rendered under native X11/Mesa with the mobile UI mode. Android APK installed successfully in the Android 9 / API 28 x86-64 emulator and Android reported the launcher activity started successfully. The actual game menu rendered in the emulator with the host Mesa graphics backend.
- Android APK signature verification passes v2/v3 schemes. Manifest minimum API is 24, target API is 36 (from the official Godot template), and ABIs are ARM64 and x86-64. Game assets include the new guide and audio; test/GUT dependencies are excluded.
- Linux, Windows, macOS, Android test APK/ZIP and the unsigned iOS Xcode project export successfully. Xcode project, Info.plist structures and explicit team placeholder are checked. Archives are CRC-checked and SHA-256 hashes recorded when packaged.
- Audio was generated offline from original procedural waveforms and bundled as replaceable WAV resources. Speaker output is not acoustically verified in this environment.

## Platform limits

The emulator has no KVM acceleration and is slow enough to produce Android System UI timeouts. Its legacy SwiftShader GLES backend failed Godot canvas shader linking (fragment uniform limit); the host Mesa/llvmpipe backend initialized and rendered the menu. This is documented rather than treating an install/launch alone as a complete gameplay test. Physical Android devices, broad handset/GPU coverage and a full two-film Android touch playthrough are **not verified**. The two-film run is verified in the exported Linux binary; phone interaction/layout/lifecycle behavior is also covered by GUT.

The iOS ZIP is **an exported Xcode project, not an installable IPA**. Xcode compilation, Simulator execution, Apple signing, provisioning, TestFlight and real iOS devices require a Mac and the owner's Apple team; none are claimed here. Windows/macOS runtime checks remain unrun on those operating systems. Production store signing/publishing is not performed. The new GitHub Actions workflow is supplied; its remote execution is separate from these local results.

Source and new packages are prepared for the user's GitHub repository. The previous record below is historical evidence for 0.1, not the current feature/test count. Environment draft saves do not publish a snapshot or prove new-task restoration.

---

## Historical 0.1 record

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
