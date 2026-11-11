Status: confirmed

# Migrate from lazy.nvim to vim.pack

## Revisions

- 2026-11-11: Initial confirmation (eager loading, flat plugin list, auto build
  steps, drop lazy-lock.json). Verified against Neovim 0.12 `help vim.pack`:
  build steps use the `PackChanged` autocmd instead of artifact checks, and
  `vim.pack` maintains its own lockfile `nvim-pack-lock.json` (replaces
  `lazy-lock.json`, must be committed). `vim.pack.add()` does not source
  `plugin/` files during `init.lua` by default, so specs must pass `load = true`.
- 2026-11-11: Colorscheme note. The old config calls
  `vim.cmd.colorscheme("catppuccin")` for a plugin that is not installed;
  lazy.nvim swallowed that error. Without the manager, the error would abort
  `init.lua`, so the migration guards the call and falls back to
  `tokyonight` (the configured theme everywhere else).

## Job story

**When** I maintain my Neovim configuration on Neovim 0.12+, **I want** to use
the built-in `vim.pack` plugin manager instead of lazy.nvim, **so that** I rely
on core Neovim features rather than a third-party dependency.

## Why now

lazy.nvim adds bootstrap code and a dependency ecosystem (lazy-lock.json, spec
format, lazy-loading semantics) that `vim.pack` now handles natively in Neovim
0.12+. Migrating removes a third-party dependency and aligns with Neovim's
direction.

## In scope

- Replace `lua/config/lazy.lua` with `lua/config/plugins.lua` using
  `vim.pack.add()`
- Convert all `lua/plugins/*.lua` specs to `vim.pack` specs in a single flat
  list, dependencies before dependents
- Handle build steps (telescope-fzf-native, LuaSnip, nvim-treesitter) via
  `PackChanged` autocmd hooks
- Map version/branch constraints to the `vim.pack` `version` field
- Delete `lazy-lock.json`; commit the generated `nvim-pack-lock.json`
- Replace lazy's `performance.rtp.disabled_plugins` with `vim.g.loaded_* = 1`
  guards in `config/options.lua`
- Expose `:PackUpdate` user command wrapping `vim.pack.update()`
- Remove all lazy-loading triggers (event, cmd, keys, lazy=false)

## Out of scope

- Changing plugin configurations or keybindings
- Adding new plugins
- Implementing a custom lazy-loading wrapper for `vim.pack`
- Migrating Mason-installed LSP servers (unrelated to plugin management)
- Cleaning up the old `~/.local/share/nvim/lazy` data directory

## Acceptance criteria

- **AC1**: Neovim starts with no errors (`nvim --headless +qa` exits 0), and
  `vim.pack.get()` lists all previously installed plugins as `active`.
- **AC2**: Build steps run automatically: telescope-fzf-native has a compiled
  `build/` dir (when cmake is present), LuaSnip has `deps/jsregexp` built,
  treesitter parsers work (`:checkhealth vim.treesitter` or TSInstall usage).
  Builds re-run on plugin install/update via `PackChanged`, not on every start.
- **AC3**: Version constraints are respected: LuaSnip tracks the latest `v2.x`
  tag, window-picker the latest `2.x`, neo-tree branch `v3.x` (via `version`).
- **AC4**: Plugin configuration is preserved: every plugin that had `opts` or
  `config` gets the identical `setup()` call; keybindings work (`<C-p>`
  telescope, `\` neo-tree, `<leader>gg` neogit, `<leader>so` obsession,
  `<leader>f` conform, LSP mappings).
- **AC5**: No lazy.nvim artifacts remain: `lazy-lock.json` deleted,
  `lua/config/lazy.lua` deleted, no `require("lazy")` calls,
  `lazy.nvim` not in any spec list.
- **AC6**: `:PackUpdate` runs `vim.pack.update()` (confirmation buffer shows).
- **AC7**: The generated `nvim-pack-lock.json` is committed.

## Definition of done

- All acceptance criteria pass, verified with headless Neovim commands.
- `init.lua` requires `config.plugins` instead of `config.lazy`.
- Startup succeeds on a fresh data dir simulation only if trivially testable;
  otherwise first-run install path is reasoned through and left as a note.
- The diff contains no unrelated changes (no keybinding rewrites, no plugin
  additions/removals).

## Decisions

### 1. Drop lazy-loading, load all plugins eagerly (confirmed)
`vim.pack` has no lazy-loading. Manual stubs would add ~200 lines for minimal
gain; current triggers are mostly `VeryLazy`/`InsertEnter`/`BufReadPre`, so
eager loading is functionally identical for ~30 plugins.

### 2. Build steps via `PackChanged` autocmd (confirmed, mechanism revised)
Verified in `help vim.pack-events`: hooks run on `PackChanged` with
`kind == "install" or "update"`, using `ev.data.spec.name`, `ev.data.path`,
synchronously (`:wait()`). Replaces artifact-checking on every startup.

### 3. Single flat plugin list in `lua/config/plugins.lua` (confirmed)
One file: `vim.pack.add()` specs in dependency order, then plugin `setup()`
calls. Replaces `lua/plugins/*.lua` and `lua/config/lazy.lua`.

### 4. Version constraints map to `version` (confirmed)
- LuaSnip `v2.*` → `version = vim.version.range("2")`
- window-picker `2.*` → `version = vim.version.range("2")`
- neo-tree branch `v3.x` → `version = "v3.x"` (string = branch/tag/commit)
- telescope-fzf-native `cond` (cmake check) → Lua `if` around the spec

### 5. Lockfiles (confirmed, revised per API)
Delete `lazy-lock.json` (lazy-specific). `vim.pack` writes
`nvim-pack-lock.json` at the config root on first use; commit it and keep it in
sync with spec changes.

### 6. Keep the disabled runtime plugins tweak (confirmed)
Replace lazy's `performance.rtp.disabled_plugins` with
`vim.g.loaded_gzip = 1` etc. (gzip, tarPlugin, tohtml, tutor, zipPlugin) in
`config/options.lua`.

### 7. Plugin loading (verified)
Pass `load = true` to `vim.pack.add()` (default is `false` during `init.lua`
sourcing) so `plugin/` files load, and `confirm = false` so first-run install
does not prompt mid-startup.
