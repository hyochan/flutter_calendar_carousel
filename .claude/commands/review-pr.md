---
name: review-pr
description: Review a GitHub PR under the 3-bot loop (Gemini + Copilot + CodeRabbit). Assign bots on open, watch their reviews, re-kick until quiet, then auto-merge. Human threads get 7-day patience before autonomous resolution. No human approval on clean PRs.
---

# /review-pr

End state for every PR this skill touches:

1. Copilot is a requested reviewer, or the request failed because that bot is
   unavailable in this repository and the failure is logged.
2. Gemini has posted at least one review against the current HEAD (triggered via `/gemini review` comment).
3. CodeRabbit has posted a summary against the current HEAD (auto-triggered by its GitHub App on push), or CodeRabbit is unavailable in this repository and logged.
4. No bot has actionable feedback outstanding against the current HEAD.
5. No human thread is unanswered AND either the human has replied, or the thread is ≥ 7 days old and we have resolved autonomously.
6. All reported status checks are green. Missing or pending checks are a wait
   state, not a change request.

Only when all six are true do we approve + auto-merge.

Argument: PR number or URL (positional `$1`).

## Step 0 — Prep the PR (first time we see it)

If Copilot is NOT yet a requested reviewer AND the PR is not authored by a bot:

```bash
OWNER_REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
PR="$1"

gh pr edit "$PR" --add-reviewer "copilot-pull-request-reviewer[bot]" 2>/dev/null \
  || gh api -X POST "repos/$OWNER_REPO/pulls/$PR/requested_reviewers" \
    -f 'reviewers[]=copilot-pull-request-reviewer[bot]'

gh pr comment "$PR" --body "/gemini review"

# CodeRabbit: no manual action — configured via .coderabbit.yaml.
```

If a bot request fails because the app/reviewer is unavailable in this repo
(404/403/422 from the reviewer request path), log `unavailable` for that bot
and skip waiting on it; do not block the PR on that bot.

## Step 1 — Fetch state

```bash
gh pr view "$PR" --json number,title,body,author,baseRefName,headRefName,isDraft,labels,mergeStateStatus,statusCheckRollup,reviewDecision,reviews,reviewRequests,comments,commits,headRefOid,updatedAt
gh pr diff "$PR"
gh pr checks "$PR" --watch=false
```

Extract: `HEAD_SHA`, checks map, all reviews (login/state/submitted_at/commit_id), and top-level comments from the `gh pr view` payload. Use direct REST calls only as a pagination fallback or when the `gh pr view` payload is missing required review/comment fields.
Keep `OWNER_REPO`, `PR`, and `HEAD_SHA` in scope for the later bot kick and merge commands; recompute them before Step 4 if the workflow is split across shell invocations.

## Step 2 — Short-circuit gates (block merge immediately)

If any is true, jump to Step 6 — Request changes:

- `isDraft == true`
- Any completed check conclusion ∉ {SUCCESS, SKIPPED, NEUTRAL}
- `baseRefName != main`
- Any commit subject contains `!:` OR body contains `BREAKING CHANGE:`
- **Project-specific guarded paths (flutter_calendar_carousel):**
  - `lib/flutter_calendar_carousel.dart` — any rename/removal of an exported class, typedef, or public field on `CalendarCarousel<T>` → human review (public API surface)
  - `lib/classes/**` — any removal or rename in `EventInterface`, `Event`, `EventList`, `MarkedDate`, `MultipleMarkedDates` (public data types) → human review
  - `lib/src/default_styles.dart` — any change to default `TextStyle` / `Color` values (globally visible to every downstream user) → human review
  - `pubspec.yaml` — any new non-dev dependency that isn't from a pub.dev verified publisher → human review; any change to `environment: sdk:` constraint → human review; any manual `version:` bump (release workflow owns this) → human review; any addition or modification of `dependency_overrides` → human review
  - `analysis_options.yaml` — disabling lint rules or removing `flutter_lints` → human review
  - `.github/workflows/release.yml`, `.github/workflows/publish.yml`, `.github/workflows/auto-release.yml` — any edit → human review (tag-format, OIDC, and release logic are load-bearing)
  - `.github/workflows/security-*.yml` — removed/weakened
- Title or any commit contains `revert`
- Test files under `test/` deleted without same-PR replacement
- `mergeStateStatus` ∈ {DIRTY, BLOCKED}
- `mergeStateStatus == BEHIND` after one attempted update from `main` when the branch is repo-owned or maintainer edits are enabled.

If checks are absent, queued, pending, or in progress, return `waiting-checks`
for this run. Do not request changes for checks that have not completed.

## Step 3 — Bot bypass (PRs authored by bots)

If `author.login` matches `dependabot[bot]`, `renovate[bot]`, `github-actions[bot]`, or ends in `[bot]`:

- Verify all checks green.
- `gh pr review "$PR" --approve --body "Automated bot PR — auto-merging." || true`
- `gh pr merge "$PR" --auto --squash --delete-branch`
- Skip the 3-bot loop — CI is the gate for bot PRs.

