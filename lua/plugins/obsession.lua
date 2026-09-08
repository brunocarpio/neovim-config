-- Obsession: Session management by tpope
-- Automatically saves session state to make it easy to resume work

return {
  "tpope/vim-obsession",
  cmd = { "Obsession" },
  keys = {
    { "<leader>so", "<cmd>Obsession<cr>", desc = "Toggle session tracking" },
    { "<leader>sO", "<cmd>Obsession!<cr>", desc = "Stop session tracking and delete Session.vim" },
  },
}
