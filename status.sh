#!/bin/bash

# Claude Code Configuration Status
# This script shows the status of symlinked configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$HOME/.claude"
REPO_CLAUDE_DIR="$SCRIPT_DIR/.claude"

echo -e "${GREEN}Claude Code Configuration Status${NC}"
echo "========================================"
echo ""

# Check if symlinks are set up
if [ ! -L "$CLAUDE_DIR/settings.json" ] && [ ! -L "$CLAUDE_DIR/commands" ] && [ ! -L "$CLAUDE_DIR/agents" ]; then
    echo -e "${YELLOW}No symlinks detected. Run ./install.sh to set up symlinks.${NC}"
    exit 1
fi

echo -e "${GREEN}Configurations are symlinked - changes are automatically active!${NC}"
echo ""
echo "Symlinked from:"
echo "  $REPO_CLAUDE_DIR"
echo ""
echo "To:"
echo "  $CLAUDE_DIR"
echo ""

# Show which items are symlinked
echo -e "${YELLOW}Current symlinks:${NC}"
[ -L "$CLAUDE_DIR/settings.json" ] && echo -e "  ${GREEN}✓${NC} settings.json → $(readlink "$CLAUDE_DIR/settings.json")" || echo -e "  ${RED}✗${NC} settings.json (not symlinked)"
[ -L "$CLAUDE_DIR/CLAUDE.md" ] && echo -e "  ${GREEN}✓${NC} CLAUDE.md → $(readlink "$CLAUDE_DIR/CLAUDE.md")" || echo -e "  ${RED}✗${NC} CLAUDE.md (not symlinked)"
[ -L "$CLAUDE_DIR/commands" ] && echo -e "  ${GREEN}✓${NC} commands/ → $(readlink "$CLAUDE_DIR/commands")" || echo -e "  ${RED}✗${NC} commands/ (not symlinked)"
[ -L "$CLAUDE_DIR/agents" ] && echo -e "  ${GREEN}✓${NC} agents/ → $(readlink "$CLAUDE_DIR/agents")" || echo -e "  ${RED}✗${NC} agents/ (not symlinked)"

echo ""
echo -e "${GREEN}No update needed - symlinks are always in sync!${NC}"
echo ""
