---
name: verify-all
description: Run the full flutter_calendar_carousel package, example consumer, native build, publishability, and repository consistency matrix.
---

# /verify-all

Use the exact latest stable Flutter SDK when claiming latest compatibility.
Record `flutter --version` and `dart --version` with the result.

## Required Matrix

```bash
set -euo pipefail

flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter pub outdated

(
  cd example
  flutter pub get
  flutter analyze
  flutter test
  flutter build apk --debug
)

flutter pub publish --dry-run
git diff --check
```

When iOS project or dependency files changed and macOS/Xcode is available, also
run an iOS simulator build from `example/`. When public web compatibility is in
scope, build a minimal temporary Flutter web consumer that imports the package.
Keep all temporary consumers outside the repository and remove them afterward.

Validate changed GitHub workflow YAML. For release/publish shell changes, run a
non-destructive simulation in a temporary worktree or copy so ignored and
generated file behavior is exercised.

## Dependency Interpretation

Use `flutter pub outdated --json` when machine-readable classification helps.
Update direct and dev dependencies to their latest compatible resolvable
versions. Report transitive latest-only versions constrained by Flutter/Dart
separately; do not force them with `dependency_overrides`.

## Completion

Fail on the first real error, preserve full failure output, and do not call the
result regression-free when a required platform check was skipped. Report each
command, SDK version, pass/fail result, and justified skip.
