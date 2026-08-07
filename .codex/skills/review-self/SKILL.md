---
name: review-self
description: Independently review and improve the current flutter_calendar_carousel implementation, working-tree changes, commit range, or pull request; fix actionable in-scope gaps; rerun relevant verification; and recheck at five-minute intervals until stable. Use for self-review, final verification, implementation audits, or fallback coverage when an external PR reviewer is unavailable.
---

# Review Self

Review the current work independently, fix validated gaps, and confirm stability.

## Preserve Scope And Authority

- Read `AGENTS.md` and reconstruct the requested outcome and acceptance criteria.
- Review a supplied PR, range, or path; otherwise use the current branch plus all
  staged, unstaged, and untracked changes against its actual merge base.
- Record initial Git state and preserve unrelated work.
- Do not commit, push, create or edit a PR, post comments, merge, or release
  unless the original request already authorized that action.
- Stop for a material product choice, irreversible action, or scope expansion.

## One Complete Round

1. Resnapshot the full target from disk. Do not review only the latest commit.
2. Read requirements, surrounding implementation, tests, docs, relevant issues,
   and current CI/review evidence.
3. Review for requirement completeness, API compatibility, date/time edge cases,
   rendering and gesture behavior, state transitions, error paths, platform and
   Flutter compatibility, dependency safety, tests, documentation, examples,
   release correctness, and security.
4. Validate every finding against current code. Reject taste-only churn,
   duplicates, and unrelated improvements.
5. Fix all validated in-scope findings in one coherent batch. Regenerate native
   or lock files through their owning tools.
6. Reread the final diff and run the checks required by `AGENTS.md` and changed
   paths. Do not repeat an expensive check when its inputs are unchanged.
7. Commit and push only when authorized, staging only the current batch.

Use `$flutter-calendar-carousel-workflows` to load only the needed detailed
command. For a risky cross-cutting change use `.claude/commands/verify-all.md`.
For GitHub issue work use `.claude/commands/resolve-issue.md`.

## PR Fallback Mode

When `$review-pr` invokes this skill because an external reviewer is unavailable:

- Run exactly one complete round against the supplied base, head SHA,
  requirements, and changed paths.
- Preserve the caller's commit, push, and reply authority.
- Do not re-enter `$review-pr`, request reviewers, handle trigger comments, or
  schedule another poll.
- Return head and working-tree fingerprints, findings and fixes, checks run, and
  a clean or blocked result. Coverage is valid only for that exact head.

## Five-Minute Confirmation

- Run immediately, then use a real product recurring monitor or wake-up to
  re-enter `$review-self` after 300 seconds.
- Do not use `sleep`, a shell loop, `nohup`, or a background process.
- Carry goal, target/base, head/tree fingerprints, working-tree fingerprint,
  feedback and check IDs, findings/fix attempts, poll count, clean count, and
  existing authority outside tracked repository files.
- A round is clean only when no actionable finding remains, required checks pass,
  required PR state is terminal and successful, and the resulting diff has been
  reread.
- Finish after two consecutive clean snapshots separated by five minutes. Reset
  on any material change. If explicitly asked for one pass or invoked in PR
  fallback mode, do not schedule the confirmation.
- If no recurring mechanism is available, report that limitation after the
  immediate round instead of pretending a future check was scheduled.

Stop on success, user redirection, incompatible target change, missing authority,
the same finding after two fix attempts, the same blocking tool failure for three
rounds, or twelve unchanged pending polls. Report exact evidence and never call a
blocked result clean.
