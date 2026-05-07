---
name: github-cli
description: >-
  Open a GitHub issue or pull request from the current repository using the
  `gh` CLI, with a title and body that follow the project's conventions and
  the user's standards. Use this skill whenever the user says "open an issue",
  "file a bug", "report this", "track a bug", "create a ticket", "feature
  request", "open a PR", "create a pull request", "make an MR", "PR this
  branch", "ready for review", "send this for review", or otherwise signals
  they want to publish work to GitHub. Also use it proactively after a feature
  branch is finished or a bug is identified — the user may not name the
  artifact ("can you put this on GitHub for the team?") but the right answer
  is still to follow this skill. The skill is project-agnostic: it detects the
  default branch, package manager, CI gates, and the project's voice from
  recent issues and merged PRs, and it never opens a public artifact without
  showing the draft and getting explicit confirmation first.
---

# GitHub CLI: Issues and PRs

This skill covers the two most common `gh` flows that publish a public
artifact on GitHub. Each flow has its own reference doc with the full
workflow, commands, and templates. This file just routes you to the right
one and states the principles that apply to both.

## Routing

Pick the matching reference doc and read **only that one**:

- **File an issue** (bug, feature request, task, question, follow-up
  reminder) → [`references/issue.md`](references/issue.md)
- **Open a pull request** (commits on a feature branch ready for review)
  → [`references/pr.md`](references/pr.md)

If the request is ambiguous (*"open something on GitHub"*, *"can you put
this on GitHub?"*), ask before loading either doc — the workflows diverge
sharply and guessing wastes a round-trip. Phrase the question concretely:
*"File an issue about this, or open a PR for the branch you're on?"*

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
- Don't combine the two flows. If the user asked for an issue, don't
  also open a PR (or vice versa) "for completeness" — open exactly
  what was requested.
- Don't load both reference docs at once. Pick one based on the user's
  intent and read only that one.
