---
name: loop-review-self
description: "Land a minor documentation, release-note, or repository-housekeeping change on flutter_calendar_carousel's main without a pull request: review it with review-self until two consecutive snapshots are clean, run the checks its paths require, then commit and push directly to main and verify the result."
---

# Loop Review Self

Take a small change that is already written and land it on `main` by itself.
This skill owns exactly two phases: self-review until stable, then a direct
push. It opens no pull request, requests no external reviewer, and releases
no package.

Use `$loop-review` instead whenever the change needs a PR or a release.

## Qualifying Scope

The change qualifies only when every touched path is one of:

- documentation: `README.md`, `example/README.md`, and other Markdown files
  that ship no Dart code;
- release notes: entries under the `## [Unreleased]` section of
  `CHANGELOG.md` only;
- agent guidance and workflows: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
  `.codex/skills/`, `.claude/skills/`, `.claude/commands/`, `.claude/guides/`;
- repository housekeeping that changes no build, analysis, or published
  behavior: `.gitignore` and editor configuration.

Stop and hand the change to `$loop-review` when it touches anything else,
including: `lib/`, `test/`, any code or native project file under `example/`,
`pubspec.yaml` (including its `version:` field), any lockfile,
`analysis_options.yaml`, `.github/workflows/`, or a released `CHANGELOG.md`
section. Never promote `[Unreleased]` to a version heading here; `release.yml`
owns version bumps and release metadata. Size is not the test; the paths are.
If the scope is ambiguous, ask rather than assume.

## Authority

An explicit `$loop-review-self` invocation authorizes, for the qualifying
scope only: in-scope fixes, the checks the touched paths require, and one
commit pushed directly to `main`. It is the explicit authorization AGENTS.md
requires for that direct commit. It does not authorize a pull request, a
release, a tag, a force-push, a branch rewrite, or any edit outside the change
the user described. Product code never lands this way.

## 1. Establish The Target

1. Read `AGENTS.md` and every workflow file that applies to the changed paths.
2. Snapshot `git status --short --branch`. Preserve every pre-existing change
   that the task does not own, and never stash in this shared checkout.
3. Confirm the working tree is on `main` and that `main` is not behind
   `origin/main`. Fetch and run `git pull --ff-only --no-tags origin main`
   when it is.
4. Run the qualifying-scope check above over `git status --short` and the diff
   of `CHANGELOG.md`. Stop here if anything falls outside it.

## 2. Review Until Clean

Run `$review-self` against the full working-tree diff and follow it as
written: fix every validated in-scope finding, rerun the verification the fix
affects, and recheck at the user's interval, or five minutes by default, until
two consecutive complete snapshots are clean. Any edit resets the count.

Keep loop state out of tracked files, and never emulate the interval with a
shell sleep loop.

## 3. Verify

Before committing, run the checks the touched paths require and record their
output. Every change runs:

```bash
git diff --check
```

When the change touches a file that ships in the package archive
(`README.md`, `CHANGELOG.md`, or `example/README.md`), also run on the latest
stable Flutter SDK:

```bash
flutter pub get
flutter pub publish --dry-run
```

When a workflow file changes, confirm its Claude adapter, command entry
point, and router mapping still agree, as AGENTS.md "Workflow
Synchronization" requires. Leave unrelated pre-existing failures alone and say
so. A failing check on an owned file blocks the push; fix it and return to
review.

## 4. Push To Main

Stage only the files this task owns, inspect the staged diff, write one
English Conventional Commit message (for example `docs(readme): ...` or
`docs(agents): ...`), and push to `main`. One verified batch, not one commit
per finding. Never force-push.

## 5. Confirm

1. Verify `HEAD` equals `origin/main` and the files this task owns are clean.
2. When the push triggers a workflow on `main`, watch it to completion.
   Documentation-only paths normally trigger none.
3. Report the commit SHA, the files changed, the checks run with their
   results, and the clean-count evidence.

## Stop Conditions

Stop without pushing, and report the concrete blocker, when the scope leaves
the qualifying list, a finding needs a decision or authority that is not
available, the same root finding survives two fix attempts, a required check
keeps failing, branch protection rejects the direct push, or `main` cannot be
fast-forwarded safely. A blocked result is never reported as clean.
