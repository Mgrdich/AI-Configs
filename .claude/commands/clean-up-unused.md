---
title: Clean Up Unused Code
allowedTools:
  - Read
  - Glob
  - Grep
  - Edit
  - Bash
  - LSP
---

# Clean Up Unused Code

Target directory: $ARGUMENTS

If no directory is provided, ask the user which directory or file path to analyze.

Analyze the codebase and identify unused code to clean up:

1. **Unused Imports** - Find and remove import statements that are never used
2. **Unused Variables** - Identify variables that are declared but never referenced
3. **Unused Functions** - Find functions/methods that are never called
4. **Unused Exports** - Exports that are not imported anywhere in the project
5. **Dead Code** - Unreachable code paths and commented-out code blocks
6. **Unused Dependencies** - Packages in package.json, requirements.txt, etc. that are never imported
7. **Unused Files** - Files that are not referenced or imported anywhere

For each category:
- List what was found with file paths and line numbers
- Explain why it appears to be unused
- Remove the unused code after confirmation or automatically if clearly safe
- Be careful not to remove code that may be used dynamically or via reflection

Use language-specific tools when available:
- TypeScript/JavaScript: Check for unused with TypeScript compiler or ESLint
- Python: Use the AST or tools like vulture patterns
- Go: Check for unused with go vet patterns

Provide a summary at the end with:
- Total items removed per category
- Files modified
- Any items skipped and why (e.g., possibly used dynamically)
