# Address Review Feedback on Your PR

Reference doc for the **fix** flow of the `github-cli` skill. Read this
only after the SKILL.md has determined the user wants to address review
comments on their own open PR.

## Why this skill exists

Iterating on review feedback is high-stakes mechanical work: each
comment is an explicit request, the author of the PR is on the hook to
address it, and reviewers are watching the PR's `commits` tab to see
whether their feedback was applied. Missing a comment, fixing the wrong
thing, or sneaking in unrelated work all damage trust. This workflow
keeps the iteration tight: read every comment, decide what to fix, fix
it precisely, and tell the reviewer what you did.

## The workflow

Run the steps in order.

### Step 1: Resolve the target PR

Same as `references/review.md` Step 1:

```bash
# explicit number
gh pr view <num> --json number,title,state,url,baseRefName,headRefName,author

# current branch
gh pr view --json number,title,state,url,baseRefName,headRefName,author
```

If the PR is closed or merged, stop — there's nothing to fix. Confirm
the PR is authored by the current user (`gh api user --jq .login`) — if
it isn't, you're not the right person to push fixes, and the right
flow is `references/review.md` instead.

### Step 2: Fetch all review threads

The JSON view gives you the top-level reviews; the inline comment
positions live on a separate endpoint. Fetch both:

```bash
gh pr view <num> --json reviews,comments
gh api "repos/{owner}/{repo}/pulls/<num>/comments" --paginate
```

For very active PRs, also grab the threaded review comments:

```bash
gh api "repos/{owner}/{repo}/pulls/<num>/reviews" --paginate
```

You need: who said what, on which file:line, on which commit SHA, and
whether the thread is resolved. Resolved threads are not your problem
unless the user explicitly asks to revisit them.

### Step 3: Categorize the feedback

Group comments into a working list. Use the existing rubric from the
project's `/pr_fix` command:

By **type**: bug / style / perf / security / docs.

By **priority**:
- **Critical** — blocking; PR cannot merge without these.
- **High** — strongly requested changes.
- **Medium** — suggestions the reviewer would like applied.
- **Low** — nits, optional improvements.

Group related comments (multiple comments about the same function or
the same pattern) so they can be addressed in one commit.

### Step 4: Present the summary to the user

Show counts before doing any work. The user needs to see the scope:

```
12 unresolved comments across 4 files:
  - 1 critical (file.py:142)
  - 4 high (auth.py:30, auth.py:88, util.py:12, util.py:55)
  - 5 medium
  - 2 low
Blocking review: @reviewer (request-changes posture)
```

Highlight any thread the reviewer marked as blocking — those are the
ones to fix first.

### Step 5: Ask which to address

Use `AskUserQuestion`. Options to offer:

- **Fix all** — work through every comment in priority order.
- **Fix by priority** — Critical + High only (or Critical + High +
  Medium); Low items get a brief reply explaining why they're
  deferred.
- **Fix specific issues** — user names which comments to address.
- **Show plan first** — produce a per-comment plan, no edits, then
  ask for go-ahead.

Default to "show plan first" when the comment count is high (>10) — it
prevents 30 minutes of work going in the wrong direction.

### Step 6: Implement the fixes

Three tiers, preserved from the existing rubric:

- **Automatic** — apply directly: style/formatting, simple refactors,
  doc tweaks, renames, import order, dead code removal.
- **Semi-automatic** — confirm with the user before applying: logic
  changes, algorithm tweaks, error-handling additions, new tests,
  performance optimizations.
- **Manual** — surface to the user and let them drive: architecture
  changes, breaking changes, security-vulnerability fixes, complex
  refactors, public API design.

For each fix:
1. Read the file at the cited line.
2. Confirm the cited line still exists at that position (the PR may
   have moved since the comment was left). If the line moved, follow
   the change and verify the comment still applies.
3. Apply the smallest edit that addresses the comment. Don't fix
   adjacent code that wasn't called out — that's scope creep.
4. Sanity-check: does the edit change observable behavior in a way
   the reviewer would not have predicted from their comment? If yes,
   pause and confirm with the user.

### Step 7: Run the project's local gates

Before pushing, run whatever CI will run on the PR. The detection logic
is the same as `references/pr.md` Step 3:

1. `.github/workflows/*.yml` for the workflow that runs on
   `pull_request` — that's the ground truth.
2. The build manifest (`package.json`, `Cargo.toml`, `go.mod`,
   `pyproject.toml`, `Gemfile`, `Makefile`).
3. The lockfile to identify the package manager.

Run the matching commands. If a gate fails, stop and surface the
failure — don't push code that will turn the PR red and force another
round.

### Step 8: Commit atomically

One commit per fix or per coherent group of related fixes. Each commit
message references the comment it addresses (e.g. *"fix: handle empty
input per @reviewer's comment on auth.py:30"*) so the reviewer can map
commits to threads.

If the user has the `commit` skill installed, hand off to it. Otherwise
inline a `git commit` with a message that follows the project's
conventional-commit style (look at recent merged PRs to confirm).

### Step 9: Push

- Has upstream and local is ahead → `git push`.
- Local has diverged from remote → stop and ask the user. Never
  `--force` push to a review iteration without explicit authorization;
  reviewers reading commit-by-commit lose context when history is
  rewritten.

### Step 10: Update the PR

Post a summary comment on the PR listing what was fixed and what
wasn't, with reasons:

```bash
gh pr comment <num> --body "$(cat <<'EOF'
Addressed review comments:

- ✅ `auth.py:30` — added null check (commit abc1234)
- ✅ `auth.py:88` — switched to parameterized query (commit def5678)
- ⏭️ `util.py:12` — deferring; will follow up in a separate PR
       because it requires changing the public API.
- 💬 `util.py:55` — disagree; the current implementation is
       intentional. Replied inline.

CI: <link to checks>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

If the user explicitly authorizes it, mark addressed threads resolved
via the GraphQL API:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }' -f threadId="<thread-id>"
```

Default to **not** resolving — many teams expect the reviewer to do it.
Only resolve when the user says so.

### Step 11: Return the URL and the unfinished list

Print the PR URL and a short list of any comments that weren't fixed,
with the reason for each. The user needs that list to either follow up
themselves or to reply to the reviewer.

## What NOT to do

- Don't fix issues that weren't raised in the review. Scope creep
  damages trust and inflates diffs.
- Don't squash unrelated work into the fix commits. Each commit should
  trace back to a comment.
- Don't mark review threads resolved without explicit user
  authorization. Some teams treat that as the reviewer's job.
- Don't push past failing local gates. If lint/test/typecheck/build
  fails after your edits, stop and surface it — don't let CI catch it.
- Don't `--force` push to address a comment. Reviewers track commit-
  by-commit; rewriting history mid-review is hostile.
- Don't combine "address review feedback" with "open a new PR." If a
  comment requires changes large enough to warrant a separate PR,
  surface that to the user and hand off to `references/pr.md`.
- Don't reply to comments you don't intend to address with silence.
  Either fix it or post a reply explaining the decision.
- Don't apply a fix at the wrong line because the diff has shifted —
  re-anchor the comment against the current file before editing.
