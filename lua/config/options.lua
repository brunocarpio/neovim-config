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

-- Reload files changed outside of Neovim
opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    -- Ignore terminal buffers, which checktime can interfere with
    if vim.bo.buftype ~= "terminal" then
      vim.cmd("checktime")
    end
  end,
})

-- Keep git views in sync with changes made outside of Neovim

local last_status_refresh = 0

local function fugitive_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "fugitive" then
      table.insert(wins, win)
    end
  end
  return wins
end

local function refresh_fugitive_status()
  local wins = fugitive_windows()
  if #wins == 0 or vim.fn.exists("*fugitive#ReloadStatus") == 0 then
    return
  end
  local now = vim.uv.hrtime()
  if now - last_status_refresh < 1e9 then
    return
  end
  last_status_refresh = now
  for _, win in ipairs(wins) do
    vim.api.nvim_win_call(win, function()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      vim.cmd("silent call fugitive#ReloadStatus()")
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
      vim.api.nvim_win_set_cursor(0, { row, math.min(col, math.max(0, #line)) })
    end)
  end
end

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    pcall(function()
      require("gitsigns").refresh()
    end)
    refresh_fugitive_status()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TabEnter", "CursorHold", "CursorHoldI" }, {
  callback = refresh_fugitive_status,
})

local status_timer = vim.uv.new_timer()
status_timer:start(2000, 2000, vim.schedule_wrap(function()
  pcall(refresh_fugitive_status)
end))

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Wildmenu
opt.wildignore:append({ "**/node_modules/*", "**/.git/*" })


vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "html", "python", "cpp", "c" },
  callback = function()
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})
