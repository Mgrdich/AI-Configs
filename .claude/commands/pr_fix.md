---
title: PR/MR Fix
allowedTools:
  - 'Bash(gh:*)'
  - 'Bash(glab:*)'
  - 'Bash(git:*)'
  - 'Read'
  - 'Write'
  - 'Edit'
  - 'Grep'
  - 'Glob'
  - 'mcp__*'
---

# Pull Request / Merge Request Fix

This command addresses review comments and issues found in a pull request or merge request.

## Usage
- `/pr_fix <PR/MR number>` - Fix issues in specific PR/MR
- `/pr_fix` - Fix issues in current branch's PR/MR

## Steps

1. Detect platform (GitHub or GitLab):
   - Check git remote URL
   - Set appropriate CLI tool (gh or glab)

2. Get PR/MR details:
   - If number provided, fetch that specific PR/MR
   - If no number, find PR/MR for current branch
   - Get PR/MR title, description, and current status

3. Fetch review comments and feedback:
   - Get all review comments from the PR/MR
   - Get inline code comments
   - Get conversation threads
   - Identify requested changes and suggestions

4. Analyze the feedback:
   - Categorize issues by type (bug, style, performance, security, etc.)
   - Prioritize issues (critical, high, medium, low)
   - Group related comments together
   - Identify files that need changes

5. Present summary of issues to fix:
   - Show total number of issues
   - Display issues by priority
   - Show which files need modifications
   - Highlight any blocking comments

6. Ask user which issues to address:
   - Option: Fix all issues automatically
   - Option: Fix by priority (critical first, then high, etc.)
   - Option: Fix specific issues (user selects)
   - Option: Show detailed plan before fixing

7. Implement fixes:
   - For each issue being addressed:
     - Read the relevant file(s)
     - Understand the context and requested change
     - Implement the fix following best practices
     - Ensure fix doesn't introduce new issues
     - Add tests if needed
   - Make changes incrementally and logically

8. Verify fixes:
   - Run tests if applicable
   - Run linting/formatting
   - Verify the fix addresses the comment
   - Check for unintended side effects

9. Commit changes:
   - Create atomic commits for each fix or related group of fixes
   - Use descriptive commit messages referencing the review comments
   - Follow repository's commit conventions

10. Update PR/MR:
    - Push changes to the branch
    - Add comment to PR/MR summarizing what was fixed
    - Optionally mark review threads as resolved
    - Request re-review if needed

11. Provide summary:
    - List all issues that were addressed
    - List any issues that couldn't be fixed automatically (with explanation)
    - Show commit(s) created
    - Confirm PR/MR was updated

## Fix Categories

**Automatic Fixes**:
- Code style and formatting issues
- Simple refactoring suggestions
- Documentation updates
- Variable/function renaming
- Import organization
- Dead code removal

**Semi-Automatic Fixes** (with confirmation):
- Logic changes
- Algorithm improvements
- Error handling additions
- Test additions
- Performance optimizations

**Manual Review Required**:
- Architecture changes
- Breaking changes
- Security vulnerability fixes
- Complex refactoring
- API design changes

## Safety Measures

- Always read the file before making changes
- Make incremental changes, not large rewrites
- Preserve existing functionality
- Run tests after changes
- Create meaningful commit messages
- Don't fix issues outside the scope of review comments
- Ask for confirmation on complex changes

## Notes
- This command uses MCP servers (if configured) or falls back to CLI tools
- Respects repository's coding conventions
- Creates clean, reviewable commits
- Provides transparency about what was changed and why
