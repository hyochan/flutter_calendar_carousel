# 05 — Deployment

This guide describes the guarded path from `main` to pub.dev. A request to open
or review a PR does not authorize any step in this release path.

## Workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `ci.yml` | relevant pushes/PRs to `main`, manual | Format, analyze, root/example tests, 95% coverage floor, Android and JavaScript/Wasm Web consumer builds |
| `auto-release.yml` | weekly/manual | Choose patch/minor or stop for a breaking release, then dispatch release |
| `release.yml` | manual/auto-release dispatch | Validate, bump version, refresh example lock, changelog, commit, tag, GitHub Release |
| `publish.yml` | `v*` tag | Authenticate with pub.dev OIDC, verify, and publish |
| `stale.yml` | schedule | Manage inactive issues |

CI path filters include the complete `example/**` tree so lockfile-only and
native consumer changes cannot bypass verification.

## Release Workflow

`release.yml` accepts `patch`, `minor`, `major`, `current`, `rc-bump`, or
`finalize`, plus prerelease and GitHub Release flags. `finalize` is valid only
for an existing `-rc.N` version and removes that suffix without incrementing
the base version. It carries the matching RC notes, including the original
breaking-change and migration guidance, into the stable release notes.
Every dispatch must target `refs/heads/main`; the workflow fails before checkout
when another ref is selected. Validation then runs package dependency install,
format, analysis, tests, and publish dry-run. Weekly automation also stops for
a non-empty `[Unreleased]` `### Breaking changes` section, even when a squash
commit omitted a breaking-change marker, so major releases remain explicit.

For a new version the deploy job:

1. Updates root `pubspec.yaml`.
2. Runs `flutter pub get` in both the root and `example/`, which resolves the
   path dependency in `example/pubspec.lock` to the new package version.
3. Promotes the curated `[Unreleased]` notes into the new version and leaves a
   fresh `[Unreleased]` section. Commit subjects are used only when curated
   notes are empty.
4. Stages `pubspec.yaml`, `CHANGELOG.md`, and `example/pubspec.lock` only. The
   ignored root lockfile is intentionally not force-added.
5. Commits, tags `v{VERSION}`, pushes, and optionally creates a GitHub Release.

Do not manually ship code that assumes a different tag format.

## pub.dev Trusted Publishing

`publish.yml` runs for `v*` tags with `id-token: write` and environment
`pub-dev`. It checks out the tag, runs pinned `dart-lang/setup-dart` first to
provision the short-lived OIDC credential, installs stable Flutter, then runs
format, analysis, tests, publish dry-run, and `dart pub publish --force`.

One-time pub.dev package configuration:

1. Enable GitHub Actions automated publishing for
   `hyochan/flutter_calendar_carousel`.
2. Set tag pattern to `v{{version}}`.
3. Set the required environment to `pub-dev`.

The workflow fix can be verified locally, but successful publication is only
confirmed by a completed tag workflow and the new version appearing on pub.dev.
If a version is already published, make a new version; never move or recreate a
published release tag.

## Routine Maintenance

`.claude/commands/daily-routine.md` is the canonical sweep. It checks fresh
`origin/main`, direct/dev dependency drift, current stable Flutter compatibility,
root and example verification, publishing readiness, issues, PRs, and failed
workflows. Maintenance PRs enter `.claude/commands/review-pr.md`; they are never
implicitly merged.

## Required Configuration

- `CODECOV_TOKEN`: optional coverage upload secret. Missing token skips upload.
- `DEPENDENCY_UPDATE_PAT`: optional release checkout token used when a bot push
  must trigger downstream workflows.
- pub.dev trusted-publishing link: package-side configuration, not a repository
  secret.
- Branch protection: require the repository's CI and normal review policy.

## Failure Handling

- Red `main`: reproduce and land a focused fix PR; avoid destructive tag/history
  edits.
- Release failure: identify whether a commit or tag was already pushed before
  retrying. Never overwrite a published tag.
- Publish authentication failure: verify pub.dev repository, tag pattern,
  environment, OIDC permission, and setup-dart step; release a new patch after
  correcting it.
- Stale example lock version: rerun root `flutter pub get` after the root version
  bump and stage `example/pubspec.lock`.
