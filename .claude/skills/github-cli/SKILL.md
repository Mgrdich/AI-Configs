---
name: github-cli
description: >-
  Open, review, or iterate on a GitHub issue or pull request from the current
  repository using the `gh` CLI, with titles, bodies, and review comments
  that follow the project's conventions and the user's standards. Use this
  skill whenever the user says "open an issue", "file a bug", "report this",
  "track a bug", "create a ticket", "feature request", "open a PR", "create
  a pull request", "make an MR", "PR this branch", "ready for review", "send
  this for review", "review this PR", "audit PR #N", "review someone's PR",
  "code review", "fix review comments", "address feedback", "apply the
  review changes", "iterate on the PR", or otherwise signals they want to
  publish, audit, or iterate on work in GitHub. Also use it proactively
  after a feature branch is finished, a bug is identified, or a reviewer
  has left comments — the user may not name the artifact ("can you put
  this on GitHub for the team?", "let's clear out the comments on PR
  #142") but the right answer is still to follow this skill. The skill is
  project-agnostic: it detects the default branch, package manager, CI
  gates, and the project's voice from recent issues, merged PRs, and prior
  reviews, and it never publishes a public artifact (issue, PR, review,
  comment) without showing the draft and getting explicit confirmation
  first.
---

# GitHub CLI: Issues, PRs, Reviews, and Fixes

This skill covers the four most common `gh` flows for working on a
GitHub repo from the terminal. Each flow has its own reference doc with
the full workflow, commands, and templates. This file just routes you
to the right one and states the principles that apply to all of them.

## Routing

Pick the matching reference doc and read **only that one**:

- **File an issue** (bug, feature request, task, question, follow-up
  reminder) → [`references/issue.md`](references/issue.md)
- **Open a pull request** (commits on a feature branch ready for review)
  → [`references/pr.md`](references/pr.md)
- **Review someone else's PR** (audit a diff and post an approve /
  request-changes / comment review) →
  [`references/review.md`](references/review.md)
- **Address review feedback on your PR** (fetch comments, implement
  fixes, push, summarize) → [`references/fix.md`](references/fix.md)

If the request is ambiguous (*"open something on GitHub"*, *"do
something with PR #142"*), ask before loading any doc — the workflows
diverge sharply and guessing wastes a round-trip. Phrase the question
concretely: *"File an issue, open a PR for this branch, review someone
else's PR, or address review feedback on your own PR?"*

## Principles that apply to both flows

The reference docs contain the *how*. These are the *why*.

1. **Detect, don't assume.** Verify the upstream is GitHub and discover
   the default branch and repo metadata from `gh` rather than hardcoding
   anything. The reference doc has the exact commands.
2. **Match the project's voice before drafting.** People notice tone
   mismatches faster than logic mistakes — read recent issues / merged
   PRs and mirror their structure, length, labels, and prefixes. Parity
   beats creativity.
3. **Draft, then confirm — every time.** Issues and PRs are public,
   hard-to-edit, and notify other people. Print the proposed title and
   body to the user and wait for explicit yes before running `gh`.
4. **Preserve formatting via HEREDOC.** When the reference doc shows
   `gh ... --body "$(cat <<'EOF' ... EOF)"`, that pattern is mandatory —
   it keeps markdown, backticks, and code fences intact and prevents the
   shell from expanding `$` inside the body.
5. **Close every body with the standard tagline.** At the very end:
   `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
6. **Never fabricate.** No invented test results, labels you didn't
   verify exist, references to issues/PRs you haven't checked, or fake
   reproduction steps. If you don't know, say so.
7. **Return the URL** that `gh` prints after success.

## What NOT to do (cross-cutting)

Each reference doc has its own NOT-to-do list. These apply regardless of
which flow you're in:

- Don't publish without showing the draft and waiting for explicit yes.
- Don't apply labels, milestones, projects, or assignees that the user
  didn't ask for and that aren't already an established convention in
  the repo.
- Don't use `--force` flags without explicit user authorization.
- Don't combine flows. If the user asked for one of the four flows
  (file an issue, open a PR, review a PR, fix review comments), do
  exactly that one — don't slip into another "for completeness".
- Don't load multiple reference docs at once. Pick one based on the
  user's intent and read only that one.
