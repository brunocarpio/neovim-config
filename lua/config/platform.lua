local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_wsl = vim.fn.has("wsl") == 1

function M.setup_clipboard()
  if M.is_wsl then
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
      },
      paste = {
        ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  end
end

function M.fix_vimruntime()
  if M.is_windows then
    local nvim_runtime = vim.fn.fnamemodify(vim.v.progpath, ":h:h") .. "/share/nvim/runtime"
    if vim.fn.isdirectory(nvim_runtime) == 1 then
      vim.env.VIMRUNTIME = nvim_runtime
    end
  end
end

return M
