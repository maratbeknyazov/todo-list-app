# Flutter 3.x / Dart 3.x Migration Guide

This project started in 2019 and has been partially modernized. The following updates were applied in code:

- Updated `pubspec.yaml` SDK constraints for Dart 3 / Flutter 3.20+.
- Moved runtime packages from `dev_dependencies` into `dependencies`.
- Replaced `package_info` imports with `package_info_plus`.
- Replaced `OverscrollIndicatorNotification.disallowGlow()` with `disallowIndicator()`.
- Updated Dio timeout arguments from `int` milliseconds to `Duration`.
- Replaced several `FlatButton` usages with `TextButton` / `ElevatedButton` in high-impact logic/util files.

## Still needs manual work

### 1) Remaining deprecated `FlatButton` usages

There are still legacy button usages in multiple UI files (widgets/pages). Migrate each case as:

- `FlatButton` with only `onPressed` + `child` -> `TextButton`
- `FlatButton` with filled background (`color`) -> `ElevatedButton` or `FilledButton`
- Move visual properties into `style` via `TextButton.styleFrom(...)` / `ElevatedButton.styleFrom(...)`

Recommended command:

```bash
rg "FlatButton" lib
```

### 2) Flare (`.flr`) migration strategy

`flare_flutter` is obsolete. Choose one:

1. **Rive** (closest replacement for Flare lineage)
   - Replace `flare_flutter` with `rive`
   - Convert `.flr` assets to `.riv`
2. **Lottie**
   - Re-export animation JSON and use `lottie`
3. **Temporary placeholder**
   - Keep splash/login logic, but replace animation widget with static image or simple progress indicator until migration is complete

If splash animation blocks app startup, temporarily comment out animation usage in `splash_page` and navigate directly.

### 3) Android Gradle / AndroidX modernization

The Android project was generated with older templates. If build fails after Dart fixes, fastest recovery path:

1. Create a fresh app: `flutter create new_project`
2. Copy over:
   - `lib/`
   - `assets` folders (`images`, `svgs`, `flrs`, `local_json`)
   - merged dependency/config sections from `pubspec.yaml`
3. Re-apply app id/signing settings in the new Android project

For existing Android project:

- Run Android Studio migration: **Refactor -> Migrate to AndroidX**
- Upgrade Gradle, Android Gradle Plugin, Kotlin, and compile/target SDK to Flutter 3.20-era defaults.

### 4) Null Safety completion

Many files are still pre-null-safety style (nullable fields/params without explicit `?`, non-nullable locals potentially returning null, old constructor patterns). Continue incrementally:

- Add `required` for mandatory named constructor params
- Add nullable marker `?` where null is valid
- Replace implicit dynamic snapshot/data access with typed casts or generic `FutureBuilder<T>`
- Remove `new` and other legacy Dart 2 style where possible

### 5) Deprecated plugin replacements

- `package_info` -> `package_info_plus` (already started)
- `flutter_webview_plugin` -> `webview_flutter` (dependency switched; code migration still needed)
- `flare_flutter` -> `rive` or `lottie` (manual asset + widget migration needed)

## Suggested verification checklist

1. `flutter clean`
2. `flutter pub get`
3. `flutter analyze`
4. Fix remaining compile errors file-by-file
5. `flutter run`

