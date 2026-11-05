return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        version = "2.*",
        opts = {
          hint = "floating-big-letter",
          selection_chars = "abcdefghijklmnopqrstuvwxyz",
          filter_rules = {
            autoselect_one = true,
            include_current_win = false,
            bo = {
              filetype = { "neo-tree", "notify", "qf" },
              buftype = { "terminal" },
            },
          },
        },
      },
    },
    lazy = false,
    opts = {
      filesystem = {
        group_empty_dirs = true,
        window = {
          mappings = {
            ["<cr>"] = "open_with_window_picker",
            ["s"] = "split_with_window_picker",
            ["v"] = "vsplit_with_window_picker",
          },
        },
      },
    },
  },
}
