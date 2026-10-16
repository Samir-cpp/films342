# THE DIRECTOR: Dhallywood

A native, single-player Godot desktop filmmaking career simulation. This is **v0.2, a playable desktop and mobile edition**, not a browser game. Create a director in Bangladesh in 2026, write a film, pitch financing, hire an ensemble, shoot, edit, market, license rights, release over eight weeks, campaign for awards, and build a catalog with sequels and restored cuts.

## Download from GitHub

Choose your platform. Desktop ZIPs run after extraction; Android has a directly installable test APK. iOS is an Xcode project that must be built and signed on a Mac:

- [Android APK — debug-signed test build](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-Android.apk)
- [Android ZIP / installation notes](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-Android.zip)
- [iPhone / iPad Xcode project — not an installable IPA](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-iOS-Xcode.zip)
- [Windows ZIP](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-Windows.zip)
- [Linux ZIP](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-Linux.zip)
- [macOS ZIP (unsigned)](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-macOS.zip)
- [Godot source ZIP](https://github.com/Samir-cpp/films342/raw/refs/heads/main/downloads/TheDirector-Source.zip)
- [SHA-256 checksums](downloads/SHA256SUMS.txt)

Windows/macOS remain cross-built and unrun on those systems. iOS signing and Xcode compilation require your Mac and Apple team. Read [Mobile installation and signing](docs/MOBILE.md) before downloading the iOS project. This playable edition still has the simulation-depth limitations listed below.

## Download and play

Release archives are produced in `builds/`:

- **Windows x86-64:** extract `TheDirector-Windows.zip`, run `TheDirector.exe`.
- **Linux x86-64:** extract `TheDirector-Linux.zip`, run `chmod +x TheDirector.x86_64 && ./TheDirector.x86_64`.
- **macOS (universal template):** extract `TheDirector-macOS.zip` and open `TheDirector.app`. This development build is unsigned and unnotarized. A distributed commercial release needs an Apple developer signature and notarization; macOS may block an unsigned download. The macOS application has not been run on a Mac here.
- **Source:** extract `TheDirector-Source.zip` and import `project.godot` into **Godot 4.6.3 stable**. Press F6 on `scenes/main.tscn` or F5 to play. No plugins, credentials, external servers or downloads are required to play or open the bundled source.

Windows and macOS exports are cross-built on Linux. Linux is the runtime tested platform. Checksums are in `builds/SHA256SUMS.txt`.

## First film / controls

1. **Quick start** → enter a name to start with a balanced 405-point director and two recommended traits. Or choose **Create your own director** → enter your name and identity, choose a background and **exactly two traits**. Spend up to **405 points**; bonuses are added afterward. A seed produces a repeatable world.
2. Follow **NEXT STEP** on Dashboard or Film studio. It recommends the action needed for the current stage. New screenplay → enter title, logline and synopsis, choose genre, theme, setting, tone, era, certificate, source and budget tier. Sequels / reboots require a previous archived film.
3. Film studio → **Next week** advances drafting. Consultants and rewrites improve the script. A screen-specific tutorial stays above the choices for each stage.
4. Pitch a producer. Larger backend demands and more creative control reduce acceptance. A rejected pitch consumes a week. Alternatively self-finance if you can cover the budget.
5. Hire at least one performer and one crew member; lock the package. Failed availability checks are fixed for that week. Crew roles and supporting performers can be added up to the package limits.
6. Choose scouting / safety, location and budget ceiling. Advance into shooting. Choose balanced, cheaper coverage or reshoots. Costs, risk and burnout matter.
7. Choose the post-production approach and certificate; market with a weekly campaign allowance. Advance into distribution.
8. Book screens and an absolute career release week. Check holidays and rival releases. License OTT, television, music and overseas territories. Each category is exclusive, except distinct overseas territories.
9. Open in cinemas when the date arrives. Advance eight weeks to see gross, producer receipts, reviews, retention and profit. Handle the event overlay whenever it appears.
10. Campaign for awards, archive the film, use Filmography to create a sequel or restored release. Deferred license payments and catalog royalties continue across weeks. Career offers training, paid advertising work, recovery, mentoring, loans, a production-house milestone and retirement.

**Mouse:** all controls. **Keyboard:** Tab / Shift+Tab focus, arrows for selectors, Enter / Space activate focused controls. **N:** next week. **Space** with no control consuming the key toggles auto-time. **Esc:** menu. Text entry preserves ordinary typing. Calendar runs at 1× / 2× / 4× and pauses for events, screen changes, backgrounding and production decision gates. The How to play screen explains money, profit splits and recovery. The casting board supports search by name/role and retains its tab/filter after a hire. Save before retirement to preserve a return point.

Settings provide independent music / UI sound, UI scale, font size, fictional-name mode and a Bengali navigation preview. The interface adapts from phone portrait through wide desktop windows. Phones use a compact page selector, stacked cards, larger controls and scrollable event choices; notches use the platform safe area. Portrait/landscape changes preserve unfinished forms. Desktop uses the familiar sidebar. Bengali names and text can be entered using the bundled Noto Sans Bengali font.

## Development

Requirements: Godot **4.6.3 stable**, Python 3, Bash, curl, unzip and zip (for the Linux build scripts). GUT **9.6.1**, matching Godot 4.6, is vendored under `addons/gut/`. No Python packages are required.

```sh
bash tools/setup.sh           # validate data and import; downloads Godot only if absent
bash tools/run.sh             # native window on a machine with a display
bash tools/test.sh            # GUT + all-screen/stage smoke test, isolated test saves
bash tools/build.sh           # verified templates; export Linux, Windows and macOS; package source
```

Set `GODOT_BIN=/path/to/godot` if the binary is not called `godot`. Setup deliberately rejects a different engine version. Build presets are also available from Godot's Export dialog; install the matching templates there when exporting outside the scripts. `tools/setup.sh --exports` downloads the official templates (~1.2 GB, selected templates occupy ~290 MB). Downloads retain TLS checks and are checked against official SHA-512 manifests. Re-running setup and tests is supported. Setup never regenerates your edited data.

In this cloud workspace, scripts keep tool state under ignored `.tools/` and generated archives under ignored `builds/`. No application service must remain running. A graphical desktop is required for interactive desktop play, while tests run headless. Android runs as a native app. For mobile packaging, use `python3 tools/build_mobile.py --accept-sdk-licenses` after desktop setup; see docs/MOBILE.md. A GitHub Actions mobile workflow can be dispatched to build APK/Xcode artifacts without storing signing credentials. This task uses the existing isolated checkout; no extra worktree is needed.

## Data and extension points

`res://data/` contains **543 named records** in 30 editable content files, including 150 event records (15 archetypes with 10 production contexts), 40 explicitly synthetic benchmark films, eight backgrounds, 10 traits, 85 performers, 72 crew entries, producers, financiers, studios, halls, markets, platforms, channels, labels, agencies, press, awards, rules, holidays, locations and reviews. `schemas.json` contains per-document JSON schemas. `python3 tools/validate_data.py` validates schema shapes and gameplay invariants. Runtime DataManager also rejects malformed or duplicate record IDs.

- Change balancing values in `economy.json`; all monetary amounts are **lakh BDT** (৳100,000), not taka or crore. Tier daily shoot costs are 3.5 / 5.5 / 7.5 lakh. More expensive stars and crew can cause an overrun.
- Add / edit events in `events.json` with stage and minimum-week conditions and two or three choices. Effects change cash, quality, hype, stress and producer relationship. Chosen events are recorded and not repeated in that career.
- Add locale keys in `localization.json`; the English UI is playable. Bengali font support and navigation examples are included, **not a complete Bengali translation**. UI prose is not yet fully extracted from scripts.
- Replace `scripts/ui/art_panel.gd` to supply your own portraits and posters. Artwork is generated locally; original music and button tones are baked offline into replaceable WAV assets to avoid expensive mobile startup work. No paid or externally licensed stock art is required.
- All characters are fictional. Real platform, channel and award names are role labels only, not endorsements. No invented scandals, private details or quotations are attached to public people. The name toggle applies to records marked `real_person: true` if such records are added; it does not rename backgrounds, genres or businesses.
- These are **estimated gameplay numbers**. The 40 benchmarks are synthetic scenarios, not assertions about actual Bangladeshi film budgets or grosses. Holidays use approximate annual planning weeks, not a verified lunar calendar.
- `tools/generate_audio.py` intentionally rebuilds the original audio assets; normal setup does not regenerate them.

`tools/generate_data.py` deterministically rebuilds the seed database and schemas. Run it **only when intentionally replacing the seed data**; it overwrites edits.

## Simulation and saves

Formulas are in `scripts/sim/economy.gd`; derivation and accounting are in `docs/ECONOMY.md`. A dedicated `RandomNumberGenerator` is seeded per career; its full state is serialized as a decimal string to avoid JSON integer precision loss. JSON uses full float precision. UI art and audio never consume simulation RNG. Availability, event selection, pitches, rivals and awards use the career RNG.

Save files use `user://saves/`: `slot_1.json` through `slot_5.json` and weekly `autosave.json`. Saving writes a temporary file then renames it, retaining the previous file as `.bak`. A version-1 migration adds achievements and seen-event state; unsupported / corrupt slots are not loaded. Back up saves before editing them. Settings are stored separately in `user://settings.json`. With the cloud scripts, user data lives below `.tools/data/godot/app_userdata/`; test data is isolated below `.tools/test-data/`.

Autoloads: EventBus, DataManager, Localization, GameState, SaveManager, Clock and AudioManager. UI is separate from state transitions and pure economic formulas. JSON is accessed through typed DataManager methods, while mutable save records are dictionaries for migration and editing.

## Current depth and limitations

The core career → release → rights → award → sequel loop is implemented and tested, including finishing the sequel. This first edition simplifies several requested systems:

- Financing currently operates through producers and self-financing. Investor, studio, distributor and agency databases are seeded extension content; there are no separate interactive co-production, brand-financing or stolen-pitch systems.
- Packaging models performer / crew fees, skill, star power and weekly availability. There is no detailed relationship chemistry matrix, role-specific production modifier, individual crew simulation or daily call-sheet interface.
- Censor review models certificate restrictions and quality cuts; bans, appeals and political/legal narrative branches are not implemented. Marketing is a composite spend/hype model rather than distinct timed campaigns for each medium.
- Rival releases are seasonal simulated slates, not full autonomous production careers. Theater receipts use aggregate capacity and fixed single/multiplex proportions rather than negotiating each cinema hall individually. Review prose is selected by quality band.
- Awards use quality thresholds and seeded jury variation. A production house is a career milestone, not a second multi-project business layer. International employment, producing others' films, spin-offs, endorsements, legal disputes and richer comeback narratives remain expansion work.
- The tutorial combines a recommended-next-action panel, Quick start and How to play, rather than a scripted narrative campaign. Gamepad support, platform signing, full translation, accessibility certification and broad human playtesting are not included. Windows/macOS runtime and real audio-device playback need platform testing.

See `docs/VALIDATION.md` for observed checks and `CHANGELOG.md` for milestone scope. This is a runnable desktop foundation with an end-to-end loop; it is not a claim that every system in the original production-scale brief is finished.

## Layout / licenses

```text
assets/       procedural icon and bundled Bengali font / license
addons/gut/   MIT-licensed GUT 9.6.1
scenes/       entry scene
scripts/      autoloads, pure simulation, native UI and art interfaces
data/         editable content and schema registry
tests/        GUT economy and career regression tests
tools/        desktop/mobile setup, validation, run, test, export and packaging scripts
docs/         formulas, validation, roadmap and template checksum
builds/       generated desktop/source ZIPs (ignored by Git)
```

Project code, data, procedural art and generated sounds: MIT, see LICENSE. Noto Sans Bengali: SIL OFL 1.1, see `assets/fonts/OFL.txt`. GUT's MIT notices are retained in its sources. Godot is MIT-licensed; engine notices are bundled with binary releases in `GODOT_COPYRIGHT.txt`.
