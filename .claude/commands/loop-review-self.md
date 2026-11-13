---
name: loop-review-self
description: Self-review a minor docs, release-note, or housekeeping change until clean and push it directly to main without a PR.
---

# /loop-review-self

Argument: optional description of the already-written change.

The complete algorithm is `.codex/skills/loop-review-self/SKILL.md`. Claude
Code uses `.claude/skills/loop-review-self/SKILL.md`; Codex invokes
`$loop-review-self`. Read the canonical skill completely before acting.

## Phases

1. Confirm `main` is current and every touched path is in the qualifying scope.
2. Run `review-self` until two consecutive clean snapshots.
3. Run `git diff --check`, plus `flutter pub publish --dry-run` when a
   packaged Markdown file changed.
4. Commit only the owned files on `main` and push.
5. Verify `HEAD == origin/main` and report the commit.

## Authority

Invoking this command authorizes one in-scope commit pushed directly to
`main`. It never authorizes product code, `pubspec.yaml` or lockfile edits, a
PR, a release, tags, or force-pushes; those go through `/loop-review`.
