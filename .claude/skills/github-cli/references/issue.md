# Open a GitHub Issue

Reference doc for the **issue** flow of the `github-cli` skill. Read this
only after the SKILL.md has determined the user wants to file an issue.

## Why this skill exists

An issue is a tracked artifact that other people search, dedupe against,
label, link PRs to, and close. A poorly-written issue costs more time to
triage than to write properly: the triager has to guess what was meant,
chase the reporter for repro steps, or worse, close it as not-reproducible
when the bug is real. The point of this workflow is to ship the issue with
everything triage needs the first time.

## Pick the issue type first

Different types want different bodies. Decide which one applies before
drafting:

- **Bug** — something doesn't work the way it should. Needs repro steps.
- **Feature request** — capability the project doesn't have yet. Needs a
  problem statement and a proposed solution.
- **Task** — known work to be done (refactor, migration, chore). Needs a
  goal and acceptance criteria, no proposal.
- **Question / discussion** — clarification needed, design input wanted.
  Often belongs in Discussions if the repo has them enabled — check
  `gh repo view --json hasDiscussionsEnabled` and suggest that first.

If the user is vague about intent, ask. The body shape is too different to
guess.

## The workflow

Run the steps in order.

### Step 1: Confirm the repo and check for duplicates

```bash
gh repo view --json nameWithOwner,defaultBranchRef,hasIssuesEnabled
```

If `hasIssuesEnabled` is false, stop — issues aren't accepted on this repo.
Tell the user and ask where they'd like to file (Discussions, a different
repo, etc.).

Then search for prior art using keywords from the user's description:

```bash
gh issue list --search "<keywords>" --state all --limit 10 \
  --json number,title,state,url
```

If anything looks related, surface the candidates to the user and ask:
*"Is your report a duplicate of any of these, a follow-up to one of them,
or a separate issue?"* Don't open a duplicate; if it's a follow-up,
reference the parent in the body.

### Step 2: Learn the project's voice

Read recent issues to mirror format, length, and labeling:

```bash
gh issue list --state all --limit 5 --json number,title,body,labels
gh label list --json name,description --limit 100
```

Note:
- Title style (sentence case vs. title case, prefixes like `[BUG]` or
  `bug:`, ticket-id conventions).
- Whether bodies use specific section headers (`### Steps` vs.
  `## Reproduction`) — match exactly.
- Which labels are real and how they're applied.

If the repo has issue templates (`.github/ISSUE_TEMPLATE/*.md` or
`*.yml`), read those — they are the explicit canonical structure and you
should follow them rather than the templates below.

### Step 3: Draft the title

Keep it under ~80 characters. The title is what people see in the list and
in notifications, so optimize for "can a triager understand the gist
without opening it?".

- **Bug:** lead with the symptom, not the suspected cause. Past PRs may
  use `bug: ` or similar prefixes — match them.
  - Good: `Modal closes when clicking inside content area on iOS Safari`
  - Bad: `iOS bug` (too vague), `Possibly a z-index issue in modal`
    (speculation belongs in the body)
- **Feature request:** name the capability, not the implementation.
  - Good: `Support exporting reports as CSV`
  - Bad: `Add a CSV button to the export dialog`
- **Task:** verb + object.
  - Good: `Migrate auth middleware to v2 SDK`

### Step 4: Draft the body by type

Pick the matching template. Don't include sections you have nothing to
fill in — empty sections create noise. If the repo has an issue template,
follow that instead.

#### Bug

```markdown
## Summary

<one or two sentences on what's wrong>

## Steps to reproduce

1. <step>
2. <step>
3. <step>

## Expected behavior

<what should happen>

## Actual behavior

<what happens instead — include the exact error message if there is one>

## Environment

- OS: <e.g. macOS 14.5>
- Browser / runtime: <e.g. Chrome 126, Node 20.11, iOS Safari 17>
- Project version / commit: <git sha or release tag>
- Anything else load-bearing: <e.g. behind corporate proxy, feature flag X enabled>

## Additional context

<logs, screenshots, related issues/PRs, links — only if you actually have them>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### Feature request

```markdown
## Problem

<the user-facing problem this solves — not the solution>

## Proposed solution

<what you'd build, at a high level — not implementation details unless asked>

## Alternatives considered

<other approaches and why they're worse, if relevant>

## Acceptance criteria

- [ ] <observable behavior #1>
- [ ] <observable behavior #2>

## Additional context

<links, screenshots, related issues>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### Task

```markdown
## Goal

<what we're trying to achieve and why>

## Acceptance criteria

- [ ] <criterion>
- [ ] <criterion>

## Out of scope

<what this issue does not cover, to prevent scope creep>

## Notes

<links to designs, related code paths, prior discussions>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

#### Question

```markdown
## Question

<the question, plainly>

## Context

<what you tried, what you read, what you expect, why it matters>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 5: Decide on labels, assignees, milestones

These metadata fields show up in every list view and in filtering, so they
matter. Apply them only when:

- The user explicitly asked for them, **or**
- The repo's recent issues consistently use a label you can match (e.g.
  every bug gets `bug`, every issue in this area gets `area/auth`). In
  that case, suggest the labels to the user and apply only after they
  confirm.

Verify any label exists before passing it: `gh label list | grep -i <name>`.
Same for milestones (`gh repo view --json milestones`) and assignees
(typically only assign yourself or someone the user named).

### Step 6: Show the draft and confirm

Print the proposed title, body, and any labels/assignees/milestones you
plan to set. Ask: *"File this issue, or want to adjust anything?"* Wait for
an explicit yes.

### Step 7: Open the issue

```bash
gh issue create \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)" \
  [--label "<label>" --label "<label>"] \
  [--assignee "<github-handle>"] \
  [--milestone "<milestone-name>"]
```

Return the URL `gh` prints to the user.

## What NOT to do

- Don't open before searching for duplicates. Triagers hate this.
- Don't fabricate reproduction steps, error messages, or environment
  details. If you don't know, leave the section out or write
  *"need to confirm with reporter"*.
- Don't invent labels. Apply only labels that exist (`gh label list`) and
  that the project actually uses on similar issues.
- Don't @-mention people the user didn't name. Pings cost attention.
- Don't combine multiple distinct issues into one ticket. Two unrelated
  bugs = two issues; otherwise triage and follow-up linking break.
- Don't speculate in the title. *"Maybe a race condition in X"* is fine
  in the body, never as the title — it locks readers into your hypothesis.
- Don't use `--web` to open the browser editor unless the user asked for
  that flow; this skill is about composing the issue here and shipping it
  via `gh`.
