# 05 — Deployment (CI, Release, Publish, Daily Routine)

This guide describes how code moves from `main` to pub.dev.

## Workflows at a glance

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `.github/workflows/ci.yml` | `push`/`pull_request` on `main` | pub get → analyze → format-check → test (+coverage). Gate for merges. |
| `.github/workflows/auto-release.yml` | cron (Mondays 10:00 UTC) + `workflow_dispatch` | Decide bump (patch default, minor for `feat:`, skip on BREAKING), dispatch `release.yml`. |
| `.github/workflows/release.yml` | `workflow_dispatch` (also dispatched by `auto-release.yml`) | Version bump, CHANGELOG regen, commit, tag `v{VERSION}`, GitHub Release. |
| `.github/workflows/publish.yml` | tag push matching `v*` | Publish to pub.dev via OIDC (`dart pub publish --force`). Enabled; requires pub.dev-side OIDC setup. |
| `.github/workflows/stale.yml` | scheduled | Close stale issues. |

## ci.yml — what it enforces

- Runs on Ubuntu, Flutter `stable`.
- Path-filtered to `lib/**`, `test/**`, `pubspec.yaml`, `analysis_options.yaml`, and the workflow itself — no-op on README-only changes.
- Concurrency group cancels in-flight runs on the same ref.
- Steps: `flutter pub get` → `dart format --set-exit-if-changed .` → `flutter analyze` → `flutter test --coverage` → upload coverage to Codecov.
- Must be green before merge. No manual bypass.

## auto-release.yml — how releases happen without you

`auto-release.yml` runs on a weekly cron (Mondays 10:00 UTC). On each run it:

1. Finds the most recent tag via `git tag --sort=-creatordate | head -n1`.
2. If there are no commits since that tag → skip (nothing to release).
3. Otherwise, inspects commit messages in the `<prev-tag>..HEAD` range:
   - `BREAKING` or `!:` anywhere → **skip** and surface "human-dispatched major required".
   - Any `feat:` commit → **minor**.
   - Otherwise → **patch**.
4. Dispatches `release.yml` with the chosen bump.

If you need an off-cycle cut (e.g. a targeted `major`), just run:

```
gh workflow run release.yml -f version=major -f prerelease=false -f create_release=true
```

`auto-release.yml` and `release.yml` share a concurrency lock — only one release can be in flight at a time.

## release.yml — how to cut a release manually

Dispatched from the Actions tab (or via `gh workflow run release.yml`). This is the workflow `auto-release.yml` calls under the hood.

Inputs:

- `version`: `patch` | `minor` | `major` | `current` | `rc-bump`
- `prerelease`: `true` | `false` — wraps the version with `-rc.1` when bumping.
- `create_release`: `true` | `false` — whether to also create a GitHub Release.

Job graph:

1. **validate** — `flutter pub get`, `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`.
2. **deploy** (needs `validate`) —
   1. Parse current version from `pubspec.yaml`.
   2. Compute new version based on the input.
   3. Write new version back to `pubspec.yaml`.
   4. Regenerate `CHANGELOG.md` (PR titles from `git log <prev-tag>..HEAD`).
   5. Commit, tag `v{VERSION}`, push.
   6. If `create_release=true`, `gh release create v{VERSION}` with the CHANGELOG slice as body.

Tag format is **`v{VERSION}`** (e.g. `v2.5.5`, `v2.6.0-rc.1`). Do not ship any code that assumes another format — `publish.yml`'s trigger matcher depends on it.

## publish.yml — pub.dev via OIDC

Triggered by `push: tags: ['v*']`. Runs:

1. Checkout.
2. `subosito/flutter-action@v2` with stable Flutter.
3. `flutter pub get`.
4. `flutter pub publish --dry-run` (sanity gate).
5. Request OIDC token.
6. `dart pub publish --force`.

### OIDC bring-up checklist (one-time)

1. On pub.dev → package admin → "Automated publishing" → enable GitHub Actions publishing.
2. Set repository to `hyochan/flutter_calendar_carousel`.
3. Set tag pattern to `v{{version}}`.
4. Set allowed environment (blank is fine for this repo; optional `pub-dev` environment adds a review gate).
5. Confirm the workflow has `permissions: { id-token: write }` at job level.
6. Only after 1–5: remove the `if: false` guard in `publish.yml` (or uncomment the job) and land that change.

