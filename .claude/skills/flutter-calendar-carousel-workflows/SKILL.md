---
name: flutter-calendar-carousel-workflows
description: Use for flutter_calendar_carousel repository work that should follow its shared workflows for issue resolution, dependency and Flutter upgrades, verification, commits, pull requests, releases, and PR monitoring.
---

# Flutter Calendar Carousel Workflows (Claude Code)

The canonical repository rules live in `AGENTS.md`; the canonical workflow
router lives in `.codex/skills/flutter-calendar-carousel-workflows/SKILL.md`.
Read and follow both completely.

When the router selects a `.claude/commands/*.md` file, read that command before
acting. Where a canonical skill requires a product wake-up or recurring monitor,
use Claude's real scheduled wake-up mechanism. Never substitute `sleep`, a shell
loop, `nohup`, or an abandoned background process.
