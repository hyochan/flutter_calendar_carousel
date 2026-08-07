---
name: rebase-main
description: Safely update local main from origin/main, rebase the current flutter_calendar_carousel work branch, resolve conflicts without losing staged, unstaged, untracked, ignored, or generated work, and restore the original working-tree state. Use when asked to pull main, rebase onto main, update a branch, or fix a stuck rebase.
---

# Rebase Main

Update `main`, rebase the current work branch, and preserve all local work. Do
not commit or push unless separately authorized.

## Establish And Safeguard

1. Read `AGENTS.md`.
2. Record branch, HEAD, upstream, worktrees, in-progress Git operations, staged,
   unstaged, untracked, and relevant ignored files with content fingerprints.
3. Stop if detached, currently on `main`, another operation is active, or `main`
   is checked out elsewhere and cannot be updated safely.
4. Default to `origin/main`; derive another target only from repository evidence.
5. If dirty, create one named stash with `--include-untracked`, never `--all`.
   Confirm the tracked and untracked worktree is clean. Preserve ignored secrets
   and environment files in place.

The stash is a recovery point. Do not drop it until restoration is exact.

## Update And Rebase

1. Fetch `origin main`.
2. Before switching, verify no recorded ignored/local path collides with a path
   tracked by the destination. Use `git checkout --no-overwrite-ignore` for
   guarded transitions.
3. Check out `main` and run `git merge --ff-only origin/main`. Stop on divergence;
   never reset or create a merge commit to conceal it.
4. Confirm local `main` and `origin/main` are identical.
5. Check out the recorded work branch with the same collision guard.
6. Run `git rebase origin/main`.
7. Resolve each conflict by inspecting base, new-main, and work-branch intent.
   Preserve compatible changes and regenerate derived files through their tools.
   Never apply blanket ours/theirs resolution.

Never use `git reset --hard`, `git checkout --`, `git clean`, or destructive
recovery shortcuts.

## Restore And Verify

1. Apply the named stash with its index.
2. Resolve restoration conflicts carefully. Keep the stash while any mismatch
   remains.
3. Compare staged, unstaged, untracked, and ignored fingerprints to the initial
   snapshot.
4. Drop only the named stash after exact restoration.
5. Run `git status`, `git diff --check`, and affected lightweight checks.
6. Report old/new main and branch heads plus restored working-tree state.

If the work branch was published, explain that rewritten history needs a later
`git push --force-with-lease`; do not perform it without explicit authorization.
