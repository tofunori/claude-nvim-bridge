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
    # Extract file:lines from header (supports both "File:" and "Fichier:")
    header=$(head -1 "$FILE" | sed -E 's/(File|Fichier): //')
    filename=$(basename "${header%%:*}")
    linerange="${header##*:}"

    # Calculate number of lines
    start="${linerange%%-*}"
    end="${linerange##*-}"
    numlines=$((end - start + 1))

    # Extract first 3 words from content
    words=$(tail -n +3 "$FILE" | tr '\n' ' ' | awk '{print $1, $2, $3}')

    # Output with badge for line count
    echo "#[fg=cyan]${filename} #[fg=black,bg=cyan] ${numlines}L #[default,fg=yellow] ${words}..."
else
    echo ""
fi
