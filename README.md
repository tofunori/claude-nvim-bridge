# claude-nvim-bridge

A lightweight bridge between Neovim and [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI, enabling real-time selection sharing without complex plugins.

![Demo](https://github.com/user/claude-nvim-bridge/assets/demo.gif)

## Features

- **Real-time selection tracking** - Your Neovim selection is captured as you select
- **Automatic context injection** - Claude Code receives your selection when you send a message
- **tmux statusbar integration** - See your current selection in the tmux status bar
- **Zero dependencies** - Just Lua, Bash, and your existing tools
- **Works with tmux** - No need for Neovim splits; use your existing tmux panes

## Architecture

```
┌─────────────────┐         ┌──────────────────────┐         ┌─────────────────┐
│     Neovim      │────────▶│  /tmp/nvim_selection │◀────────│   Claude Code   │
│  (visual mode)  │         │        .txt          │         │     (hook)      │
└─────────────────┘         └──────────────────────┘         └─────────────────┘
         │                            │
         │                            ▼
         │                   ┌──────────────────┐
         └──────────────────▶│  tmux statusbar  │
                             │   (real-time)    │
                             └──────────────────┘
```

## Installation

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/claude-nvim-bridge.git
cd claude-nvim-bridge
./install.sh
```

### Manual Install

1. **Copy the Lua module to your Neovim config:**

```bash
cp lua/claude-selection.lua ~/.config/nvim/lua/
```

2. **Add to your `init.lua`:**

```lua
require('claude-selection').setup()
```

3. **Install Claude Code hooks:**

```bash
mkdir -p ~/.claude/hooks
cp hooks/nvim-selection.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/nvim-selection.sh
```

4. **Add to `~/.claude/settings.json`:**

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/nvim-selection.sh"
          }
        ]
      }
    ]
  }
}
```

5. **(Optional) tmux statusbar integration:**

```bash
cp hooks/tmux-selection.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/tmux-selection.sh
```

Add to `~/.tmux.conf`:

```bash
# Claude selection in statusbar
set -g status-style 'bg=#1a1a1a fg=#888888'
set -g status-justify centre
set -g status-right-length 100
set -g window-status-current-format '#(~/.claude/hooks/tmux-selection.sh)'
set -g window-status-format ''
set -g status-interval 1
```

Reload tmux: `Ctrl+b r` or `tmux source-file ~/.tmux.conf`

## Usage

1. Open Neovim in one tmux pane, Claude Code in another
2. Select text in Neovim (visual mode: `v`, `V`, or `Ctrl-V`)
3. The selection appears in your tmux statusbar in real-time
4. Send a message to Claude Code
5. Claude automatically sees your selection with file path and line numbers

**Example of what Claude receives:**

```
=== Neovim Selection ===
File: /path/to/file.py:42-48

def calculate_albedo(surface, wavelength):
    """Calculate surface albedo for given wavelength."""
    return surface.reflectance(wavelength)
=== End Selection ===
```

## Configuration

### Lua Options

```lua
require('claude-selection').setup({
  selection_file = '/tmp/nvim_selection.txt',  -- Where to write selections
  enable_autocmd = true,                        -- Auto-capture on cursor move
})
```

### Customizing tmux Display

Edit `~/.claude/hooks/tmux-selection.sh` to change:
- Colors (default: cyan for filename, white for content)
- Content preview length (default: 30 characters)
- Format of the display

## How It Works

1. **Neovim autocmd** listens to `CursorMoved` events in visual mode
2. On each cursor movement, the current selection is written to `/tmp/nvim_selection.txt`
3. **Claude Code hook** (`UserPromptSubmit`) reads this file when you send a message
4. The file content is injected as context into your conversation
5. **tmux statusbar** (optional) polls the file every second for real-time display

## Comparison with claudecode.nvim

| Feature | claude-nvim-bridge | claudecode.nvim |
|---------|-------------------|-----------------|
| Dependencies | None | WebSocket, snacks.nvim |
| Setup complexity | Simple | More complex |
| Real-time tracking | Yes (file-based) | Yes (WebSocket) |
| tmux integration | Built-in | Requires provider config |
| Selection injection | Via hook | Native protocol |
| Diff support | No | Yes |
| @ mentions | No | Yes |

**Use this if:** You want a simple, hackable solution that works with tmux.

**Use claudecode.nvim if:** You need full IDE features (diffs, @ mentions, etc.)

## Troubleshooting

### Selection not appearing in Claude Code

1. Check the hook script is executable: `chmod +x ~/.claude/hooks/nvim-selection.sh`
2. Verify the file is being written: `cat /tmp/nvim_selection.txt`
3. Check Claude Code settings: `cat ~/.claude/settings.json`

### tmux statusbar not updating

1. Reload tmux config: `Ctrl+b r`
2. Check script is executable: `chmod +x ~/.claude/hooks/tmux-selection.sh`
3. Test manually: `~/.claude/hooks/tmux-selection.sh`

### Selection is empty for single characters

This can happen with edge cases. Try selecting at least 2 characters.

## Contributing

PRs welcome! Ideas for improvements:

- [ ] Support for multiple selection files (per-project)
- [ ] Integration with other AI tools (Copilot, Cursor, etc.)
- [ ] Vim support (not just Neovim)
- [ ] Better handling of very long selections

## License

MIT License - See [LICENSE](LICENSE)

## Acknowledgments

- Inspired by [claudecode.nvim](https://github.com/coder/claudecode.nvim)
- Built for use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic
