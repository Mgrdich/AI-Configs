# Claude Code Configuration Repository

This repository contains your custom Claude Code configurations including settings, commands, agents, and hooks.

## 📁 Repository Structure

```
.
├── .claude/
│   ├── settings.json      # Global settings (permissions, hooks, models)
│   ├── CLAUDE.md          # Global instructions for all sessions
│   ├── commands/          # Custom slash commands
│   │   ├── commit.md      # Smart commit message generator
│   │   ├── pr_review.md   # Pull/Merge request reviewer
│   │   ├── pr_fix.md      # Fix PR review comments
│   │   ├── review.md      # Code review helper
│   │   └── test-all.md    # Run all tests
│   └── agents/            # Custom subagents
│       ├── code-reviewer.md
│       └── test-writer.md
├── .mcp.json              # MCP server configuration (GitHub/GitLab)
├── .env.example           # Environment variables template
├── install.sh             # Installation script (creates symlinks)
├── update.sh              # Update script (pulls latest changes)
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
   # Edit .env and add your API tokens
   ```

3. Run the install script:
   ```bash
   ./install.sh
   ```

This will create symlinks from `~/.claude/` to the files in this repository.

### What Gets Installed

- **`~/.claude/settings.json`** → Global settings and hooks
- **`~/.claude/CLAUDE.md`** → Global instructions
- **`~/.claude/commands/`** → Custom slash commands
- **`~/.claude/agents/`** → Custom subagents

## 🔄 Updating

To pull the latest changes from the repository:

```bash
./update.sh
```

Since symlinks are used, changes take effect immediately after pulling.

## 📝 Configuration Files

### `settings.json`
Contains:
- Tool permissions
- Model preferences
- Hook configurations
- Feature flags

### `CLAUDE.md`
Global instructions that Claude reads at the start of every session. Use this for:
- Coding standards
- Preferred patterns
- Global preferences

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

### Available Slash Commands

**`/commit`** - Intelligent commit message generator
- Analyzes your repository's commit history
- Detects and follows existing conventions
- Generates 3 commit message candidates
- Interactive selection process

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
```

### Custom Agents
Agents are invoked automatically by Claude when relevant, or explicitly:
```
Use the test-writer agent to add tests for this function
Use the code-reviewer agent to review this file
```

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

This repository includes MCP server configurations for GitHub and GitLab integration.

### Prerequisites

**For GitHub:**
- Create a Personal Access Token at [GitHub Settings](https://github.com/settings/tokens)
- Required scopes: `repo`, `read:org`, `read:user`
- Add to `.env`: `GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...`

**For GitLab:**
- Create a Personal Access Token at [GitLab Settings](https://gitlab.com/-/user_settings/personal_access_tokens)
- Required scopes: `api`, `read_api`
- Add to `.env`: `GITLAB_TOKEN=glpat-...`

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

### Available MCP Commands

Once configured, the `/pr_review` and `/pr_fix` commands will use MCP servers to:
- Fetch pull/merge request details
- Get diff and changes
- Add review comments
- Approve/request changes
- Update PR/MR status

### Environment Variables

All sensitive data is stored in `.env` (not committed to git). See `.env.example` for all available variables:

- `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub API access
- `GITLAB_TOKEN` - GitLab API access
- `GITLAB_HOST` - GitLab instance (default: gitlab.com)
- `LOG_LEVEL` - Logging verbosity (default: INFO)

## 🔗 Symlinks vs. Copying

This setup uses **symlinks** by default:

✅ **Pros:**
- Single source of truth
- Changes sync automatically
- Git-tracked

⚠️ **Note:** Don't symlink the `~/.claude/` directory itself (known issue). Symlink individual files/directories inside it instead.

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
4. Run `./update.sh` to get latest changes

## 📄 License

Your choice of license here.
