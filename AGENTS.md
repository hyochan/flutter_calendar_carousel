# flutter_calendar_carousel Agent Guide

This file is the repository-wide source of truth for Codex, Claude Code, and
other coding agents. `CLAUDE.md` and `GEMINI.md` point here. Detailed reusable
workflows live in `.codex/skills/`; Claude adapters live in `.claude/skills/`,
and user-invoked command entry points live in `.claude/commands/`.

## Repository Scope

- Package: `flutter_calendar_carousel`
- Default branch: `main`
- Public package source: `lib/`
- Regression tests: `test/`
- Consumer smoke app: `example/`
- CI and publishing: `.github/workflows/`

## Non-Negotiables

- Preserve public API compatibility unless the user explicitly authorizes a
  breaking change. Treat exported types, constructor parameters, callbacks,
  defaults, and date-selection behavior as public contracts.
- Reproduce an issue and add a focused regression test before changing behavior
  whenever practical.
- Test the package as both a library and a real Flutter consumer. Example native
  scaffolding must remain compatible with the current stable Flutter release.
- Do not weaken analysis, tests, publishing validation, or release safeguards to
  make a change pass.
- Do not edit generated lockfiles or native project metadata by hand when the
  corresponding Flutter, CocoaPods, or Gradle command can regenerate them.
- Preserve unrelated user changes. Never use destructive Git recovery commands.
- Do not commit directly to `main`, force-push, merge, publish, or release unless
  the user explicitly authorized that action.

## Verification

Run the smallest sufficient set while iterating. Before a cross-cutting PR or a
Flutter/dependency/tooling update, run the full matrix:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
(cd example && flutter pub get && flutter analyze && flutter test)
(cd example && flutter build apk --debug)
flutter pub publish --dry-run
git diff --check
```

Also build the iOS example for a simulator when iOS project or dependency files
change and macOS/Xcode is available. For release or compatibility claims, use
the exact latest stable Flutter SDK rather than relying only on a locally
installed channel that may be behind.

`flutter pub outdated` distinguishes actionable direct/dev upgrades from
transitive packages constrained by the Flutter SDK. Do not force transitive
versions through `dependency_overrides` merely to report everything as latest.

## Issues And Pull Requests

- Use English for public GitHub titles, bodies, reviews, replies, and commits.
- Link fixes to issue numbers and preserve evidence for issues that are already
  fixed, externally blocked, duplicates, or platform limitations.
- Reply to inline review comments through the inline reply API, not a new
  top-level PR comment.
- Resolve a review thread only after its valid finding is fixed and pushed, or
  after an evidence-backed reply shows why no code change is appropriate.
- A requested review loop never implies merge authority. Stop at a clean,
  verified PR unless the user explicitly asks to merge.
- Follow `.codex/skills/review-pr/SKILL.md` for review polling and
  `.claude/commands/review-pr.md` as the shared command entry point.

## Commits And Releases

- Use Conventional Commits, for example `fix(ci): authenticate pub publishing`.
- Stage only the files belonging to the current change and inspect the staged
  diff before committing.
- Release metadata is owned by `.github/workflows/release.yml`; publishing is
  owned by `.github/workflows/publish.yml` and pub.dev trusted publishing.
- A release version change must refresh and commit `example/pubspec.lock`. The
  ignored root lockfile must not be force-added.

## Workflow Synchronization

- `.codex/skills/` contains the complete, agent-agnostic procedures.
- `.claude/skills/` contains thin adapters that point to those canonical files.
- `.claude/commands/` contains concise command entry points and repository check
  matrices. Do not copy a second independent review or rebase algorithm there.
- When a canonical skill changes, verify its Claude adapter and command mapping
  in the same commit.
