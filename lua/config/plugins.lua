local function pack_hooks(ev)
  local data = ev.data
  if data.kind ~= "install" and data.kind ~= "update" then
    return
  end
  local name = data.spec.name
  if name == "telescope-fzf-native.nvim" then
    if vim.fn.executable("cmake") == 1 then
      vim.system({
        "sh",
        "-c",
        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
      }, { cwd = data.path }):wait()
    end
  elseif name == "LuaSnip" then
    vim.system({ "make", "install_jsregexp" }, { cwd = data.path }):wait()
  elseif name == "nvim-treesitter" then
    pcall(vim.cmd.packadd, "nvim-treesitter")
    pcall(vim.cmd, "TSUpdate")
  end
end

vim.api.nvim_create_autocmd("PackChanged", { callback = pack_hooks })

local function gh(repo)
  return "https://github.com/" .. repo
end

local specs = {
  { src = gh("folke/tokyonight.nvim") },
  { src = gh("nvim-tree/nvim-web-devicons") },
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("MunifTanjim/nui.nvim") },
  {
    src = gh("s1n7ax/nvim-window-picker"),
    name = "window-picker",
    version = vim.version.range("2"),
  },
  { src = gh("tpope/vim-commentary") },
  { src = gh("tpope/vim-abolish") },
  { src = gh("tpope/vim-dadbod") },
  { src = gh("tpope/vim-dispatch") },
  { src = gh("tpope/vim-repeat") },
  { src = gh("tpope/vim-surround") },
  { src = gh("tpope/vim-unimpaired") },
  { src = gh("tpope/vim-obsession") },
  { src = gh("tpope/vim-fugitive") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("sindrets/diffview.nvim") },
  { src = gh("nvim-telescope/telescope.nvim") },
  { src = gh("NeogitOrg/neogit") },
  { src = gh("nvim-neo-tree/neo-tree.nvim"), version = "v3.x" },
  { src = gh("folke/snacks.nvim") },
  { src = gh("nvim-treesitter/nvim-treesitter") },
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("windwp/nvim-autopairs") },
  { src = gh("rafamadriz/friendly-snippets") },
  { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2") },
  { src = gh("hrsh7th/nvim-cmp") },
  { src = gh("hrsh7th/cmp-nvim-lsp") },
  { src = gh("hrsh7th/cmp-buffer") },
  { src = gh("hrsh7th/cmp-path") },
  { src = gh("hrsh7th/cmp-cmdline") },
  { src = gh("davidsierradz/cmp-conventionalcommits") },
  { src = gh("saadparwaiz1/cmp_luasnip") },
  { src = gh("stevearc/conform.nvim") },
  { src = gh("williamboman/mason.nvim") },
  { src = gh("neovim/nvim-lspconfig") },
  { src = gh("williamboman/mason-lspconfig.nvim") },
  { src = gh("nvim-zh/colorful-winsep.nvim") },
}

if vim.fn.executable("cmake") == 1 then
  table.insert(specs, { src = gh("nvim-telescope/telescope-fzf-native.nvim") })
end

vim.pack.add(specs, { load = true, confirm = false })

require("tokyonight").setup({ style = "night" })
pcall(vim.cmd.colorscheme, "catppuccin")
if not vim.g.colors_name then
  vim.cmd.colorscheme("tokyonight")
end

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

do
  local opts = {}
  opts.bigfile = { enabled = false }
  opts.dashboard = { enabled = false }
  opts.indent = {
    enabled = true,
    indent = { char = "│" },
    scope = { enabled = true, char = "│", underline = false },
    animate = { enabled = true, style = "out" },
  }
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
  opts.dim = { enabled = true }
  opts.git = { enabled = false }
  opts.gitbrowse = { enabled = false }
  opts.profiler = { enabled = false }
  opts.lazygit = { enabled = false }
  opts.zen = {
    enabled = true,
    toggles = { dim = true },
  }
  opts.bufdelete = { enabled = false }
  require("snacks").setup(opts)
end
vim.keymap.set("n", "<leader>z", function()
  require("snacks").zen()
end, { desc = "Toggle Zen Mode" })

require("window-picker").setup({
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
})

require("neo-tree").setup({
  filesystem = {
    scan_mode = "deep",
    group_empty_dirs = true,
    window = {
      width = "25%",
      mappings = {
        ["<cr>"] = "open_with_window_picker",
        ["s"] = "split_with_window_picker",
        ["v"] = "vsplit_with_window_picker",
        ["z"] = "none",
        ["zc"] = "close_all_nodes",
        ["zo"] = "expand_all_nodes",
      },
    },
  },
})
vim.keymap.set("n", "\\", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer (neo-tree)" })

do
  local telescope = require("telescope")
  local actions = require("telescope.actions")

  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          ["<Esc>"] = actions.close,
        },
      },
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "dist/",
        "build/",
      },
      path_display = { "truncate" },
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
        width = 0.87,
        height = 0.80,
      },
    },
    pickers = {
      find_files = {
        hidden = true,
      },
    },
  })

  pcall(telescope.load_extension, "fzf")
end

vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Find files (Ctrl+P)" })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Show keymaps" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", {
  desc = "Search in buffer",
})

require("gitsigns").setup({
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
      vim.api.nvim_create_user_command(name, com, {})
    end

    map("n", "]c", gs.next_hunk, "Next hunk")
    map("n", "[c", gs.prev_hunk, "Previous hunk")
    command("HunkPreview", gs.preview_hunk)
    command("HunkStage", gs.stage_hunk)
    command("HunkReset", gs.reset_hunk)
    command("HunkDiffThis", gs.diffthis)
  end,
})

require("neogit").setup({
  integrations = {
    picker = "telescope",
  },
})
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

require("conform").setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
vim.keymap.set("", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

require("nvim-autopairs").setup({})
do
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

do
  local luasnip = require("luasnip")
  luasnip.config.setup({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
end
require("luasnip.loaders.from_vscode").lazy_load()

do
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer", option = {
        get_bufnrs = function()
          return vim.tbl_filter(function(bufnr)
            return vim.bo[bufnr].buflisted and vim.api.nvim_buf_get_name(bufnr) > ""
          end, vim.api.nvim_list_bufs())
        end,
      } },
      { name = "path" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = "conventionalcommits" },
      { name = "buffer" }
    })
  })
end

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
    "lua_ls",
    "biome",
    "pyright",
    "ruff",
  },
})

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config("pyright", {
  settings = {
    pyright = {
      disableTaggedHints = false,
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportDuplicateImport = "none",
        },
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = {
    settings = {
      organizeImports = true,
    },
  },
})

vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({
  "ts_ls",
  "lua_ls",
  "biome",
  "pyright",
  "ruff",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        max_height = 80,
        max_width = 100,
        focusable = true,
      })
    end, "Hover documentation")

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", vim.lsp.buf.references, "Go to references")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>D", vim.lsp.buf.type_definition, "Type definition")
    map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
    map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'LspReferenceTarget', {})
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.makeprg = "pyright"
    vim.bo.errorformat = "%f:%l:%c - %t%*[^:]:%m"
  end,
})

vim.keymap.set("n", "<leader>so", "<cmd>Obsession<cr>", { desc = "Toggle session tracking" })
vim.keymap.set("n", "<leader>sO", "<cmd>Obsession!<cr>", {
  desc = "Stop session tracking and delete Session.vim",
})

require("colorful-winsep").setup({})

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, {})
