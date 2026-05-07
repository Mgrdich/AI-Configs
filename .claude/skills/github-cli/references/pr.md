# Open a GitHub Pull Request

Reference doc for the **PR** flow of the `github-cli` skill. Read this only
after the SKILL.md has determined the user wants to open a pull request.

## Why this skill exists

A PR is a public artifact — it lives in the issue tracker, it's the first
thing reviewers read, and it's hard to revise after the fact. Getting the
title, summary, and verification steps right on the first push saves a
round-trip and signals that the change has been thought through.

This skill is intentionally project-agnostic. It infers the default branch,
package manager, and CI commands from the repository itself rather than
hardcoding any one toolchain. If the repo uses pnpm and Vitest, you run
those. If it uses Cargo and clippy, you run those. The shape of the
workflow stays the same — only the commands change.

## The workflow

Run the steps in order. Each gate exists for a reason; don't skip ahead.

### Step 1: Inspect the branch state

First, find the trunk branch. Don't assume `main` — some repos use
`master`, `develop`, or `trunk`.

```bash
gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null \
  || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
       | sed 's@^refs/remotes/origin/@@' \
  || echo main
```

Call that result `<base>`. Then run these in parallel — they're independent
and the results inform every later step:

```bash
git status --short
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
git log <base>..HEAD --oneline
git diff <base>...HEAD --stat
```

If the current branch *is* `<base>`, stop and tell the user — PRs are
opened from feature branches, not from trunk.

The `@{u}` query tells you whether the branch has an upstream. If it
errors, the branch has never been pushed and Step 4 will need `-u`.

Also check if a PR already exists for this branch:

```bash
gh pr list --head "$(git branch --show-current)" --json number,url,state
```

If one is open, surface it to the user and ask whether they want to update
it (push more commits) instead of opening a new one.

### Step 2: Warn about uncommitted work

If `git status --short` shows anything (modified, staged, or untracked),
list those paths and ask the user: *"These files are not committed and
will not appear in the PR. Commit them first, or open the PR without
them?"*

Wait for an answer. Silently opening a PR that excludes pending work is
the kind of thing the user only notices after a reviewer asks "where is
X?" — so this prompt is non-negotiable.

If the user wants to commit first, hand off to their normal commit flow
(or the `commit` skill if available) and come back to Step 3 once that's
done.

### Step 3: Run the project's quality gates

The goal: run locally whatever CI will run on the PR, so it doesn't land
red on the first check. Before doing that, give the user an out — sometimes
the gates are slow, the user already ran them, or this is a docs-only
change.

**First, ask.** Use `AskUserQuestion` with a single question along the
lines of *"Run lint / format / typecheck / build / test before opening
this PR?"* with options like `Run them` and `Skip — I've already verified`.
If the user picks skip, jump to Step 4 and note in the Test plan that
gates were skipped at the user's request.

**If running gates, figure out the project first.** You don't get a fixed
recipe — you have to understand what this project actually uses and run
those commands. Look at, in this order:

1. `.github/workflows/*.yml` — the workflow that runs on `pull_request` is
   the source of truth for what CI checks and in what order.
2. The build manifest at the repo root — `package.json`, `Cargo.toml`,
   `go.mod`, `pyproject.toml`, `Gemfile`, `Makefile`, etc. — which tells
   you the toolchain and the available scripts/targets.
