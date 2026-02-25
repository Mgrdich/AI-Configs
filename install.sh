#!/bin/bash

# Claude Code Configuration Installer
# This script copies commands, agents, skills, and .mcp.json from this repo
# into each Claude data directory listed in .env.
# Usage: ./install.sh
#
# Config targets are defined in .env as CONFIG_SOURCE_DIR entries.
# Each target is a Claude data directory (e.g. ~/.claude-provectus).
#
# What this script does:
# 1. Reads target directories from .env
# 2. Copies commands/, agents/, and skills/ folders into each target
# 3. Copies .mcp.json into each target
# 4. Removes files from target dirs that no longer exist in the source

set -e

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

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

    # Copy directories and remove stale files (supports nested subdirectories)
    for dir in "${COPY_DIRS[@]}"; do
        src="$REPO_CLAUDE_DIR/$dir"
        dest="$target/$dir"

        if [ ! -d "$src" ]; then
            echo -e "  ${YELLOW}Skipping $dir/ (not found in repo)${NC}"
            continue
        fi

        mkdir -p "$dest"

        # Copy source files to target (recursively)
        while IFS= read -r -d '' file; do
            rel_path="${file#$src/}"
            dest_file="$dest/$rel_path"
            mkdir -p "$(dirname "$dest_file")"
            cp "$file" "$dest_file"
            echo -e "  ${GREEN}✓${NC} $dir/$rel_path"
            copy_count=$((copy_count + 1))
        done < <(find "$src" -type f -print0)

        # Remove files in target that no longer exist in source
        while IFS= read -r -d '' file; do
            rel_path="${file#$dest/}"
            if [ ! -f "$src/$rel_path" ]; then
                rm "$file"
                echo -e "  ${RED}✗${NC} $dir/$rel_path (removed)"
                remove_count=$((remove_count + 1))
            fi
        done < <(find "$dest" -type f -print0)

        # Remove empty directories left behind after stale file cleanup
        find "$dest" -type d -empty -delete 2>/dev/null || true
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
