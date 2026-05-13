---
description: Execute the daily maintenance routine for flutter_calendar_carousel
---

# /daily-routine

Run the daily maintenance sweep. This is also what the Cowork scheduled tasks trigger — running it by hand should produce the same output.

## Daily (run every weekday morning)

1. **Repository freshness & tracking**
   - Fetch latest remote state first: `git fetch origin main --tags --prune`.
   - Run the sweep against latest `origin/main`. If the mounted checkout has local changes or is behind, do not overwrite it; use `git worktree add <unique-temp-path> origin/main` to create a clean temporary worktree and report the local dirty/behind state.
   - Remove any temporary worktree created for the sweep before the run exits. If cleanup fails, report the path as a follow-up instead of leaving it implicit.
   - Record commit SHA, Flutter/Dart version, latest tag, commits since tag, and open issue/PR counts.
   - Use GitHub issues for recurring blockers: red main, failed dependency bumps, Flutter stable regressions, and CI/release/publish failures.

2. **Autonomous maintenance task loop**
   - Build a daily work queue from failed sweep steps, actionable issues, PR blockers that can be fixed in the base repo, dependency/Flutter drift, CI/release/publish failures, and automation gaps.
   - Split work into small branches. Use names like `codex/<area>-YYYYMMDD` or `chore/deps-YYYYMMDD`.
   - Implement the smallest safe change, then run the relevant verification. Minimum for product changes: `flutter pub get`, `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test --coverage`, and `flutter pub publish --dry-run`.
   - Commit, push, open a PR, request Copilot, post `/gemini review for $HEAD_SHA`, wait for CodeRabbit when available, and use the same 3-bot gates before merge.
   - If CI/reviews fail, push a follow-up fix or leave the PR open with a precise blocker comment/issue.
   - Never push directly to `main`. Never batch unrelated fixes. Never weaken lint, CI, release, publish, or security gates to make a PR pass.
   - Do not edit contributor PR branches unless the author explicitly requested/allowed maintainer edits; create repo-owned fix PRs instead.

3. **Dependency check**
   - `flutter pub outdated`
   - `flutter pub outdated --json`
   - Note direct/dev packages with newer compatible or resolvable versions.
   - Separately report transitive-only latest versions blocked by Flutter/Dart constraints.
   - If a direct/dev package remains blocked by SDK constraints or a major upgrade for more than one run, create/update `maintenance: dependency upgrade blocked`.
   - Do not blindly upgrade from here. Safe direct/dev updates can be queued into the autonomous task loop; grouped dependency PRs normally happen in the weekly job.

4. **Code quality**
   - `flutter analyze`
   - `dart format --set-exit-if-changed .`
   - `flutter pub publish --dry-run`
   - Analyze and format must pass. If they don't, surface the failure, open/update `daily-routine: analyze/format red on main`, and stop the routine.
   - Report publish dry-run as the package publishability/breaking-risk smoke check.

5. **Tests**
   - `flutter test --coverage`
   - Report pass/fail counts. If any test fails, open (or update) a tracking issue with the failure output.

