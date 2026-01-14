#!/bin/bash
# ------------------------------------------------------------------------------
# tmux-selection.sh
# Display current Neovim selection in tmux statusbar
# Format: filename [NL] first three words...
#
# https://github.com/tofunori/claude-nvim-bridge
# ------------------------------------------------------------------------------

FILE="/tmp/nvim_selection.txt"
if [[ -f "$FILE" && -s "$FILE" ]]; then
    # Extract file:lines from header
    header=$(head -1 "$FILE" | sed 's/File: //')
    filename=$(basename "${header%%:*}")
    linerange="${header##*:}"

    # Calculate number of lines
    start="${linerange%%-*}"
    end="${linerange##*-}"
    numlines=$((end - start + 1))

    # Extract first 3 words
    words=$(tail -n +3 "$FILE" | tr '\n' ' ' | awk '{print $1, $2, $3}')

    # Output with badge for line count
    echo "#[fg=cyan]${filename} #[fg=black,bg=cyan] ${numlines}L #[default,fg=yellow] ${words}..."
else
    echo ""
fi
