local platform = require("config.platform")

platform.fix_vimruntime()
platform.setup_clipboard()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
