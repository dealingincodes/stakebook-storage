# Stakebook (local-only bet tracker)

All data is stored on the phone (shared_preferences). No backend, no internet.

## Setup
1. `flutter create --platforms=android stakebook && cd stakebook`
2. Replace the generated `lib/` folder with the `lib/` folder from this project.
3. Merge the packages from `pubspec_additions.yaml` into your `pubspec.yaml`, then `flutter pub get`.
4. Set `android:allowBackup="true"` in AndroidManifest.xml (see ANDROID_MANIFEST_NOTES.md).
5. Plug in your phone (USB debugging on) and run `flutter run`,
   or build an installable file with `flutter build apk --release`
   (output: build/app/outputs/flutter-apk/app-release.apk).

## Using it
- Home: create funds (bankrolls). Overview shows total P/L, bet count, win rate.
- Tap a fund to see its bet history. + adds a bet, tap a bet to edit (e.g. mark Won/Lost),
  swipe left to delete.
- Menu (top right): Backup data (share a JSON file) / Restore data.
