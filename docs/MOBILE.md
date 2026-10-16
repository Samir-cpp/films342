# THE DIRECTOR 0.2 — Android and iOS

## Android: install the test build

Download `TheDirector-Android.apk` from the repository's `downloads/` directory onto your Android device. Open it, allow **Install unknown apps** for the browser/file manager if Android requests that permission, and finish installation. Android 7.0+ (API 24) and a GLES 3-capable GPU are required; the APK includes ARM64 and x86-64. This is a **debug-signed test build**, not a Play Store release. The Android ZIP contains the same APK plus license and installation notes.

The app works offline; no account, payment, network access, storage permission or server is required. Saves stay in the app's private storage. Uninstalling the app removes local saves. An update signed with a different key cannot replace it directly. Keep the generated local debug key when producing test updates; do not upload it to GitHub. Store publishing needs your own securely managed release key and a release/AAB build, neither of which this task creates.

## iPhone / iPad: Xcode project, not an IPA

`TheDirector-iOS-Xcode.zip` contains the generated Xcode project, game content, Godot frameworks and privacy manifest for iPhone and iPad. **It cannot be installed by tapping the ZIP on an iPhone.** An installable iOS package must be built and signed on a Mac with Xcode and your own Apple signing identity.

1. Extract the ZIP on a Mac and open `TheDirector.xcodeproj`.
2. Select the TheDirector target → Signing & Capabilities. Replace the explicit `REPLACE_WITH_YOUR_TEAM_ID` placeholder by selecting your own development team. Change `org.dhallywood.director` to a bundle ID belonging to you if required.
3. Select a simulator or a connected iPhone/iPad and build/run in Xcode. Device builds need a matching signing identity and provisioning. Enable Developer Mode on a development device if prompted.
4. For TestFlight / App Store distribution, use your Apple Developer Program membership, configure distribution signing, archive and validate in Xcode, and upload through Apple's normal workflow. Store review, signing, screenshots, privacy declarations and distribution are outside this build.

The exported project was generated on Linux and structurally inspected; **Xcode compilation, Simulator launch, physical iOS devices and App Store approval are not verified here**. The team ID is intentionally a placeholder, not an invented credential. No certificate or account credentials were requested or embedded.

To export from the source on a Mac, install Godot 4.6.3 and matching export templates using Godot's editor, open the source project, choose the iOS preset and configure your real team locally. The automated bootstrap below is intended for this Linux cloud workspace.

## Touch layout and player guidance

- Phones have a compact page selector instead of a desktop sidebar. Narrow portrait screens stack cards and forms; landscape uses wider panels. Tablets also work with the desktop layout when space permits.
- Primary interactive controls use at least 52 logical pixels on compact screens. Scroll containers support touch dragging; long event decisions scroll and buttons wrap.
- Android/iOS orientation uses the device sensor. Display-safe-area insets protect the interface around notches. Layout changes preserve unfinished character/screenplay form values.
- **Quick start** creates a valid 405-point director with two recommended traits. **NEXT STEP** on Dashboard and Film studio tells you what to do and offers the appropriate action.
- Automatic time pauses on financing, casting, distribution and completion. It also pauses when the app loses focus or enters the background. Backgrounding saves the career immediately; a process killed without any lifecycle notification still relies on the last completed autosave.
- **How to play** explains lakh BDT, ticket gross versus producer receipts, backend and recovery after a flop. Explicit save feedback and a confirmation before replacing a career reduce accidental loss.

## Rebuild in the Linux workspace

```sh
bash tools/setup.sh --exports
python3 tools/setup_mobile.py --accept-sdk-licenses
python3 tools/build_mobile.py
bash tools/test.sh
```

Python 3, Java 17+ (Java 21 tested), curl/unzip and Godot 4.6.3 are needed. The bootstrap uses verified official Godot templates and a checksum-pinned Android command-line tools archive. It installs only SDK build-tools 35.0.1, platform 35 and platform-tools; native Godot APK templates avoid a Gradle/NDK build. Downloads are retained in ignored `.tools/`; Android SDK licenses must be accepted to install missing components. No signing secrets belong in tracked presets or scripts.

The iOS project includes the real engine frameworks and compiled game pack. Source ZIPs remain small and can be exported again in Godot. Desktop releases are rebuilt from the same updated code.

## Test scope

GUT covers phone-width overflow, minimum touch target height, all ten film-stage layouts in portrait and landscape, rotation preserving a draft, app-background save/pause, valid quick start and context-sensitive recommendations. Headless tests exercise the two-film economic loop. Native rendered phone screenshots are inspected separately. APK signature and manifest are verified with Android SDK tools.

See `docs/VALIDATION.md` for the observed emulator/platform results. Passing layout tests or generating an APK is not proof of behavior on every Android handset or on iOS.
