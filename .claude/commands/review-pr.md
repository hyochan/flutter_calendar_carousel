---
name: review-pr
description: Fix pull-request feedback, verify the exact current head, and poll every five minutes until two consecutive clean snapshots. Never merge unless separately requested.
---

# /review-pr

Argument: PR number or URL. If omitted, resolve the PR for the current branch.

The complete algorithm is `.codex/skills/review-pr/SKILL.md`. Claude Code uses
`.claude/skills/review-pr/SKILL.md`; Codex invokes `$review-pr`. Read the
canonical skill completely before acting.

## Project Checks

Select checks from the changed paths. For dependency, Flutter, native example,
release, publish, or broad workflow changes, run the complete matrix in
`.claude/commands/verify-all.md` against the current stable Flutter SDK.

At minimum, behavior changes need format, analysis, root tests, and a focused
regression test. Example dependency or native changes also need example analysis,
tests, Android debug build, and an iOS simulator build when Xcode is available.
Workflow changes need YAML validation and a faithful local simulation of changed
shell logic when possible.

## Round Checklist

1. Resolve repository, PR, actual base, editable head, and exact head SHA.
2. Refresh full diff, checks, reviews, requested reviewers, top-level comments,
   paginated inline comments, and GraphQL review threads.
3. Auto-resolve only threads GitHub marks outdated.
4. Validate every current finding. Fix valid findings now; add regression tests
   where appropriate. Reply with evidence when a finding is invalid or already
   fixed.
5. Verify, commit, and push the coherent fix batch when authorized.
6. Reply through the inline comment reply API with the plain commit hash, then
   resolve the addressed thread.
7. Re-request configured reviewers only when the head changed. If automation is
   terminally unavailable, use one exact-head `$review-self` fallback pass.
8. Poll again after 300 seconds through a real product wake-up. Finish only after
   two clean snapshots separated by five minutes.

Pending checks or active reviewers are wait states. A clean snapshot requires
all required checks terminal and successful or explicitly allowed to skip, no
actionable thread, no pending configured reviewer, clean fallback coverage for
unavailable reviewers, and a reread of the exact current-head diff.

## Public Reply Rules

- Use English.
- Reply to the exact inline comment, not a new general PR comment.
- Write commit hashes as plain text so GitHub links them.
- Never promise to fix a valid finding later.
- Never dismiss feedback or weaken a gate to obtain green status.
- Never merge from this command without separate explicit merge authority.

## Result

Report the PR URL, exact head SHA, checks, findings fixed or rebutted, threads
resolved, reviewer availability/fallback, poll count, and clean count.
