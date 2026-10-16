# Changelog

## 0.2.0 — 2026-10-16

- Added a recommended NEXT STEP action for each production phase, a valid quick-start director, a money/profit glossary, save feedback and confirmation before replacing a career. Auto time pauses at production gates.
- Added responsive phone portrait/landscape layouts, compact navigation, 52-pixel touch controls, safe-area insets, larger mobile type, scrollable event choices and form preservation across rotation.
- App backgrounding pauses time and autosaves. Android Back returns to the menu; iOS avoids an application Quit button.
- Casting-board searches filter names and crew roles; tab and search selection survive hiring.
- Added Android APK and iPhone/iPad Xcode export presets, verified SDK bootstrap, mobile build/packaging scripts and an artifact-producing GitHub Actions workflow. Android packages use a local debug key; iOS team is an explicit placeholder.
- Baked original audio offline to reduce mobile startup work. Virtual-keyboard resizing preserves the focused editor and open name dialog.
- Added mobile layout/lifecycle, quick-start and recommendation regression coverage. Platform execution evidence and remaining limitations are recorded in docs/VALIDATION.md.

## 0.1.0 — 2026-10-16

1. **Skeleton / data:** Godot 4.6.3 project, typed DataManager access, schemas, 543 seed records and validated fictional content. Initial economy suite: 18/18 tests passed.
2. **Career / persistence:** native menu and character point-buy, eight backgrounds, two traits, five JSON slots plus autosave, full-precision RNG restoration and migration. Covered in career regression tests.
3. **Calendar / dashboard:** weekly time, pause and speed, calendar holidays, cash / reputation / burnout, inbox and seasonal competitor slate. Headless UI smoke check passed.
4. **Development / financing:** original/adaptation/remake sources, script drafting, rewriting / consultant, producer negotiation and self-financing. End-to-end exercised.
5. **Package / shoot:** performer and crew boards, weekly availability, real cost accounting, scouting, permits, lean / balanced / reshoot choices, events and burnout. End-to-end exercised.
6. **Post / marketing / rights:** edit choices, rating restrictions, spend/hype, release date and screens, deferred exclusive rights. Duplicate licensing and delayed-backend regression tests passed.
7. **Box office:** eight-week opening / retention simulation, producer shares and recoupment, charts, review text, final statement. Formula tests and full run passed.
8. **Career continuation:** award campaigns and wins, archive, rights windows, royalties, restored cuts, sequel / reboot sources and retirement. An end-to-end test completes both the first film and a sequel.
9. **Presentation:** teal / gold native UI, generated city/poster art and portraits, original procedural loop and UI tone, scalable panels, Bengali font, settings, achievements, contextual hints. Rendered screenshots inspected on a virtual X11 display.
10. **Packaging:** Linux, Windows and macOS presets, checksum-verified template setup and source / desktop archive build scripts. Platform runtime verification is recorded in docs/VALIDATION.md.

These milestones describe this first edition's implemented loop. Additional production-scale systems and seeded-only data categories are listed explicitly in README.md; they are not marked complete merely because their database exists.
