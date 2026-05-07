# Review Someone Else's PR

Reference doc for the **review** flow of the `github-cli` skill. Read
this only after the SKILL.md has determined the user wants to review a
pull request someone else opened.

## Why this skill exists

A code review is a public, time-bounded artifact: the author is waiting,
other reviewers will read what you write, and the comments live in the PR
forever. A good review answers two questions in priority order — *is this
safe to merge?* and *can it be improved?* — and tells the author exactly
where to look for each finding. A bad review is vague, speculative, or
buried in noise.

This skill produces a structured review with severity buckets and
file:line references that the author can act on without guessing.

## The workflow

Run the steps in order.

### Step 1: Resolve the target PR

If the user gave a PR number, use it. Otherwise resolve the PR for the
current branch.

```bash
# explicit number
gh pr view <num> --json number,title,body,author,state,baseRefName,headRefName,url

# current branch
gh pr view --json number,title,body,author,state,baseRefName,headRefName,url
```

If the current branch has no open PR, stop and tell the user — there's
nothing to review. If the user is reviewing across repos, surface
`--repo <owner/repo>` and require it explicitly.

If the PR's `author.login` matches the current `gh api user --jq .login`,
this is the user's own PR. Surface that and ask: *"This looks
self-authored — do you want a self-checklist instead of a posted review?"*
Self-reviews via `gh pr review` are usually unwanted.

### Step 2: Fetch the diff and surrounding context

A good review reads the change in context, not just the diff in
isolation:

```bash
gh pr diff <num>
gh pr view <num> --json files,additions,deletions,commits
```

Also pull the title, body, and any `Closes #N` references. If the PR
links an issue, read it (`gh issue view <n>`) — the issue is the
*intent*, the diff is the *implementation*, and the review compares
the two.

### Step 3: Check CI status before reading code

```bash
gh pr checks <num>
```

If checks are red, surface that to the user up front and ask whether to:
- Pause the review until CI is green (typical), or
- Continue and flag the failures in the review (if the user explicitly
  wants design feedback regardless of CI state).

Reviewing red code wastes everyone's time when the author is going to
push fixes anyway.

### Step 4: Audit the diff against the standard categories

Walk the diff with these in mind. Skip categories that don't apply (a
docs-only PR doesn't need a security audit) — empty findings are noise.

- **Code quality** — readability, naming, complexity, dead code, copy-
  paste, layering violations against the project's existing patterns.
- **Security** — exposed secrets, SQL/command injection, XSS, unsafe
  deserialization, missing authz checks, overly permissive defaults.
- **Performance** — N+1 queries, unbounded loops, redundant work in
  hot paths, blocking I/O on hot paths, allocations in tight loops.
- **Testing** — coverage of new logic, edge cases (empty, null, max,
  off-by-one), regression tests for the bug being fixed.
- **Documentation** — public API doc updates, README/CHANGELOG entries
  if they are part of the project's convention, comment accuracy.
- **Breaking changes** — API surface, on-disk format, env var renames,
  config flag changes; presence of a migration path.
- **Dependencies** — new packages and their license / maintenance /
  size / supply-chain reputation.

### Step 5: Sort findings into severity buckets

Use the project's existing rubric (preserved from the longstanding
`/pr_review` command):

- **Critical** *(must fix before merge)* — security vulnerabilities,
  data-loss risks, breaking changes without a migration path, exposed
  credentials.
- **High** — poor error handling, performance regressions, missing
  tests for critical functionality, significant code-quality issues.
- **Medium** — style inconsistencies, missing docs, suboptimal
  implementations, minor perf wins.
- **Low** — minor refactor suggestions, nice-to-have test coverage,
  style preferences, doc enhancements.

Each finding must include a concrete file:line reference and a concrete
suggestion (or a question, when the right answer isn't obvious yet).
Vague findings — *"this could be cleaner"* — don't help the author and
shouldn't be posted.

### Step 6: Generate the review report

Use this shape:

```markdown
## Summary

<one-paragraph overall assessment — does this do what its description says,
and is it safe to merge?>

## Critical

- `path/to/file.py:142` — <finding>. Suggested: <fix>.

## High

- `path/to/file.py:88` — <finding>. Suggested: <fix>.

## Medium

- `path/to/file.py:30` — <finding>.

## Low

- `path/to/file.py:12` — <finding>.

## Notes

<positive observations — patterns worth keeping, good test coverage,
clear refactor; balances the rest>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Skip empty severity sections — don't write `## Critical\n*(none)*`.

### Step 7: Confirm what to do with the review

Print the draft report. Then use `AskUserQuestion` to ask which posture
to take:

- **Approve** — *the change is safe to merge as-is or with trivial
  follow-ups*.
- **Request changes** — *blocking findings exist; author should
  iterate*.
- **Comment-only review** — *findings exist but you don't want to
  block; common when reviewing as a peer rather than a CODEOWNER*.
- **View locally only** — *don't post anything; user just wanted the
  audit*.

Match the posture to the severity mix: don't approve a PR with Critical
findings, and don't request changes for Low-only findings.

### Step 8: Post the review

Use `gh pr review` with the appropriate flag. Always HEREDOC the body so
formatting survives:

```bash
gh pr review <num> --approve --body "$(cat <<'EOF'
<body>
EOF
)"

gh pr review <num> --request-changes --body "$(cat <<'EOF'
<body>
EOF
)"

gh pr review <num> --comment --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL afterward.

If recent reviews on this repo use **inline comments** rather than a
single top-level summary, follow that pattern instead — check
`gh api repos/<owner>/<repo>/pulls/<num>/reviews` and recent merged
PRs (`gh pr list --state merged --limit 3`) before posting. Don't
double-post: pick one mode (top-level summary *or* inline comments)
unless the project clearly does both.

## What NOT to do

- Don't post a review without showing the draft and waiting for an
  explicit yes.
- Don't approve a PR you haven't actually read end-to-end.
- Don't fabricate file:line references — every one must be verifiable
  against `gh pr diff <num>`.
- Don't stack speculative concerns. *"This might race"* without a
  concrete trigger is noise; either show the trigger or leave it out.
- Don't write findings without a suggestion or a question. *"This is
  bad"* is not actionable.
- Don't review your own PR via `gh pr review`. If you self-authored,
  produce a self-checklist for the user to act on instead.
- Don't both post a top-level summary *and* a comment-mode inline
  thread on the same review pass unless that's the project's norm.
- Don't change the review posture (approve/request-changes/comment)
  silently from what the user picked.
