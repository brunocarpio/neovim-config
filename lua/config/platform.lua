-- Platform detection and cross-platform utilities
local M = {}

-- Detect operating system
M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
M.is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_mac
M.is_wsl = vim.fn.has("wsl") == 1

-- Get OS name as string
function M.get_os()
  if M.is_windows then
    return "windows"
  elseif M.is_mac then
    return "macos"
  elseif M.is_wsl then
    return "wsl"
  elseif M.is_linux then
    return "linux"
  else
    return "unknown"
  end
end

-- Path separator
M.path_sep = M.is_windows and "\\" or "/"

-- Join paths using appropriate separator
function M.join_path(...)
  return table.concat({ ... }, M.path_sep)
end

-- Normalize path separators for current OS
function M.normalize_path(path)
  if M.is_windows then
    return path:gsub("/", "\\")
  else
    return path:gsub("\\", "/")
  end
end

-- Get home directory
function M.get_home()
  return vim.fn.expand("~")
end

-- Get Neovim config directory (uses stdpath for portability)
function M.get_config_dir()
  return vim.fn.stdpath("config")
end

-- Get Neovim data directory
function M.get_data_dir()
  return vim.fn.stdpath("data")
end

-- Get Neovim cache directory
function M.get_cache_dir()
  return vim.fn.stdpath("cache")
end

-- Check if a command is executable
function M.has_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Get shell command based on platform
function M.get_shell()
  if M.is_windows then
    return vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  else
    return vim.env.SHELL or "/bin/sh"
  end
end

-- Platform-specific clipboard configuration
function M.setup_clipboard()
  if M.is_wsl then
    -- WSL: use clip.exe for copy, powershell for paste
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
  -- For Windows, macOS, and Linux, Neovim handles clipboard automatically
  -- when clipboard=unnamedplus is set (done in options.lua)
end

-- Fix VIMRUNTIME on Windows (Git for Windows may set it incorrectly)
function M.fix_vimruntime()
  if M.is_windows then
    local nvim_runtime = vim.fn.fnamemodify(vim.v.progpath, ":h:h") .. "/share/nvim/runtime"
    if vim.fn.isdirectory(nvim_runtime) == 1 then
      vim.env.VIMRUNTIME = nvim_runtime
    end
  end
end

return M
