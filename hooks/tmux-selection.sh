#!/bin/bash
# ------------------------------------------------------------------------------
# tmux-selection.sh
# Display current Neovim selection in tmux statusbar
#
# Install: Place in ~/.claude/hooks/ and add to ~/.tmux.conf
# https://github.com/YOUR_USERNAME/claude-nvim-bridge
# ------------------------------------------------------------------------------

SELECTION_FILE="${CLAUDE_NVIM_SELECTION_FILE:-/tmp/nvim_selection.txt}"
MAX_CONTENT_LENGTH="${CLAUDE_TMUX_MAX_LENGTH:-30}"

if [[ -f "$SELECTION_FILE" && -s "$SELECTION_FILE" ]]; then
    # Extract file:lines from header
    header=$(head -1 "$SELECTION_FILE" | sed 's/File: //')
    filename=$(basename "${header%%:*}")
    lines="${header##*:}"

    # Extract content preview (skip header lines)
    content=$(tail -n +3 "$SELECTION_FILE" | tr '\n' ' ' | cut -c1-"$MAX_CONTENT_LENGTH")

    # Format output with tmux colors
    if [[ -n "$content" ]]; then
        echo "#[fg=cyan]${filename}:${lines}#[fg=white] ${content}..."
    else
        echo "#[fg=cyan]${filename}:${lines}"
    fi
else
    echo ""
fi
