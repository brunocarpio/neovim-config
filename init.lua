-- Neovim Configuration
-- Cross-platform setup with modern Lua configuration

-- Load platform utilities first (handles OS-specific fixes)
local platform = require("config.platform")

-- Apply platform-specific fixes early
platform.fix_vimruntime()
platform.setup_clipboard()

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration modules
require("config.options")
require("config.keymaps")
require("config.lazy")
