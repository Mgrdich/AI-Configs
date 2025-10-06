#!/bin/bash

# Claude Code Configuration Installer
# This script creates symlinks from ~/.claude to this repository
# Usage: ./install.sh
#
# What this script does:
# 1. Creates ~/.claude directory if it doesn't exist
# 2. Creates symlinks for settings.json, commands/, and agents/
# 3. Backs up existing files if they aren't symlinks
# 4. Enables automatic syncing of configuration changes

set -e  # Exit immediately if any command fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located (handles spaces in paths)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$HOME/.claude"
REPO_CLAUDE_DIR="$SCRIPT_DIR/.claude"

echo -e "${GREEN}Claude Code Configuration Installer${NC}"
echo "========================================"
echo ""

# Create ~/.claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Creating $CLAUDE_DIR directory...${NC}"
    mkdir -p "$CLAUDE_DIR"
fi

# Function to create symlink safely
# Parameters:
#   $1 - source: The file/directory in the repository
#   $2 - target: The destination path in ~/.claude
#   $3 - name: Human-readable name for logging
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    # Check if target already exists (file or symlink)
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            # Remove existing symlink to replace it
            echo -e "${YELLOW}Removing existing symlink: $target${NC}"
            rm "$target"
        else
            # Backup existing file/directory to preserve user data
            echo -e "${YELLOW}Backing up existing $name to ${target}.backup${NC}"
            mv "$target" "${target}.backup"
        fi
    fi

    # Create the symlink (-s = symbolic, -f = force)
    ln -sf "$source" "$target"
    echo -e "${GREEN}✓ Linked $name${NC}"
}

# Install settings.json
if [ -f "$REPO_CLAUDE_DIR/settings.json" ]; then
    create_symlink "$REPO_CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json" "settings.json"
else
    echo -e "${YELLOW}! settings.json not found in repo${NC}"
fi

# Install CLAUDE.md
if [ -f "$REPO_CLAUDE_DIR/CLAUDE.md" ]; then
    create_symlink "$REPO_CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"
else
    echo -e "${YELLOW}! CLAUDE.md not found in repo${NC}"
fi

# Install commands directory
if [ -d "$REPO_CLAUDE_DIR/commands" ]; then
    create_symlink "$REPO_CLAUDE_DIR/commands" "$CLAUDE_DIR/commands" "commands/"
else
    echo -e "${YELLOW}! commands/ directory not found in repo${NC}"
fi

# Install agents directory
if [ -d "$REPO_CLAUDE_DIR/agents" ]; then
    create_symlink "$REPO_CLAUDE_DIR/agents" "$CLAUDE_DIR/agents" "agents/"
else
    echo -e "${YELLOW}! agents/ directory not found in repo${NC}"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Your Claude Code configurations are now symlinked to:"
echo "  $REPO_CLAUDE_DIR"
echo ""
echo "Any changes you make in the repo will automatically apply to Claude Code."
echo ""
echo "To update from the repository, run: ./update.sh"