3. The lockfile, which tells you the package manager for Node projects
   (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock(b)` → bun,
   `package-lock.json` → npm).

Then run the matching commands in parallel. Don't invent scripts that
aren't in `package.json`; don't run `cargo` against a Go repo. If the
project uses a single aggregate script (`pnpm check`, `npm run verify`,
`make ci`), run that instead of decomposed gates. Capture each command's
output — you'll need pass/fail and (where relevant) the test count for
the PR body.

If any gate fails, stop and surface the failure. Don't open a PR with
known failures unless the user explicitly asks for a draft PR — and even
then, mention the failures in the body.

### Step 4: Push the branch (if needed)

- No upstream → `git push -u origin <branch-name>`
- Has upstream but local is ahead → `git push`
- Local diverged from remote → stop and ask the user. Never `--force`
  push automatically; the user must explicitly authorize a force push.

### Step 5: Learn this project's PR style

Read the most recent merged PRs to see the live title format, section
structure, and tone:

```bash
gh pr list --state merged --limit 3 --json number,title,body
```

Match what you see there. The point is parity, not creativity — if recent
PRs use a `## Docs` section but never `## Migration notes`, follow the
same pattern. If they bullet the Summary with bolded labels
(`**Auth**: ...`), do that too. If the project has no merged PRs yet,
fall back to the conservative template below.

If there's a `.github/PULL_REQUEST_TEMPLATE.md`, that's the explicit
canonical structure — follow it instead of the templates here.

### Step 6: Draft the title and body

**Title** — if recent PRs use conventional commits (`feat:`, `fix:`,
`docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `perf:`, `build:`), match
that. If they use a different convention (e.g. `[AUTH] ...`, ticket
prefixes, plain sentences), match that instead. Keep the title under 70
characters; details belong in the body. If the project links PRs to
issues or tickets, include the id where past PRs do.

**Body** — three sections, in this order:

1. **`## Summary`** — what was built and *what problem it solves*. Lead
   with a one-sentence framing, then bullet the major changes with
   bolded labels. Reference the issue or ticket if there is one
   (`Closes #142`). The reviewer should be able to read this section
   alone and understand the change without diffing.

2. **`## Test plan`** — how a reviewer can verify this works. Include
   each gate from Step 3 with its actual result, as a checkbox list,
   using the literal commands you ran:

   ```markdown
   - [x] `<lint command>` — clean
   - [x] `<format check command>` — clean
   - [x] `<typecheck command>` — clean
   - [x] `<build command>` — succeeds
   - [x] `<test command>` — N/N passing
   ```

   Add manual verification steps (regression checks, browser testing,
   manual QA) only if you actually performed them.

3. **`## Docs`** *(optional)* — include this section only if the PR
   updates user-facing docs (`README.md`, `CHANGELOG.md`, `CLAUDE.md`,
   anything under `docs/`). List what changed and why.

Close the body with the standard tagline:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 7: Show the draft and confirm

Print the proposed title and body to the user and ask: *"Open this PR, or
want to adjust the wording?"* Wait for an explicit go-ahead.

Opening a PR is a public, hard-to-undo action — it notifies collaborators
and becomes part of the project history. The 5-second confirmation prompt
is worth it.

### Step 8: Open the PR

Use a HEREDOC so the body's formatting (markdown, backticks, newlines) is
preserved exactly:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

If the PR should target a branch other than the repo's default base, pass
`--base <branch>` explicitly. If the user asked for a draft (e.g. gates
failed but they want feedback anyway), pass `--draft`. Return the PR URL
to the user.

## Title examples

Conventional-commit style — match this register *only if* recent PRs do:

- `feat: add SSO login via OIDC`
- `fix: prevent race condition in payment retry loop`
- `docs: clarify env var setup in README`
- `refactor: extract auth middleware into its own package`
- `chore: bump dependencies for Q2 audit`
- `perf: cache user lookups in request scope`
- `test: cover edge cases in date parser`
- `ci: cache pnpm store across workflow runs`

If the project doesn't use conventional commits, follow whatever style
the last few merged PRs use.

## Body template

The body has the same shape regardless of toolchain — Summary, Test
plan, and optional Docs. Only the Test plan commands change to reflect
what Step 3 actually ran on this repo.

```markdown
## Summary

<one-sentence framing of what was built and the problem it solves.
Reference the issue or ticket if there is one — `Closes #142`.>

- **<Label>:** <major change, bolded-label style if recent PRs use it>
- **<Label>:** <next major change>

## Test plan

- [x] `<gate-1 command>` — <result, e.g. clean / N/N passing / succeeds>
- [x] `<gate-2 command>` — <result>
- [x] `<gate-N command>` — <result>
- [x] Manual: <only if you actually performed manual verification>

## Docs *(only if user-facing docs changed)*

- `<path>` — <what changed and why>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Fill the Test plan with the literal commands you ran in Step 3 — never
the placeholder names above. Don't invent gates the project doesn't
have. If recent PRs follow a different section convention (e.g. they
use `## Why` instead of `## Summary`, or omit `## Test plan` entirely),
mirror that — Step 5's voice-matching wins over this template.

## What NOT to do

- Don't open the PR without showing the draft and waiting for confirmation.
- Don't silently push past failing gates — at minimum, surface failures
  and ask whether to proceed with a draft PR.
- Don't invent sections that have no precedent in recent PRs (no
  `## Screenshots`, `## Migration notes`, `## Breaking changes` unless
  past PRs use them).
- Don't `git push --force` without explicit user approval — even when the
  remote looks "obviously stale".
- Don't describe uncommitted work in the body. Describe only what is
  actually committed and will be in the diff the reviewer sees.
- Don't fabricate test results. The Test plan should reflect what Step 3
  actually produced — same commands, same counts.
- Don't hardcode `main` or `master`. Always detect the base branch from
  the remote.
- Don't run gates the project doesn't have. If `package.json` has no
  `format:check` script and the workflow doesn't run one, skip it —
  don't fabricate a gate just to fill out the checklist.
- Don't open a duplicate PR. If `gh pr list --head <branch>` already
  shows one, update the existing PR instead.
