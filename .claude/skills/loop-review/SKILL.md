---
name: loop-review
description: Run the complete flutter_calendar_carousel loop from latest main through review-self, one PR, five-minute PR review until clean, merge, release.yml, and pub.dev verification.
---

# Loop Review (Claude Code)

Read and follow `.codex/skills/loop-review/SKILL.md` completely. Its authority,
clean gate, merge, release, and stop rules are canonical for Claude Code too.

Use `.claude/commands/loop-review.md` as the command entry point. Delegate each
phase to the matching local skill or command:

- `review-self` for pre-PR stabilization and unavailable-reviewer fallback.
- `.claude/commands/commit.md` for commit, push, PR, and labels.
- `review-pr` for review threads, CI, and the two-clean-snapshot gate.
- `.claude/guides/05-deployment.md` for `release.yml` and `publish.yml`.

Use Claude's real scheduled wake-up mechanism for every five-minute re-entry;
never use `sleep`, a shell loop, `nohup`, or an abandoned process.
