# Claude Code Configuration Repository

This repository contains your custom Claude Code configurations including settings, commands, agents, and hooks.

## 📁 Repository Structure

```
.
├── .claude/
│   ├── settings.json      # Global settings (permissions, hooks, models)
│   ├── commands/          # Custom slash commands
│   │   ├── clean-up-unused.md   # Remove unused code
│   │   ├── docs.md              # Documentation generator
│   │   ├── merge-conflict-resolver.md # Resolve merge conflicts
│   │   ├── pr_fix.md            # Fix PR review comments
│   │   ├── pr_review.md        # Pull/Merge request reviewer
│   │   ├── repo-research.md    # Repository analysis
│   │   ├── review.md           # Code review helper
│   │   └── test-all.md         # Run all tests
│   ├── agents/            # Custom subagents
│   │   ├── architect.md
│   │   ├── code-reviewer.md
│   │   ├── debugger.md
│   │   └── test-writer.md
│   └── skills/            # Custom skills
│       └── commit/
│           └── SKILL.md   # Smart commit message generator
├── .mcp.json              # MCP server configuration (GitHub/GitLab)
├── .env.example           # Environment variables template
├── config.sh              # Shared configuration (sourced by install/status)
├── install.sh             # Installation script (copies files to targets)
├── status.sh              # Check configuration status
└── README.md              # This file
```

## 🚀 Installation

### First Time Setup

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd AI-Configs
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your API tokens and target directories
   ```

   Add one or more `CONFIG_SOURCE_DIR` entries pointing to your Claude data directories:
   ```env
   CONFIG_SOURCE_DIR=~/.claude-provectus
   CONFIG_SOURCE_DIR=~/.claude-livenation
   ```

3. Run the install script:
   ```bash
   ./install.sh
   ```

This copies commands, agents, skills, and `.mcp.json` from this repo into each target directory listed in `.env`. Stale files that no longer exist in the source are automatically removed.

### What Gets Installed

- **`commands/`** → Custom slash commands
- **`agents/`** → Custom subagents
- **`skills/`** → Custom skills
- **`.mcp.json`** → MCP server configuration

## 🔄 Checking Status

To check the configuration status:

```bash
./status.sh
```

## 📝 Configuration Files

### `settings.json`
Contains:
- Tool permissions
- Model preferences
- Hook configurations
- Feature flags

### `commands/`
Custom slash commands stored as Markdown files.

**Example** (`.claude/commands/review.md`):
```markdown
1. Run git diff to see recent changes
2. Review code for bugs, security issues, and best practices
3. Provide detailed feedback with line numbers
4. Suggest improvements
```

Usage: `/review`

### `agents/`
Custom subagents with specialized roles.

**Example** (`.claude/agents/test-writer.md`):
```markdown
---
name: test-writer
description: Writes comprehensive unit tests for code
tools: Read, Write, Edit, Bash
model: sonnet
---

You are a test writing expert. When invoked:
1. Analyze the code structure
2. Write comprehensive unit tests
3. Follow testing best practices
4. Ensure high coverage
```

## 🎯 Usage

### Available Skills

**`/commit`** - Intelligent commit message generator (skill)
- Analyzes your repository's commit history
- Detects and follows existing conventions
- Generates 3 commit message candidates
- Interactive selection process

### Available Slash Commands

**`/pr_review [number]`** - Comprehensive PR/MR review
- Reviews code quality, security, and performance
- Provides categorized feedback (Critical, High, Medium, Low)
- Can post comments directly to GitHub/GitLab
- Requires MCP servers configured

**`/pr_fix [number]`** - Fix PR/MR review comments
- Fetches all review comments
- Categorizes and prioritizes issues
- Implements fixes automatically
- Creates clean commits with fixes

**`/review`** - Quick code review
- Reviews recent git changes
- Provides feedback on quality and best practices
- Suggests improvements

**`/test-all`** - Run all tests
- Executes test suite
- Analyzes failures
- Suggests fixes

**`/clean-up-unused`** - Remove unused code
- Identifies dead code, unused imports, and unreferenced functions
- Cleans up safely

**`/merge-conflict-resolver`** - Resolve merge conflicts
- Analyzes conflicting changes
- Resolves conflicts intelligently

**`/docs`** - Generate documentation
- Analyzes codebase structure
- Identifies undocumented code
- Generates comprehensive documentation
- Follows language-specific conventions

**`/repo-research`** - Repository analysis
- Analyzes languages, frameworks, and tech stack
- Lists dependencies and their versions
- Maps project structure and architecture
- Identifies build tools, testing, and CI/CD setup
- Flags outdated dependencies and security concerns

### Usage Examples

```bash
# Generate smart commit message
/commit

# Review PR #42
/pr_review 42

# Fix issues in current branch's PR
/pr_fix

# Quick code review
/review

# Generate documentation
/docs

