Status: in-progress

## Revisions

- 2026-11-21: Corrected every `plugins.lua` path reference to the existing `lua/config/plugins.lua`; no behavior or scope changes.

# Add Go LSP support via gopls

**Purpose**: Enable Go language intelligence (completion, diagnostics, hover, navigation) so editing `.go` files gets the same LSP experience as TypeScript, Python, and Lua in this config.

## Job story

When I open a `.go` file in a Go module, I want `gopls` attached to the buffer with completion and the existing LSP keymaps working, so I can navigate, rename, and inspect Go code without leaving Neovim.

## Why now

Go is the only major language in the current editing rotation (TS, Python, Lua, Java all have LSPs) that lacks one. The cost of not doing it is context-switching to a separate editor/terminal for Go work.

## In scope

- Add `gopls` to `mason-lspconfig.ensure_installed` and `vim.lsp.enable`.
- Follow the existing convention (plugins in `plugins.lua`, LSP config via `vim.lsp.config`, shared `LspAttach` keymaps).

## Out of scope (follow-ups)

- `makeprg` / `:make` for Go.
- Explicit `go` treesitter parser.
- Go-specific formatters in conform.nvim (gopls formatting via `lsp_fallback` is enough for v1).
- `gopls` per-server settings (analyses, hints) — add only if needed later.

## Acceptance criteria

**Given** `gopls` is not installed by Mason yet,
**When** Neovim starts and `plugins.lua` is loaded,
**Then** `gopls` appears in Mason's managed install list and is installed automatically on first run.

**Given** a Go file is opened inside a Go module,
**When** the `LspAttach` autocmd fires for that buffer,
**Then** `:LspInfo` lists `gopls` as the attached client and the generic LSP keymaps (`K`, `gd`, `gr`, `gi`, `<leader>rn`, `<leader>ca`) work on Go identifiers.

**Given** a Go buffer with a missing import,
**When** completion is invoked in insert mode,
**Then** `cmp` offers LSP completion items sourced from `gopls` (the `nvim_lsp` source).

**Given** `gopls` is not yet on `$PATH` and Mason has not run,
**When** Neovim starts,
**Then** startup does not error and no spurious messages about a missing `gopls` appear.

**Given** a non-Go file is opened,
**When** LSP attaches,
**Then** the set of attached servers is unchanged from today (no regression in TS/Python/Lua/Java).

## Definition of done

- Every acceptance criterion is covered by a manual check with exact steps (no CI for dotfiles).
- The narrow check: `:Mason` shows `gopls` installed; `:LspInfo` in a `.go` file shows `gopls`; LSP keymaps resolve a symbol in Go code.
- `init.lua` loads without error on a fresh checkout.
- The diff contains only the additions needed for Go — no unrelated reformatting of `plugins.lua`.
- Reviewer has checked that `vim.lsp.enable` and `ensure_installed` stay in sync with the rest of the list.

## Decisions

- **Server**: `gopls` only, no secondary linter — default. gopls already provides diagnostics; adding `staticcheck` duplicates and is a follow-up.
- **Plugin list**: no new plugin — `nvim-lspconfig`, `mason`, and `mason-lspconfig` are already present — default. No `go.nvim` or similar; the existing `vim.lsp.*` API plus the shared `LspAttach` autocmd is sufficient.
- **`vim.lsp.config("gopls", ...)` block**: omit (empty defaults) — default. Add one only when a concrete setting is wanted; empty blocks are noise.
- **`automatic_enable` exclude list**: do not add `gopls` — default. Unlike `jdtls`, `gopls` attaches cleanly via the standard path.
- **Conform formatter for Go**: do not add `gofmt`/`goimports` here — default. `format_on_save` with `lsp_fallback = true` already invokes gopls formatting; goimports can be a follow-up if import sorting matters.
- **Location of change**: append to the existing `ensure_installed` / `vim.lsp.enable` lists in `plugins.lua`, keeping lexical/grouping order — default. Do not split into a separate file; the current config keeps every LSP in one place.

## Assumptions

- The user has (or will install) a Go toolchain; Mason installs `gopls` itself but `go` on `$PATH` is still expected for project builds.
- `gopls` defaults are acceptable; no workspace-specific settings are required yet.

## Open questions

- None blocking the draft. If the user wants goimports-based format-on-save or a `:make`-based `go build ./...`, those are explicit follow-ups, not part of this story.
