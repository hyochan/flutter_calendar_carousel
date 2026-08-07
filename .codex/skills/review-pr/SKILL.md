---
name: review-pr
description: Inspect and finish flutter_calendar_carousel pull requests by fixing valid review findings, replying and resolving threads, diagnosing CI, using review-self when automation is unavailable, and polling at five-minute intervals until the exact head is clean. Use for PR review, review feedback, CI failures, reviewer monitoring, or requests to keep reviewing until no actionable feedback remains.
---

# Review Pull Request

Own one PR review loop. Fix valid findings now, verify the resulting head, and
stop at a clean PR unless the user separately authorized merging.

## Authority And Target

- Read `AGENTS.md` and `.claude/commands/review-pr.md` completely.
- Resolve a supplied number or URL. Otherwise use the PR for the current branch.
- Confirm repository, base branch, head branch, exact head SHA, author, draft
  state, and whether the branch can be edited safely.
- Existing authorization to commit, push, create a PR, or reply to reviews is
  preserved. Review authorization alone never grants merge or release authority.
- Record the initial working tree and preserve unrelated changes.

## Fetch The Complete Current State

For every round, refresh:

- PR metadata, full base-to-head diff, commits, and merge state;
- check runs and status rollup for the exact head SHA;
- submitted reviews, requested reviewers, and top-level comments;
- paginated inline review comments;
- GraphQL review threads with resolution and outdated state.

Do not infer clean state from `reviewDecision` alone. Do not reuse review or CI
evidence from an older head.

Auto-resolve only unresolved threads GitHub marks outdated. Do not resolve a
current thread merely because the author already replied.

## Classify And Act

For each unresolved current finding:

1. Read the cited code and surrounding tests or workflow.
2. Classify it as valid, invalid, already fixed, obsolete, or requiring a user
   decision.
3. Fix every valid in-scope correctness, compatibility, CI, documentation, or
   regression gap in the current PR. Do not defer a real finding as follow-up.
4. Add or strengthen a focused regression test when behavior changed.
5. Run the verification required by the changed paths.

After one coherent fix batch:

1. Commit and push when already authorized.
2. Reply directly to each inline comment using its reply endpoint. Mention the
   plain commit hash without backticks and summarize the fix or evidence.
3. Resolve the thread after the pushed fix or evidence-backed reply fully
   addresses it.
4. Re-request only reviewers that are configured for this repository and need a
   new pass on the new head. Do not fabricate a three-bot requirement.

All public replies must be concise English. Never hide a failed check, dismiss a
review, or weaken a gate.

## Verification Matrix

Use touched-path checks while iterating. For dependency, Flutter SDK, native
example, release, publish, or broad workflow changes, run:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
(cd example && flutter pub get && flutter analyze && flutter test)
(cd example && flutter build apk --debug)
flutter pub publish --dry-run
git diff --check
```

Build the iOS example for a simulator when iOS files changed and Xcode is
available. Validate changed workflow YAML. Prefer current stable Flutter for
compatibility claims.

## Reviewer Fallback

External review automation is optional coverage, not a completion dependency.
A reviewer is unavailable for the current head when it returns a terminal
quota, billing, permission, size, or service failure, or when two polling rounds
after a request show neither a review nor a requested/in-progress state.

When any configured reviewer is unavailable, run exactly one complete
`$review-self` round against the actual base and head. Pass the requirements,
changed paths, checks, and current commit/push authority. The fallback must not
request reviewers or start its own polling loop. Cache clean fallback coverage
by reviewer failure set and head SHA; invalidate it after any head change.

## Five-Minute Polling Contract

- Run the first review round immediately.
- Use the product's recurring monitor or wake-up mechanism to re-enter
  `$review-pr` 300 seconds after each non-terminal round. Never emulate this
  with `sleep`, a shell loop, `nohup`, or an abandoned process.
- Carry the PR number, base, exact head SHA, seen thread/check/review IDs, poll
  count, clean count, fallback coverage, start time, and fix-attempt fingerprints.
- Pending CI or active reviewers are neither clean nor failed. Poll without
  rerunning expensive unchanged local checks.
- A snapshot is clean only when the exact head has terminal successful or
  allowed-skipped checks, no actionable unresolved feedback, no pending
  configured reviewers, clean fallback coverage for unavailable reviewers, and
  the final diff has been reread.
- Finish after two consecutive clean snapshots separated by at least five
  minutes. Reset the clean count on any head or material-state change.
- If no real recurring mechanism exists, complete the current round and report
  that automatic re-entry could not be scheduled. Do not claim it was scheduled.

## Stop Conditions

Stop and report exact evidence when two clean snapshots establish stability; the
user redirects the task; the PR closes or changes incompatibly; a fix needs new
authority or a product decision; the same finding survives two fix attempts; the
same external/tool failure blocks three rounds; or only unchanged pending state
remains after twelve polls. Never label a blocked or interrupted PR clean.

Do not merge the PR unless the user explicitly asks for merge after these gates.
