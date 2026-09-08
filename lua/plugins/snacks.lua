-- =============================================================================
-- File tree plugin: snacks.nvim explorer
-- =============================================================================

return {
  {
    "folke/snacks.nvim",
    -- Keep snacks but only load the explorer; disable all other snacks modules
    opts = function(_, opts)
      opts.bigfile = { enabled = false }
      opts.dashboard = { enabled = false }
      opts.indent = { enabled = false }
      opts.input = { enabled = false }
      opts.notifier = { enabled = false }
      opts.scope = { enabled = false }
      opts.scroll = { enabled = false }
      opts.statuscolumn = { enabled = false }
      opts.words = { enabled = false }
      opts.rename = { enabled = false }
      opts.terminal = { enabled = false }
      opts.win = { enabled = false }
      opts.toggle = { enabled = false }
      opts.image = { enabled = false }
      opts.animate = { enabled = false }
      opts.notify = { enabled = false }
      opts.dim = { enabled = false }
      opts.git = { enabled = false }
      opts.gitbrowse = { enabled = false }
      opts.profiler = { enabled = false }
      opts.lazygit = { enabled = false }
      opts.zen = { enabled = false }
      opts.bufdelete = { enabled = false }
      opts.explorer = opts.explorer or {}
    end,
    keys = {
      { "\\", function() require("snacks").explorer() end, desc = "Explorer Snacks (root dir)" },
    },
  },
}
