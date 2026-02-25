#!/bin/bash

# Claude Code Configuration Installer
# This script copies commands, agents, and .mcp.json from this repo
# into each Claude data directory listed in .env.
# Usage: ./install.sh
#
# Config targets are defined in .env as CONFIG_SOURCE_DIR entries.
# Each target is a Claude data directory (e.g. ~/.claude-provectus).
#
# What this script does:
# 1. Reads target directories from .env
# 2. Copies commands/ and agents/ folders into each target
# 3. Copies .mcp.json into each target
# 4. Removes files from target dirs that no longer exist in the source

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_CLAUDE_DIR="$SCRIPT_DIR/.claude"
ENV_FILE="$SCRIPT_DIR/.env"

# Items to copy from this repo into each target
COPY_DIRS=("commands" "agents")
COPY_FILES=(".mcp.json")

echo -e "${GREEN}Claude Code Configuration Installer${NC}"
echo "========================================"
echo ""

# --- Validate repo source ---
if [ ! -d "$REPO_CLAUDE_DIR" ]; then
    echo -e "${RED}Error: .claude/ directory not found in repo at $REPO_CLAUDE_DIR${NC}"
    exit 1
fi

echo -e "Source: ${BLUE}$SCRIPT_DIR${NC}"
echo ""

# --- Load target directories from .env ---
TARGETS=()

if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        key="$(echo "$key" | xargs)"
        if [ "$key" = "CONFIG_SOURCE_DIR" ]; then
            value="$(echo "$value" | sed 's/^["'\''"]//;s/["'\''"]$//')"
            value="${value/#\~/$HOME}"
            TARGETS+=("$value")
        fi
    done < "$ENV_FILE"
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No CONFIG_SOURCE_DIR entries found in .env${NC}"
    echo "Add one or more CONFIG_SOURCE_DIR=/path/to/claude-data-dir lines to .env"
    echo ""
    echo "Example .env:"
    echo "  CONFIG_SOURCE_DIR=~/.claude-provectus"
    echo "  CONFIG_SOURCE_DIR=~/.claude-livenation"
    exit 1
fi

echo -e "Found ${GREEN}${#TARGETS[@]}${NC} target(s):"
for target in "${TARGETS[@]}"; do
    echo "  - $target"
done
echo ""

# --- Copy files and clean up stale ones in each target ---
copy_count=0
remove_count=0

for target in "${TARGETS[@]}"; do
    if [ ! -d "$target" ]; then
        echo -e "${RED}Warning: Target does not exist, skipping: $target${NC}"
        continue
    fi

    echo -e "${BLUE}Installing to: $target${NC}"

    # Copy directories (commands/, agents/) and remove stale files
    for dir in "${COPY_DIRS[@]}"; do
        src="$REPO_CLAUDE_DIR/$dir"
        dest="$target/$dir"

        if [ ! -d "$src" ]; then
            echo -e "  ${YELLOW}Skipping $dir/ (not found in repo)${NC}"
            continue
        fi

        mkdir -p "$dest"

        # Copy source files to target
        for file in "$src"/*; do
            [ -f "$file" ] || continue
            filename="$(basename "$file")"
            cp "$file" "$dest/$filename"
            echo -e "  ${GREEN}✓${NC} $dir/$filename"
            copy_count=$((copy_count + 1))
        done

        # Remove files in target that no longer exist in source
        for file in "$dest"/*; do
            [ -f "$file" ] || continue
            filename="$(basename "$file")"
            if [ ! -f "$src/$filename" ]; then
                rm "$file"
                echo -e "  ${RED}✗${NC} $dir/$filename (removed)"
                remove_count=$((remove_count + 1))
            fi
        done
    done

    # Copy individual files (.mcp.json)
    for file in "${COPY_FILES[@]}"; do
        src="$SCRIPT_DIR/$file"

        if [ ! -f "$src" ]; then
            echo -e "  ${YELLOW}Skipping $file (not found in repo)${NC}"
            continue
        fi

        cp "$src" "$target/$file"
        echo -e "  ${GREEN}✓${NC} $file"
        copy_count=$((copy_count + 1))
    done

    echo ""
done

echo -e "${GREEN}Installation complete! Copied $copy_count file(s), removed $remove_count stale file(s).${NC}"
echo ""
echo "Items installed:"
for dir in "${COPY_DIRS[@]}"; do
    echo "  $dir/"
done
for file in "${COPY_FILES[@]}"; do
    echo "  $file"
done
echo ""
echo "To change targets, edit CONFIG_SOURCE_DIR entries in .env and re-run ./install.sh"
