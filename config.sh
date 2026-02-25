#!/bin/bash

# Shared configuration for install.sh and status.sh
# This file is sourced, not executed directly.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Resolve paths relative to the calling script, not this file
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
REPO_CLAUDE_DIR="$SCRIPT_DIR/.claude"
ENV_FILE="$SCRIPT_DIR/.env"

# Items to copy from this repo into each target
COPY_DIRS=("commands" "agents" "skills")
COPY_FILES=(".mcp.json")

# Load target directories from .env
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
