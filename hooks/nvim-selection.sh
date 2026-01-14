#!/bin/bash
# ------------------------------------------------------------------------------
# nvim-selection.sh
# Claude Code hook script - injects Neovim selection into conversation context
#
# Install: Place in ~/.claude/hooks/ and add to ~/.claude/settings.json
# https://github.com/YOUR_USERNAME/claude-nvim-bridge
# ------------------------------------------------------------------------------

SELECTION_FILE="${CLAUDE_NVIM_SELECTION_FILE:-/tmp/nvim_selection.txt}"

if [[ -f "$SELECTION_FILE" && -s "$SELECTION_FILE" ]]; then
    echo "=== Neovim Selection ==="
    cat "$SELECTION_FILE"
    echo "=== End Selection ==="
fi
