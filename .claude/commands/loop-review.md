---
name: loop-review
description: Take one change from latest main through review, merge, release.yml, and a verified pub.dev version.
---

# /loop-review

Argument: optional task description, issue, or existing PR number. With a PR
number, resume the loop at that PR.

The complete algorithm is `.codex/skills/loop-review/SKILL.md`. Claude Code uses
`.claude/skills/loop-review/SKILL.md`; Codex invokes `$loop-review`. Read the
canonical skill completely before acting.

## Phases

1. Start from fresh `origin/main` or resume the in-progress branch safely.
2. Implement with regression tests, docs, and `[Unreleased]` notes; run
   `.claude/commands/verify-all.md` checks for the touched paths.
3. Stabilize with `review-self`.
4. Commit, push, and open one labeled PR with `.claude/commands/commit.md`.
5. Run `.claude/commands/review-pr.md` until two clean exact-head snapshots.
6. Squash-merge the clean head, delete the branch, and fast-forward `main`.
7. Dispatch `release.yml` on `main` with the bump the notes require, then
   verify the tag, GitHub Release, `publish.yml`, and pub.dev.

## Authority

Invoking this command authorizes the in-scope commit, push, one PR, review
replies, merge, and one stable release. It never authorizes prereleases,
force-pushes, tag rewrites, or direct product-code commits to `main`.
