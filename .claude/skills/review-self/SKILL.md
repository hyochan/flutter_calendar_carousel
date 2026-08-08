---
name: review-self
description: Independently review and improve current flutter_calendar_carousel work, fix actionable gaps, rerun verification, and recheck every five minutes until stable.
---

# Review Self (Claude Code)

Read and follow `.codex/skills/review-self/SKILL.md` completely. Use Claude's
real scheduled wake-up mechanism for five-minute confirmations. If none exists,
finish the immediate round and report the limitation; never emulate recurrence
with a shell process.

When invoked as the `review-pr` fallback, run exactly one complete round and do
not request reviewers, handle review threads, or schedule another poll.
