---
name: loop-review-self
description: Land a minor flutter_calendar_carousel docs, release-note, or housekeeping change on main with no pull request after two clean review-self snapshots and the checks its paths require.
---

# Loop Review Self (Claude Code)

Read and follow `.codex/skills/loop-review-self/SKILL.md` completely. Its
qualifying scope, authority, review-until-clean phase, verification, direct
push, and stop rules are canonical for Claude Code too.

Use `.claude/commands/loop-review-self.md` as the command entry point.

- `review-self` runs the review phase and owns the interval loop; do not start
  a second one.
- `.claude/commands/commit.md` covers staging and the commit message, but this
  skill commits on `main` with no branch and no PR.
- Use Claude's real scheduled wake-up mechanism for every five-minute
  re-entry; never use `sleep`, a shell loop, `nohup`, or an abandoned process.
- Anything outside the qualifying scope goes to `loop-review`.