## Step 4 — Bot review loop (core contract)

Bot logins:

| Bot | Login | Re-kick |
|---|---|---|
| Gemini | `gemini-code-assist[bot]` | `gh pr comment "$PR" --body "/gemini review"` |
| Copilot | review author `copilot-pull-request-reviewer[bot]`; reviewer login `copilot-pull-request-reviewer[bot]` | `gh api -X POST "repos/$OWNER_REPO/pulls/$PR/requested_reviewers" -f 'reviewers[]=copilot-pull-request-reviewer[bot]'` |
| CodeRabbit | `coderabbitai[bot]` | nothing — re-runs on push |

### 4a. Classify each bot against current HEAD

For each bot:

- `reviewed_current_head`: true when the latest bot review has `commit_id == HEAD_SHA`. For bots that only leave top-level comments without commit IDs, count the comment only if it appears after the most recent explicit kick for `HEAD_SHA`, even when that kick happened in a previous run; do not use broad timestamp comparisons as a substitute for commit identity.
- `has_findings`: true if the latest content contains `state == "CHANGES_REQUESTED"`, inline severity markers (🛑 / ⚠️ / `Critical` / `Major` / `Nit:` / "Suggested change"), or reviewer-authored TODO/FIXME text. Ignore TODO/FIXME when it appears only inside quoted code, diffs, or documentation examples.
- `unavailable`: true if the bot's app or reviewer cannot be requested in this repo (kick returned 404/403/422).

### 4b. Decision

- All three `reviewed_current_head == true` AND no `has_findings` → **exit loop, go to Step 5**.
- All three `reviewed_current_head == true` AND ≥1 has findings:
  - Summarize per-bot findings in a single top-level comment `## Bot review pass N\n...`.
  - Per finding:
    - **Blocker** (security, correctness, API break) → add to Step 6 list, stop loop.
    - **Non-blocker** (style, nit) → acknowledge in top-level comment; continue.
  - If any blocker existed → Step 6 and stop.
  - If no blockers → acknowledge the nits once in the pass summary and proceed when all other gates are green. Do not keep re-kicking bots for non-blocking nits.
- Any bot `reviewed_current_head == false` AND NOT `unavailable` → **wait**:
  - If this bot hasn't been kicked against HEAD_SHA yet, kick once.
  - Otherwise do nothing; return `waiting-bots`.
- `unavailable` bots: ignore, don't block merge.

### 4c. Never

- Never write code changes from this skill. Fixes are for the PR author.
- Never approve before §4b's exit condition.
- Never force-push/amend/rebase.
- Never kick a bot more than once per iteration.

## Step 5 — Approve + auto-merge

All preconditions must hold (§2 clean, §4 exit, no open human thread, all checks green, `mergeStateStatus` ∈ {CLEAN, HAS_HOOKS}):

```bash
gh pr review "$PR" --approve --body "All automated reviewers quiet; merging."
gh pr merge "$PR" --auto --squash --delete-branch
```

Return `MERGED <sha>`.

## Step 6 — Request changes

```bash
gh pr review "$PR" --request-changes --body "$(cat <<'EOF'
Auto-review found blockers. Push a fix; next daily run will re-evaluate.

<bullet list: file:line — issue — suggested fix>
EOF
)"
```

Put every requested change in the review body as concrete file/line guidance. Do not apply the author's code changes from this command, do not use inline comments, and do not merge.

## Step 7 — Human conversations

Scan for unresolved human threads (non-bot authors):

- **< 7 days since human's latest message**: reply substantively, wait. Return `waiting-human`.
- **≥ 7 days AND we already replied AND human hasn't responded**: autonomous resolution:
  - Clear code change ask → request changes with the required edits in the review body + log "Auto-resolving after 7d no-reply".
  - Question we already answered → "Auto-closing thread after 7d no-reply; our prior answer stands." Proceed to Step 5.
  - Ambiguous → prefer request-changes over merge. Log the decision.

## Step 8 — Return format

```
PR #<N> <author> <result> [iter=<K>] [waiting=<bots|human>] [checks=<status>]
```

Result ∈ merged | requested-changes | waiting-bots | waiting-checks | waiting-human | skipped(draft|bot-bypass-failed).

## Hard rules

1. Never merge until all 3 bots reviewed current HEAD (or marked unavailable).
2. Never silence a bot by dismissing its review.
3. Never exceed 3 kicks per bot per daily run.
4. Never treat a human's question as answered by our previous reply unless > 7 days elapsed.
5. Never skip §2 gates because bots approved.
6. Never open a PR from this skill. The daily routine may open a PR before invoking this review loop; `/review-pr` itself only reviews an existing PR.
7. Never re-request review from a bot that already reviewed clean — that's the exit condition.

## Tuning knobs

`REVIEW_LOOP_MAX_ITERS=3`, `REVIEW_HUMAN_AUTONOMY_DAYS=7`, `REVIEWER_{COPILOT,GEMINI,CODERABBIT}_LOGIN`, `REVIEW_POLL_SLEEP_SEC=30`.
