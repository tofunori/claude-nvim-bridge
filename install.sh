#!/bin/bash
# ------------------------------------------------------------------------------
# install.sh
# Installer for claude-nvim-bridge
# https://github.com/YOUR_USERNAME/claude-nvim-bridge
# ------------------------------------------------------------------------------

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing claude-nvim-bridge...${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install Lua module
echo -e "${YELLOW}[1/4]${NC} Installing Neovim Lua module..."
NVIM_LUA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lua"
mkdir -p "$NVIM_LUA_DIR"
cp "$SCRIPT_DIR/lua/claude-selection.lua" "$NVIM_LUA_DIR/"
echo "  → Installed to $NVIM_LUA_DIR/claude-selection.lua"

# 2. Install hook scripts
echo -e "${YELLOW}[2/4]${NC} Installing Claude Code hooks..."
HOOKS_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/nvim-selection.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/tmux-selection.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/nvim-selection.sh"
chmod +x "$HOOKS_DIR/tmux-selection.sh"
echo "  → Installed to $HOOKS_DIR/"

# 3. Update Claude Code settings
echo -e "${YELLOW}[3/4]${NC} Checking Claude Code settings..."
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    if grep -q "nvim-selection.sh" "$CLAUDE_SETTINGS"; then
        echo "  → Hook already configured in settings.json"
    else
        echo -e "  ${YELLOW}⚠${NC}  Please add the hook manually to $CLAUDE_SETTINGS:"
        echo ""
        echo '    "hooks": {'
        echo '      "UserPromptSubmit": [{'
        echo '        "matcher": "",'
        echo '        "hooks": [{'
        echo '          "type": "command",'
        echo '          "command": "~/.claude/hooks/nvim-selection.sh"'
        echo '        }]'
        echo '      }]'
        echo '    }'
        echo ""
    fi
else
    echo "  → Creating $CLAUDE_SETTINGS"
    cp "$SCRIPT_DIR/config-examples/settings.json" "$CLAUDE_SETTINGS"
fi

# 4. Neovim setup reminder
echo -e "${YELLOW}[4/4]${NC} Neovim configuration..."
echo "  → Add this to your init.lua:"
echo ""
echo "    require('claude-selection').setup()"
echo ""

# Summary
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Add require('claude-selection').setup() to your init.lua"
echo "  2. (Optional) Add tmux config from config-examples/tmux.conf"
echo "  3. Restart Neovim and reload tmux config (Ctrl+b r)"
echo ""
echo "Usage:"
echo "  1. Select text in Neovim (visual mode)"
echo "  2. Send a message to Claude Code"
echo "  3. Claude sees your selection automatically!"
