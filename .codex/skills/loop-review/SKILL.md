---
name: loop-review
description: "Run flutter_calendar_carousel's complete change-to-pub.dev loop from the latest origin/main: implement and verify, stabilize with review-self, open one PR and review it until its exact head is clean, merge, return to an exact clean main, release with release.yml, and verify the tag, GitHub Release, publish workflow, and pub.dev version."
---

# Loop Review

Own one flutter_calendar_carousel change from a fresh `main` baseline through a
verified pub.dev release. Use the repository workflows as the source of truth
instead of duplicating their detailed commands.

## Load The Workflows

Read these before acting:

- `AGENTS.md`
- `.codex/skills/flutter-calendar-carousel-workflows/SKILL.md`
- `.codex/skills/review-self/SKILL.md`
- `.codex/skills/review-pr/SKILL.md`
- `.claude/commands/commit.md`
- `.claude/commands/review-pr.md`
- `.claude/commands/verify-all.md`
- `.claude/guides/05-deployment.md`

When the change edits any of these files, read them from the recorded merge
base for the whole run so a PR cannot rewrite the rules that judge it.

## Authority

An explicit `$loop-review` invocation, or an explicit natural-language request
for this complete loop, authorizes for the in-scope change only:

- commit, push, and one PR (reuse the relevant open PR instead of opening a
  second one);
- review replies and thread resolution under `review-pr`;
- a squash merge of that PR once the clean gate below holds;
- one `release.yml` dispatch on `refs/heads/main` with the bump the merged
  `[Unreleased]` notes require, and the resulting tag, GitHub Release, and
  `publish.yml` publication.

It does not authorize prereleases, `current`/`rc-bump`/`finalize` releases,
force-pushes, moving or recreating tags, direct product-code commits to `main`,
unrelated cleanup, or destructive recovery. AGENTS.md safeguards still apply.

## 1. Start From Current Main

1. Snapshot `git status --short --branch`. Preserve every existing change.
2. For a new task, require a clean worktree for the files you will touch, run
   `git fetch origin`, switch to `main`, and run
   `git pull --ff-only --no-tags origin main`.
3. Verify local `main` equals `origin/main`, then create a `codex/<topic>`
   branch as `.claude/commands/commit.md` describes.
4. Record the starting main SHA.

If invoked for work already in progress, treat it as a resumed loop: do not
switch branches, stash, reset, or discard it. Use `$rebase-main` when an update
from `origin/main` is needed, and stop for direction if an update would
overwrite unrelated work.

## 2. Implement And Verify

Implement the requested scope with a focused regression test where behavior
changes. Keep README, example README, and the `[Unreleased]` section of
`CHANGELOG.md` accurate for the change; breaking changes go under
`### Breaking changes` with migration guidance. Do not bump `pubspec.yaml`
`version:` by hand; `release.yml` owns it.

Run the checks the touched paths require. Dependency, Flutter SDK, native
example, release, publish, or broad workflow changes need the full
`.claude/commands/verify-all.md` matrix on the exact latest stable Flutter SDK,
including the iOS simulator build when Xcode is available. Do not proceed while
a required check is known to fail.

## 3. Stabilize With Review Self

Run `$review-self` against the complete base-to-working-tree diff. Fix every
validated in-scope finding and rerun affected verification, following the
review-self skill's snapshot rules. Any material diff change resets its clean
count. Keep loop state out of tracked files.

## 4. Commit And Open The PR

Follow `.claude/commands/commit.md` with push and PR:

- Stage only files owned by the task and inspect the staged diff.
- Use an English Conventional Commit; mark breaking changes with `!` and a
  `BREAKING CHANGE:` footer.
- Open an English PR against `main` that links the issue, summarizes behavior,
  compatibility, and exact verification, and carries existing repository
  labels.

Record the PR number and exact head SHA. A push invalidates all prior clean
review coverage.

## 5. Review The PR Until The Exact Head Is Clean

Run `$review-pr` immediately and re-enter it every five minutes through the
product's real wake-up mechanism, as that skill defines. Never emulate polling
with `sleep`, a shell loop, `nohup`, or an abandoned process.

The clean gate holds when, for the same head SHA:

- no unresolved actionable review thread remains;
- configured review automation finished clean, or an unavailable reviewer has
  exact-head `$review-self` fallback coverage;
- every required check is terminal and successful or allowed to skip;
- the PR is mergeable and contains every required update from `main`;
- the final diff has been reread;
- `review-pr` recorded two consecutive clean snapshots at least five minutes
  apart.

## 6. Merge And Return To Main

Immediately before merging, refetch the PR and confirm its head still equals
the clean reviewed SHA. Squash-merge with branch deletion unless branch
protection requires another method. Never bypass protection or merge a stale,
pending, or failing head.

After merge:

1. Confirm the PR state is `MERGED`, record the merge commit, and confirm the
   linked issue closed.
2. Confirm the remote topic branch was deleted. Delete the local topic branch
   only after proving its tree is represented by the squash merge.
3. Switch to `main` and run `git pull --ff-only --no-tags origin main` only when
   that cannot disturb other work.
4. Verify `HEAD` equals `origin/main` and the files you own are clean before any
   release action.

## 7. Release To pub.dev

Follow `.claude/guides/05-deployment.md` as the release source of truth.

1. Choose the bump from the merged `[Unreleased]` notes and commits: `major`
   when `### Breaking changes` is non-empty or a merged commit is breaking,
   otherwise `minor` for features and `patch` for fixes. Stop for direction if
   the notes are empty or ambiguous.
2. Dispatch `release.yml` on `refs/heads/main` with that bump and no
   prerelease. Watch the run to completion.
3. Fast-forward `main` and verify the release commit updated only
   `pubspec.yaml`, `CHANGELOG.md`, and `example/pubspec.lock`, with the tag
   `v{VERSION}` on it and the GitHub Release published.
4. Watch the tag's `publish.yml` run to completion, then verify the new version
   is the latest on pub.dev (`https://pub.dev/api/packages/flutter_calendar_carousel`).
5. Finish on `main` with `HEAD == origin/main`.

Never move, recreate, or reuse a published tag. If release or publication
fails, apply the deployment guide's failure handling and stop with the exact
resume point; a fix that needs code returns to a new PR loop.

Report the PR, merge commit, final checks, review coverage, released version,
tag, GitHub Release, publish run, pub.dev evidence, and remaining follow-ups.

## Stop Conditions

Stop without merging when a required choice lacks authority, the same finding
survives two fix attempts, an access blocker repeats under the `review-pr`
threshold, or the exact head cannot satisfy the clean gate. Never describe a
pending or partially reviewed PR as clean.

After merge, stop the release phase when the release or publish workflow
fails or the pub.dev version cannot be verified. Preserve every successful step
and report the resume point.
