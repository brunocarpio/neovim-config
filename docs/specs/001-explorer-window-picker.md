# Choose destination window when opening a file from the snacks explorer

Status: superseded

## Job story

When I press `<cr>` on a file in the snacks explorer, I want to pick which
existing window it opens into via letter labels (a/b/c/...) drawn on the
windows, so I control where the file appears.

## Acceptance criteria

1. Given a file is highlighted in the explorer, when `<cr>` is pressed, letter
   labels appear on eligible windows; pressing a letter opens the file in that
   window.
2. Eligible windows are visible, normal windows in the current tab, excluding
   the explorer's own window.
3. Pressing a key that is not a shown letter (e.g. `<esc>`) cancels: no window
   changes, the explorer stays open and usable.
4. Directories are unaffected: `<cr>` on a directory toggles it, `<bs>` keeps
   its `explorer_up` behavior.
5. With no eligible window, `<cr>` on a file does nothing and the explorer
   stays usable.
6. Focus moves to the destination window after opening.

## Definition of done

- All criteria verified manually in Neovim with a multi-window layout.
- No new plugin dependencies.
- Change confined to `lua/plugins/snacks.lua`.

## Decisions

- Key: `<cr>` opens the chooser for files (user decision; replaces default
  `jump`). `<bs>` untouched (`explorer_up`).
- Chooser UX: letter labels (a, b, c, ...) drawn on windows, like
  nvim-window-picker. Not built into snacks 2.31.0 — custom action.
- Destinations: visible windows in the current tab, explorer excluded.
- After opening: focus the destination window.

## Revisions

- 2026-11-04: Initial spec confirmed by user. User originally said `<bs>`;
  clarified to `<cr>`. User believed a/b/c chooser was built-in; verified it
  is not, implemented as custom action.
- 2026-11-04: Superseded by user decision — snacks explorer removed entirely
  and replaced with neo-tree + nvim-window-picker, which provide the a/b/c
  window chooser natively. Custom-action approach dropped.
