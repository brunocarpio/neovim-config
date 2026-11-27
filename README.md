# Neovim Config

My personal Neovim config. Lua, with the built-in `vim.pack` plugin manager.

## Install

Requires Neovim >= 0.11 and git.

```bash
git clone git@github.com:brunocarpio/neovim-config.git ~/.config/nvim
```

On Windows, clone to `%LOCALAPPDATA%\nvim`. Plugins install on first launch.

## Updating

```vim
:PackUpdate
```

## Keys

Leader is `Space`.

| Key | Action |
|-----|--------|
| `jk` | Exit insert mode |
| `<C-p>` | Find files |
| `<leader>fg` | Live grep |
| `\` | Toggle file explorer |
| `<leader>gg` | Neogit |
| `<leader>z` | Zen mode |
| `gd` / `gr` / `K` | Definition / references / hover |
| `<leader>ca` | Code action |
| `<leader>f` | Format buffer |
| `<leader>so` | Toggle session tracking |

See `:Telescope keymaps` for the rest.
