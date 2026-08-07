---
name: daily-routine
description: Run the guarded maintenance sweep for flutter_calendar_carousel without overwriting local work or implicitly merging releases.
---

# /daily-routine

Run the sweep against fresh `origin/main`. If the current checkout is dirty or
behind, use a detached temporary worktree and remove it afterward; never overwrite
or stash an unrelated active checkout merely to run maintenance.

Run daily quality checks with the official current stable Flutter SDK. If the
active SDK is on `beta`, `dev`, or a stale stable revision, use an isolated SDK
at the current stable release instead of changing the user's global checkout.
Never report `main` as red from a beta/dev test-runner failure unless the same
failure reproduces on current stable.

## Daily Sweep

1. Fetch `origin main --tags --prune`. Record origin SHA, latest tag, commits
   since tag, open issues/PRs, and exact Flutter/Dart versions.
2. Run `flutter pub outdated --json`. Separate actionable direct/dev upgrades
   from transitive versions constrained by Flutter/Dart.
3. Run root format, analysis, tests with coverage, and publish dry-run.
4. Run example `pub get`, analysis, tests, and Android debug build.
5. Inspect failed CI, release, and publish runs plus actionable open issues and
   PR feedback. Avoid duplicate tracking comments or issues.
6. For each clear safe maintenance item, create one scoped branch and PR, run
   `.claude/commands/verify-all.md`, then enter `/review-pr`.

Never push directly to `main`, batch unrelated fixes, edit contributor branches
without permission, weaken a gate, merge, publish, or release without explicit
authority.

## Review Loop

`.claude/commands/review-pr.md` and `.codex/skills/review-pr/SKILL.md` are the
canonical review procedure. Fix valid findings, cover unavailable reviewers with
one exact-head self-review, and poll every five minutes until two clean snapshots.
Opening a maintenance PR does not imply permission to merge it.

## Issue Triage

- Apply existing labels when classification is clear.
- Let the configured stale workflow handle age-based closure.
- Link duplicates with evidence.
- Distinguish repository fixes from external pub.dev, GitHub App, platform, or
  Flutter limitations.
- Create/update a tracking issue for red `main`, failed dependency upgrades,
  Flutter stable regressions, or release/publish failures only when one does not
  already exist.

## Report

Return repository freshness, SDK versions, dependency status, format/analyze/test
and coverage results, example build status, publish dry-run, PR review state,
issues touched, temporary-worktree cleanup, and precise blockers.

Weekly runs may prepare grouped compatible dependency upgrades and changelog
maintenance. Monthly runs verify the newest stable Flutter and sweep deprecated
APIs. Both use the same verification and no-implicit-merge rules.
