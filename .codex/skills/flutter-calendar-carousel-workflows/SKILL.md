---
name: flutter-calendar-carousel-workflows
description: Use for flutter_calendar_carousel repository work that should follow its shared workflows for issue resolution, dependency and Flutter upgrades, full verification, commits, pushes, pull requests, releases, PR feedback, five-minute review monitoring, and project conventions from AGENTS.md.
---

# Flutter Calendar Carousel Workflows

Route natural-language requests through the repository's canonical rules and
command entry points.

## Source Of Truth

1. Read `AGENTS.md` before changing the repository.
2. Read only the matching `.claude/commands/*.md` workflow below.
3. Apply this skill's cross-workflow safeguards when command prose is concise.
4. For `review-pr`, `review-self`, or `rebase-main`, use the matching specialized
   `.codex/skills/<name>/SKILL.md` as the canonical procedure.

## Command Mapping

- PR review, feedback, checks, or monitoring → `.claude/commands/review-pr.md`
  and `$review-pr`
- Self-review or final implementation audit → `$review-self`
- Issue investigation and resolution → `.claude/commands/resolve-issue.md`
- Full repository verification → `.claude/commands/verify-all.md`
- Branch, commit, push, or PR creation → `.claude/commands/commit.md`
- Daily repository maintenance → `.claude/commands/daily-routine.md`
- Updating a branch from `main` → `$rebase-main`
- Release or publishing work → `.claude/guides/05-deployment.md`

Read the selected file completely before acting. Do not load every workflow by
default.

## Shared Safeguards

- Preserve the authority of the user's request. Inspection does not authorize a
  commit; commit does not authorize a push; push does not authorize a PR; a PR
  does not authorize merge or release.
- Public GitHub communication and commit messages must be in English.
- Record initial Git state and preserve unrelated staged, unstaged, untracked,
  and ignored files.
- Prefer issue reproduction and regression tests over speculative fixes.
- Use the exact latest stable Flutter SDK for current-compatibility claims.
- Run direct and consumer checks after dependency or native-toolchain changes.
- Do not edit another contributor's branch without explicit permission.
- Do not treat unavailable external review automation as success; cover it with
  one `$review-self` pass for the exact current head.
- Do not merge, tag, publish, or deploy unless explicitly requested.

## GitHub Review Threads

Fetch PR metadata, checks, reviews, inline comments, top-level comments, and
GraphQL review threads. Classify each finding against the current diff. Fix
valid findings in a coherent batch, reply to the exact inline comment with a
plain commit hash, and resolve only after the response is complete. Use
evidence-backed replies for invalid or already-fixed findings.

## Completion

Report the resulting branch/PR, checks run, issue or review disposition, and any
external blocker. Do not call work regression-free unless the required matrix
passed on the relevant Flutter SDK and PR head.
