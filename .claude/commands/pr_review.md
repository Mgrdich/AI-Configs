---
title: PR/MR Review
allowedTools:
  - 'Bash(gh:*)'
  - 'Bash(glab:*)'
  - 'Bash(git:*)'
  - 'mcp__*'
---

# Pull Request / Merge Request Review

This command performs a comprehensive code review of a pull request or merge request.

## Usage
- `/pr_review <PR/MR number>` - Review specific PR/MR
- `/pr_review` - Review current branch's PR/MR

## Routing

**For GitHub repositories, prefer the `github-cli` skill** instead of running these steps. The skill has a curated GitHub-only workflow at `references/review.md` that produces tighter, project-aware reviews. To use it: invoke the Skill tool with `skill: github-cli`, then follow its routing to `references/review.md`.

The steps below remain the canonical path for **GitLab** (`glab`) and as a fallback when the `github-cli` skill is unavailable.

## Steps

1. Detect which platform is being used (GitHub or GitLab):
   - Check git remote URL for github.com or gitlab.com
   - Set appropriate CLI tool (gh or glab)
   - **If the remote is GitHub** (github.com): invoke the `github-cli` skill via the Skill tool and stop. Do not continue with the steps below — the skill handles the GitHub flow end-to-end.
   - **If the remote is GitLab** (gitlab.com): continue with the steps below using `glab`.

2. Get PR/MR details:
   - If number provided, fetch that specific PR/MR
   - If no number, find PR/MR for current branch
   - Get PR/MR title, description, author, and status

3. Fetch the diff/changes:
   - Get full diff of all changes in the PR/MR
   - Identify modified files and change summary

4. Analyze the code changes:
   - **Code Quality**: Check for readability, maintainability, and best practices
   - **Security**: Look for potential security vulnerabilities, exposed secrets, SQL injection risks, XSS vulnerabilities
   - **Performance**: Identify potential performance bottlenecks, inefficient algorithms, memory leaks
   - **Testing**: Verify if adequate tests are included, check test coverage
   - **Documentation**: Ensure code is well-documented, check if README/docs need updates
   - **Breaking Changes**: Identify any breaking changes or API modifications
   - **Dependencies**: Review new dependencies and their security status

5. Check CI/CD status:
   - Verify if tests are passing
   - Check for linting/formatting issues
   - Review deployment status

6. Generate comprehensive review report:
   - Executive summary with overall assessment
   - Detailed findings by category (Critical, High, Medium, Low)
   - Specific file and line number references
   - Code suggestions with examples
   - Positive feedback on good practices

7. Ask if the user wants to:
   - Post review comments to the PR/MR
   - Approve the PR/MR
   - Request changes
   - Just view the review locally

## Review Criteria

**Critical Issues** (Must Fix):
- Security vulnerabilities
- Data loss risks
- Breaking changes without migration path
- Exposed credentials or secrets

**High Priority**:
- Poor error handling
- Performance issues
- Missing tests for critical functionality
- Significant code quality issues

**Medium Priority**:
- Code style inconsistencies
- Missing documentation
- Suboptimal implementations
- Minor performance improvements

**Low Priority**:
- Minor refactoring suggestions
- Additional test coverage
- Code style preferences
- Documentation enhancements

## Notes
- This command uses MCP servers (if configured) or falls back to CLI tools (gh/glab)
- Respects repository's coding conventions and standards
- Provides constructive, actionable feedback
- Highlights both issues and good practices