# Analyze repository structure
/repo-research
```

### Custom Agents
Agents are invoked automatically by Claude when relevant, or explicitly:
```
Use the test-writer agent to add tests for this function
Use the code-reviewer agent to review this file
Use the debugger agent to find and fix this bug
Use the architect agent to review the system design
```

**Available Agents:**
- **`code-reviewer`** - Expert code reviewer for quality, security, and best practices
- **`test-writer`** - Writes comprehensive unit and integration tests
- **`debugger`** - Systematic debugging and troubleshooting expert
- **`architect`** - Software architecture and design specialist

## 🔧 Customization

### Adding a New Command

1. Create a new `.md` file in `.claude/commands/`:
   ```bash
   touch .claude/commands/my-command.md
   ```

2. Add numbered instructions:
   ```markdown
   1. First step
   2. Second step
   3. Third step
   ```

3. Commit and push:
   ```bash
   git add .claude/commands/my-command.md
   git commit -m "Add my-command"
   git push
   ```

### Adding a New Agent

1. Create a new `.md` file in `.claude/agents/`:
   ```bash
   touch .claude/agents/my-agent.md
   ```

2. Add frontmatter and instructions:
   ```markdown
   ---
   name: my-agent
   description: What this agent does
   tools: Read, Write, Edit
   model: sonnet
   ---

   Your system prompt here...
   ```

3. Commit and push

## 🔗 MCP (Model Context Protocol) Setup

This repository includes MCP server configurations for GitHub, GitLab, Sequential Thinking, and Context7.

### Prerequisites

**For GitHub:**
- Create a Personal Access Token at [GitHub Settings](https://github.com/settings/tokens)
- Required scopes: `repo`, `read:org`, `read:user`
- Add to `.env`: `GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...`

**For GitLab:**
- Create a Personal Access Token at [GitLab Settings](https://gitlab.com/-/user_settings/personal_access_tokens)
- Required scopes: `api`, `read_api`
- Add to `.env`: `GITLAB_TOKEN=glpat-...`

**For Sequential Thinking:**
- No additional configuration required
- Provides extended thinking capabilities for complex reasoning tasks

**For Context7:**
- No additional configuration required
- Provides up-to-date code documentation and examples
- Optional API key available for higher rate limits and private repos

### Installing MCP Servers

**GitHub MCP Server:**
```bash
# Automatically installed via npx when needed
# No manual installation required
```

**GitLab MCP Server:**
```bash
# Clone the GitLab MCP server
mkdir -p ~/.config/mcp-servers
cd ~/.config/mcp-servers
git clone https://github.com/mehmetakinn/gitlab-mcp-code-review.git
cd gitlab-mcp-code-review

# Install dependencies
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv pip install -r requirements.txt
```

**Sequential Thinking MCP Server:**
```bash
# Automatically installed via npx when needed
# No manual installation required
```

**Context7 MCP Server:**
```bash
# Automatically installed via npx when needed
# No manual installation required
```

### Available MCP Commands

Once configured, MCP servers provide enhanced capabilities:

**GitHub/GitLab MCP** (used by `/pr_review` and `/pr_fix`):
- Fetch pull/merge request details
- Get diff and changes
- Add review comments
- Approve/request changes
- Update PR/MR status

**Sequential Thinking MCP**:
- Extended reasoning for complex problems
- Step-by-step problem decomposition
- Enhanced analytical capabilities
- Automatic activation for challenging tasks

**Context7 MCP**:
- Up-to-date code documentation and examples
- Real-time library documentation retrieval
- Version-specific code samples
- Prevents outdated or hallucinated code examples
- Usage: Add "use context7" to your prompts

### Environment Variables

All sensitive data is stored in `.env` (not committed to git). See `.env.example` for all available variables:

- `CONFIG_SOURCE_DIR` - Target Claude data directory (one or more)
- `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub API access
- `GITLAB_TOKEN` - GitLab API access
- `GITLAB_HOST` - GitLab instance (default: gitlab.com)
- `LOG_LEVEL` - Logging verbosity (default: INFO)

## 🔗 How Installation Works

This setup uses **copy-based installation**. Running `./install.sh` copies managed items from this repo into each target directory configured in `.env`. Running it again overwrites targets with the latest source and removes stale files.

Shared configuration (colors, paths, managed item lists, `.env` parsing) lives in `config.sh` and is sourced by both `install.sh` and `status.sh`. To manage a new folder or file, add it to the `COPY_DIRS` or `COPY_FILES` array in `config.sh`.

## 📚 Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Custom Commands Guide](https://docs.claude.com/en/docs/claude-code/commands)
- [Subagents Guide](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide)

## 🤝 Contributing

If you're sharing this with a team:

1. Fork this repository
2. Make your changes
3. Submit a pull request
4. Run `./install.sh` to deploy latest changes

## 📄 License

Your choice of license here.
