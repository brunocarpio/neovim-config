-- Git integration
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        local command = function(name, com)
          vim.api.nvim_create_user_command(name, function()
            com()
          end, {})
        end

        -- Navigation
        map("n", "]c", gs.next_hunk, "Next hunk")
        map("n", "[c", gs.prev_hunk, "Previous hunk")

        -- Commands
        command('HunkPreview', gs.preview_hunk)
        command('HunkStage', gs.stage_hunk)
        command('HunkReset', gs.reset_hunk)
        command('HunkDiffThis', gs.diffthis)
      end,
    },
  },

  -- Fugitive (Git commands)
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
}
