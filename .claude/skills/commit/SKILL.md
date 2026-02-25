---
title: Smart Commit
allowedTools:
  - 'Bash(git status:*)'
  - 'Bash(git diff:*)'
  - 'Bash(git log:*)'
  - 'Bash(git add:*)'
  - 'Bash(git commit:*)'
  - AskUserQuestion
---

# Smart Commit

1. Run `git status` to check current repository status
2. Run `git diff --cached` to see staged changes (if any)
3. Run `git diff` to see unstaged changes
4. Run `git log --oneline -10` to analyze recent commit message conventions in this repository
5. Analyze the commit history to identify:
   - Commit message format (conventional commits, semantic commits, custom format)
   - Common prefixes used (feat:, fix:, chore:, docs:, etc.)
   - Emoji usage patterns (if any)
   - Typical message length and style
   - Capitalization conventions
   - Tense used (imperative, past tense, etc.)
6. Based on the repository's conventions, generate 3 commit message candidates that:
   - Follow the detected repository convention style
   - Accurately describe the changes
   - Use imperative mood if conventional commits are detected
   - Keep the first line concise (under 72 characters)
   - Include additional context in body if changes are complex
7. Present the 3 candidates with brief reasoning for each
8. Use the `AskUserQuestion` tool to let the user pick a commit message. Provide the 3 candidates as selectable options (the user can also choose "Other" to write their own). Use header "Commit msg" and set `multiSelect: false`.
9. Stage all relevant files with `git add` if needed
10. Use the `AskUserQuestion` tool to ask: "Add Co-Authored-By: Claude footer?" with header "Co-author" and `multiSelect: false`. Provide two options: "Yes" (description: "Append Co-Authored-By: Claude <noreply@anthropic.com> to the commit message") and "No" (description: "Commit without co-author footer").
11. Execute the commit with the chosen message using `git commit -m "message"`
    - If the user selected "Yes" in step 10, append a `Co-Authored-By: Claude <noreply@anthropic.com>` footer to the commit message
    - If the user selected "No", do NOT add the co-authorship footer
12. Confirm the commit was successful with `git log -1`

**Important Notes:**
- Respect the repository's existing conventions over general best practices
- If the repository has no clear convention, default to Conventional Commits format
- For breaking changes, add an exclamation mark after the type (e.g., feat!:)
- Keep commits atomic and focused on a single logical change
