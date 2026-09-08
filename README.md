# Neovim Configuration

Cross-platform Neovim configuration with Lua and lazy.nvim.

## Requirements

- Neovim >= 0.11.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)

## Installation

### Windows

```powershell
# Backup existing config (if any)
if (Test-Path "$env:LOCALAPPDATA\nvim") {
    Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.bak"
}

# Clone this config
git clone https://github.com/YOUR_USERNAME/nvim-config.git "$env:LOCALAPPDATA\nvim"
```

### macOS / Linux

```bash
# Backup existing config (if any)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/.config/nvim
```

### WSL

Same as Linux - config goes in `~/.config/nvim`.

## First Launch

On first launch, lazy.nvim will automatically:
1. Bootstrap itself
2. Install all configured plugins

Just run `nvim` and wait for the installation to complete.

## Structure

```
nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── platform.lua     # Cross-platform utilities
│   │   ├── options.lua      # Vim options
│   │   ├── keymaps.lua      # Key mappings
│   │   └── lazy.lua         # Plugin manager bootstrap
│   └── plugins/
│       ├── editor.lua       # Editor enhancements (comments, autopairs, colorscheme)
│       ├── git.lua          # Git integration (gitsigns, fugitive)
│       ├── lsp.lua          # LSP, Mason, completion
│       ├── obsession.lua    # Session management
│       ├── snacks.lua       # File explorer
│       └── telescope.lua    # Fuzzy finder
└── lazy-lock.json           # Plugin version lock file
```

## Key Mappings

Leader key: `Space`

### General

| Key | Action |
|-----|--------|
| `jk` | Exit insert mode |
| `<Esc>` | Clear search highlight |
| `<C-h/j/k/l>` | Navigate windows |
| `-` | Open parent directory (netrw) |
| `\` | Open file explorer (snacks) |

### Telescope (Fuzzy Finder)

| Key | Action |
|-----|--------|
| `<C-p>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>/` | Search in current buffer |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |

### Git

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (fugitive) |
| `<leader>gb` | Git blame |
| `]c` / `[c` | Next/previous hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage hunk |

### Session (Obsession)

| Key | Action |
|-----|--------|
| `<leader>so` | Toggle session tracking |
| `<leader>sO` | Stop tracking & delete session |

## LSP Servers

Managed by Mason. Currently configured:
- `ts_ls` - TypeScript/JavaScript
- `lua_ls` - Lua

Install additional servers with `:Mason`.

## Treesitter

Currently disabled (requires a C compiler for parser compilation). To enable:

1. Install a C compiler:
   - **Windows**: Install [zig](https://ziglang.org/) or MinGW
   - **macOS**: `xcode-select --install`
   - **Linux**: `sudo apt install build-essential` (or equivalent)

2. Edit `lua/plugins/editor.lua` and set `enabled = true` for nvim-treesitter.

## Customization

### Adding Plugins

Create a new file in `lua/plugins/` or add to an existing one:

```lua
-- lua/plugins/myplugin.lua
return {
  "author/plugin-name",
  opts = {},
}
```

### Platform-Specific Settings

Use the platform module in your config:

```lua
local platform = require("config.platform")

if platform.is_windows then
  -- Windows-specific settings
elseif platform.is_mac then
  -- macOS-specific settings
end
```

## Updating

```vim
:Lazy sync
```

Or press `S` in the Lazy UI (`:Lazy`).
