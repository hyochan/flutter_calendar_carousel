---
name: commit
description: Create a branch, stage owned changes, make a Conventional Commit, push, and optionally open a pull request without implying merge authority.
---

# /commit

Options may include `--push`, `--pr`, `--all`, or explicit paths. Preserve the
user's authorization exactly; `--pr` includes push, but none of these include
merge, tag, publish, or release authority.

## Procedure

1. Read `AGENTS.md`; confirm current branch, upstream, worktrees, and full status.
2. If on `main`, create a scoped `codex/<topic>` branch unless the user supplied
   another valid branch name.
3. Run the relevant checks before staging.
4. Stage only owned paths. Use `--all` only when every visible change belongs to
   the requested task.
5. Inspect `git diff --cached --stat`, `--name-only`, and the complete staged
   diff. Check for secrets, generated artifacts, accidental lockfiles, and
   unrelated edits.
6. Commit in English with a Conventional Commit subject and a concise body when
   the reason is not obvious.
7. Push with upstream tracking only when authorized.
8. Create a ready PR against `main` only when authorized. The English PR body
   must summarize behavior/workflow changes, issue disposition, dependency and
   Flutter compatibility, exact verification, and known external blockers.

After pushing, compare local HEAD to the remote PR head. Never force-push unless
explicitly authorized and protected with `--force-with-lease`. Never merge from
this command.
