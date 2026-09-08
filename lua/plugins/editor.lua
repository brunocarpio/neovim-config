-- Editor enhancements
return {
  -- Comment.nvim (replaces vim-commentary)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- vim-repeat (dot repeat support)
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- vim-unimpaired (bracket mappings: [b ]b buffers, [q ]q quickfix, [e ]e move lines, etc.)
  { "tpope/vim-unimpaired", event = "VeryLazy" },

  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Treesitter (syntax highlighting)
  -- DISABLED: No C compiler available for parser compilation
  -- To enable: install gcc/clang/zig, then set enabled = true
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = false, -- Disabled until C compiler is available
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "typescript", "javascript",
          "json", "html", "css", "markdown", "markdown_inline", "bash",
        },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      -- Integrate with cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}
