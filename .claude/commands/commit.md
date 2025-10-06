---
title: Smart Commit
allowedTools:
  - 'Bash(git status:*)'
  - 'Bash(git diff:*)'
  - 'Bash(git log:*)'
  - 'Bash(git add:*)'
  - 'Bash(git commit:*)'
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
8. Ask the user which commit message to use (or if they want to provide their own)
9. Stage all relevant files with `git add` if needed
10. Execute the commit with the chosen message using `git commit -m "message"`
11. Confirm the commit was successful with `git log -1`

**Important Notes:**
- DO NOT add co-authorship footers unless explicitly requested
- Respect the repository's existing conventions over general best practices
- If the repository has no clear convention, default to Conventional Commits format
- For breaking changes, add an exclamation mark after the type (e.g., feat!:)
- Keep commits atomic and focused on a single logical change