6. **PR review & auto-merge (3-bot loop)**

   See `.claude/commands/review-pr.md` for the canonical bot-loop spec. This section is the daily entry point for it.

   **When we open a PR from this routine** (deps bump, fix, anything):
   The daily routine may open scoped maintenance PRs before invoking the
   review loop. The standalone `/review-pr` command never opens PRs by itself.

   ```bash
   OWNER_REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
   PR=<number>
   HEAD_SHA=$(gh pr view "$PR" --json headRefOid --jq .headRefOid)
   gh pr edit "$PR" --add-reviewer "copilot-pull-request-reviewer[bot]" \
     || gh api -X POST "repos/$OWNER_REPO/pulls/$PR/requested_reviewers" \
       -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
   gh pr comment "$PR" --body "/gemini review for $HEAD_SHA"
   # CodeRabbit auto-fires on push — no manual action.
   ```

   **Reviewing every open PR**:
   ```bash
   OWNER_REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
   gh pr list --state open --json number,isDraft,author,headRefOid --repo "$OWNER_REPO"
   ```

   For each PR:
   - **`isDraft == true`** → skip.
   - **Author is a bot** (`dependabot[bot]`, `renovate[bot]`, `github-actions[bot]`, or ends `[bot]`) → **bot-bypass**: verify all CI checks green → `gh pr review "$PR" --approve --body "Automated bot PR — auto-merging." || true` → `gh pr merge "$PR" --auto --squash --delete-branch`. If checks are missing, pending, failed, cancelled, or timed out, record `skipped(bot-bypass-failed)` and do not approve. Do not run the 3-bot loop. CI is the gate.
   - **Everything else** → run the full `/review-pr` flow:
    1. Step 0 prep if Copilot isn't a requested reviewer yet (assign + `/gemini review for $HEAD_SHA`).
     2. Step 1 fetch state (PR JSON, diff, checks, reviews, comments).
    3. Step 2 short-circuit gates — if any failed/cancelled check or guarded blocker hits → Step 6 request-changes, stop. If checks are pending or missing, wait and report `waiting-checks`; do not request changes for CI that has not run yet. If the branch is merely `BEHIND`, update it from `main` via `gh pr update-branch "$PR"` when the branch is repo-owned or maintainer edits are enabled; only request changes if that update fails or creates conflicts.
     4. Step 4 bot-loop:
        - All 3 bots (`gemini-code-assist[bot]`, `copilot-pull-request-reviewer[bot]`, `coderabbitai[bot]`) must have `reviewed_current_head == true` against HEAD_SHA, or be marked `unavailable` because the app/reviewer cannot be requested in this repo.
        - If any bot is still catching up and hasn't been kicked against HEAD_SHA → kick once, move on, return `waiting-bots` for this PR this run.
        - If all reviewed & clean → Step 5 approve + auto-merge.
        - If all reviewed & has findings → classify (blocker vs. nit). Blocker → Step 6 request-changes. Non-blocking nits get one acknowledgement comment and do not force another review cycle; proceed when all other gates are green.
     5. Step 7 human threads:
       - Human replied in last 14 days and we haven't responded → reply substantively, return `waiting-human`.
       - Human hasn't replied in ≥ 14 days AND we already replied → add a stale warning label/comment first, then autonomously resolve per Step 7 rules only if the thread remains unanswered.
   - Never merge if any of the 3 bots hasn't reviewed current HEAD (unless that bot is unavailable in the org). Never merge while GitHub reports `DIRTY`, `BLOCKED`, `BEHIND`, or `UNSTABLE`. Never exceed 3 bot-kick iterations per PR per daily run.

7. **Issue triage**
   - `gh issue list --state open --limit 50`
   - `gh pr list --state open --limit 50`
   - Look for:
     - Missing labels (apply `bug`, `enhancement`, `question` as appropriate).
     - Stale-candidate issues with no activity in 90 days (let the `stale.yml` workflow handle closure; don't close manually unless the issue is clearly invalid).
     - Duplicates to mark with `duplicate`.
     - PR blockers worth tracking in the report: merge conflicts, missing CI, stale bot reviews, unresolved human asks, guarded public API changes, dependency/SDK changes, or breaking commits.
   - Do not add noisy duplicate comments when a current-head review already states the blocker.

8. **Cleanup**
   - Delete clean temporary worktrees created by this run with `git worktree remove <path>`.
   - If a temporary worktree contains uncommitted diagnostics or logs that must be preserved, keep it and include the absolute path in the final report.

## Output

Write a short report:
- Dependencies: N outdated (list)
- Repo freshness: origin/main SHA, local checkout clean/dirty/behind, Flutter/Dart version
- Analyze: pass/fail
- Format: pass/fail
- Publish dry-run: pass/fail
- Tests: N passed / M failed (coverage %)
- PRs:
  - `#<N> <author> <merged|requested-changes|waiting-bots|waiting-human|skipped(draft|bot-bypass-failed)> [iter=<K>] [checks=<status>]`
- Issues touched: list PR numbers / issue numbers

Make code changes through scoped branches and PRs when the task is clear and safe. If something is ambiguous, breaking, or blocked by external service configuration, file/update an issue and mention it in the report.

---

## Weekly / monthly

The schedule skill runs these on different cadences — see `.claude/guides/05-deployment.md`. They include:

- **Weekly**: dependency update PR (which goes through the same 3-bot auto-merge loop above), CHANGELOG tidy, breaking/release-readiness review.
- **Monthly**: Flutter stable compatibility check against latest stable, deprecated-API sweep.
