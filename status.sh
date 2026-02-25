#!/bin/bash

# Claude Code Configuration Status
# This script shows the status of copied configurations
# Usage: ./status.sh
#
# What this script does:
# 1. Reads target directories from .env
# 2. Checks which managed files exist in each target
# 3. Compares them against the repo source

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

# Items managed by install.sh
COPY_DIRS=("commands" "agents" "skills")
COPY_FILES=(".mcp.json")

echo -e "${GREEN}Claude Code Configuration Status${NC}"
echo "========================================"
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

echo -e "${YELLOW}Source (this repo):${NC}"
echo -e "  $SCRIPT_DIR"
echo ""

echo -e "${YELLOW}Targets (.env):${NC}"
if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "  ${RED}None configured${NC}"
else
    for target in "${TARGETS[@]}"; do
        if [ -d "$target" ]; then
            echo -e "  ${GREEN}✓${NC} $target"
        else
            echo -e "  ${RED}✗${NC} $target (not found)"
        fi
    done
fi
echo ""

# --- Check installed files in each target ---
for target in "${TARGETS[@]}"; do
    [ -d "$target" ] || continue

    echo -e "${BLUE}$target${NC}"

    for dir in "${COPY_DIRS[@]}"; do
        src_dir="$REPO_CLAUDE_DIR/$dir"
        dest_dir="$target/$dir"

        if [ ! -d "$src_dir" ]; then
            continue
        fi

        echo -e "  ${BLUE}$dir/${NC}"

        # Check source files against target (recursively)
        while IFS= read -r -d '' src_file; do
            rel_path="${src_file#$src_dir/}"
            dest_file="$dest_dir/$rel_path"

            if [ ! -f "$dest_file" ]; then
                echo -e "    ${RED}✗${NC} $rel_path (missing)"
            elif diff -q "$src_file" "$dest_file" >/dev/null 2>&1; then
                echo -e "    ${GREEN}✓${NC} $rel_path (up to date)"
            else
                echo -e "    ${YELLOW}~${NC} $rel_path (differs from source)"
            fi
        done < <(find "$src_dir" -type f -print0 | sort -z)

        # Check for orphaned files in target that don't exist in source
        if [ -d "$dest_dir" ]; then
            while IFS= read -r -d '' dest_file; do
                rel_path="${dest_file#$dest_dir/}"
                if [ ! -f "$src_dir/$rel_path" ]; then
                    echo -e "    ${RED}!${NC} $rel_path (orphaned — not in source)"
                fi
            done < <(find "$dest_dir" -type f -print0 | sort -z)
        fi
    done

    for file in "${COPY_FILES[@]}"; do
        src_file="$SCRIPT_DIR/$file"
        dest_file="$target/$file"

        if [ ! -f "$src_file" ]; then
            continue
        fi

        if [ ! -f "$dest_file" ]; then
            echo -e "  ${RED}✗${NC} $file (missing)"
        elif diff -q "$src_file" "$dest_file" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $file (up to date)"
        else
            echo -e "  ${YELLOW}~${NC} $file (differs from source)"
        fi
    done

    echo ""
done