`publish.yml` is enabled and will run on every `v*` tag push. If pub.dev OIDC is not yet configured on the package's admin page, the first auto-release will fail at the `dart pub publish --force` step with an auth error — that is the signal to finish the pub.dev-side setup. Until then, the tag + GitHub Release will still be created; only the pub.dev upload step will fail.

## Daily routine (Cowork schedule skill)

A single consolidated scheduled task, `flutter-calendar-carousel-daily`, runs every weekday morning. It always does the daily block, and branches into the weekly block on Mondays and the monthly block on the 1st of the month. The routine definition is in `.claude/commands/daily-routine.md`.

**Daily block (every weekday)**
1. Repository freshness — fetch `origin/main` and run against latest remote state; use a clean temporary worktree when the mounted checkout has local changes.
2. Autonomous task queue — split actionable maintenance into small branches/PRs: failed sweep fixes, dependency/Flutter drift, CI/release/publish failures, automation gaps, and base-repo fixes for PR blockers.
3. Dependency check — `flutter pub outdated` and `flutter pub outdated --json`, split into direct/dev upgradable, direct/dev blocked, and transitive latest-only updates.
4. Code quality — `flutter analyze` + `dart format --set-exit-if-changed .` + `dart pub publish --dry-run`.
5. Tests — `flutter test --coverage`.
6. Issue/PR triage — label issues, mark clear duplicates, and report PR blockers such as missing CI, merge conflicts, guarded public API changes, SDK/dependency changes, or breaking commits.
7. PR lifecycle — for bot- or maintainer-authored maintenance PRs, monitor CI and bot reviews, push follow-up fixes when needed, approve/enable auto-merge only when all gates are green, and never push directly to `main`.

**Weekly block (Mondays only)**
8. Dependency update PR — if any direct/dev dependency has a safe compatible/resolvable update, open a PR bumping it, then run analyze, format, tests with coverage, and publish dry-run.
9. Blocked dependency tracking — if a package needs an SDK constraint change, unverified publisher dependency, or likely breaking major upgrade, create/update `maintenance: dependency upgrade blocked` instead of auto-merging it.
10. CHANGELOG tidy — surface any merged PRs since the last release so they don't get lost.
11. Breaking/release readiness — report commits since tag, `feat:`/`BREAKING`/`!:` commits, guarded public API path changes, and publish dry-run status.

**Monthly block (1st of month only)**
12. Flutter SDK compatibility — switch to/upgrade latest Flutter stable, then run analyze, format, tests with coverage, and publish dry-run.
13. Deprecated-API sweep — grep for `@Deprecated` usage that's been shipped for ≥1 minor release and propose removal for the next major.

The schedule entry itself lives in Cowork, not in this repo. Earlier iterations of this setup used three separate tasks (daily/weekly/monthly); those have been consolidated into one to reduce noise.

## Repo-specific knobs & secrets

- **`CODECOV_TOKEN`** — GitHub Actions secret used by `ci.yml` for coverage upload.
- **`DEPENDENCY_UPDATE_PAT`** — (optional) personal access token used by the weekly dependency-update PR so pushes trigger CI. If missing, the weekly job falls back to `GITHUB_TOKEN` and PRs will not re-trigger CI.
- **pub.dev OIDC link** — not a secret; configured on the pub.dev side (see above).
- **Repository `main` branch protection** — require `ci.yml` green + at least one review.

## When things go wrong

- **CI red on `main`** — revert the offending commit, file an issue, land the fix in a follow-up PR.
- **Release workflow failed mid-deploy** — inspect what got committed/tagged. If the tag went out but `publish.yml` didn't fire (or was disabled), you may need to re-push the tag. If `publish.yml` fired and pub.dev rejected, fix the cause and ship a new patch version.
- **pub.dev publish rejected for version already published** — version conflict. Bump to the next patch and re-release.
- **Wrong version in `pubspec.yaml` committed by hand** — revert; the workflow owns version bumps.
