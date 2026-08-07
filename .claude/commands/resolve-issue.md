---
name: resolve-issue
description: Investigate and resolve a flutter_calendar_carousel GitHub issue with reproduction evidence, focused fixes, regression tests, and verified PR delivery when authorized.
---

# /resolve-issue

Argument: issue number or URL.

## Procedure

1. Fetch the issue body, labels, timeline, linked PRs, and relevant closed issues
   or releases. Confirm whether the report is reproducible on current `main` and
   the exact current stable Flutter SDK.
2. Classify it as reproducible, already fixed, duplicate, external configuration,
   Flutter/platform limitation, question, or needs reporter evidence.
3. For a reproducible issue, add a focused failing regression test first when
   practical, implement the smallest compatible fix, and run the relevant
   matrix from `.claude/commands/verify-all.md`.
4. For an already-fixed or non-code issue, collect concrete commit, version,
   workflow, platform, or documentation evidence. Do not manufacture a code
   change merely to close an issue.
5. Commit, push, and create a PR only when authorized. Link the issue in the PR
   body and state whether it should close automatically or remain open for an
   external verification such as pub.dev publishing.
6. Post or close an issue only when external GitHub writes were authorized.

Use English publicly. Preserve public API compatibility and do not conflate a
local workflow fix with confirmation that an external release has published.
