-- Options (ported from vimrc)
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Search
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8

-- Behavior
opt.mouse = "a"
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.wrap = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Wildmenu
opt.wildignore:append({ "**/node_modules/*", "**/.git/*" })


vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "html", "python" },
  callback = function()
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})
