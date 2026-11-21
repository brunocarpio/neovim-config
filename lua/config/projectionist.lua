local M = {}

local cached_root = nil

local function is_dir(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

local function is_file(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

local function py_files(dir)
  local files = {}
  if not is_dir(dir) then
    return files
  end
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" and name:match("%.py$") then
      files[#files + 1] = name
    end
  end
  table.sort(files)
  return files
end

local function find_root(file)
  if cached_root and file:sub(1, #cached_root) == cached_root then
    return cached_root
  end
  local dir = vim.fs.dirname(file)
  local previous = nil
  while dir and dir ~= previous and dir ~= "" do
    if is_file(dir .. "/pyproject.toml") and is_dir(dir .. "/src") then
      for name in vim.fs.dir(dir .. "/src") do
        if name:match("%-hexagon$") then
          cached_root = dir
          return dir
        end
      end
    end
    previous = dir
    dir = vim.fs.dirname(dir)
  end
  return nil
end

local function scan_members(root)
  local hexagons = {}
  local adapters = {}
  for name, kind in vim.fs.dir(root .. "/src") do
    if kind == "directory" then
      local app = name:match("^(.-)%-hexagon$")
      if app then
        hexagons[app] = name
      end
      local rest = name:match("^.-adapter%-for(.+)$")
      if rest then
        local port_token, tech = rest:match("^(.+)%-([^%-]+)$")
        if port_token then
          adapters[#adapters + 1] = {
            dir = name,
            port_token = port_token,
            tech = tech,
          }
        end
      end
    end
  end
  table.sort(adapters, function(a, b)
    return a.dir < b.dir
  end)
  return hexagons, adapters
end

local function build_projections(root)
  local projections = {
    ["*"] = { dispatch = "uv run pytest -q" },
    ["src/**/driving_ports/for_*.py"] = { type = "dport" },
    ["src/**/driven_ports/for_*.py"] = { type = "driven" },
    ["tests/adapters/test_*.py"] = { type = "test", dispatch = "uv run pytest {file} -q" },
    ["src/genai-configurator/src/genai_configurator/*.py"] = { type = "config" },
  }

  local hexagons, adapters = scan_members(root)

  local port_files = {}
  for app, hex_dir in pairs(hexagons) do
    local pkg = app .. "_hexagon"
    local pkg_dir = "src/" .. hex_dir .. "/src/" .. pkg
    if is_dir(root .. "/" .. pkg_dir) then
      projections[pkg_dir .. "/*.py"] = { type = app .. "hexagon" }
    end
    for _, kind in ipairs({ "driving_ports", "driven_ports" }) do
      for _, fname in ipairs(py_files(root .. "/" .. pkg_dir .. "/" .. kind)) do
        local port = fname:match("^for_(.*)%.py$")
        if port then
          port_files[app .. ":" .. port:gsub("_", "")] = pkg_dir .. "/" .. kind .. "/" .. fname
        end
      end
    end
  end

  for _, adapter in ipairs(adapters) do
    local app = adapter.dir:match("^(.-)%-adapter%-")
    adapter.app = app
    adapter.pkg = app .. "_adapter_for" .. adapter.port_token .. "_" .. adapter.tech
    local pkg_dir = "src/" .. adapter.dir .. "/src/" .. adapter.pkg
    if is_dir(root .. "/" .. pkg_dir) then
      projections[pkg_dir .. "/*.py"] = { type = app .. "adapter" }
    end

    local port_file = port_files[app .. ":" .. adapter.port_token]
    local test_file = "tests/adapters/test_" .. adapter.pkg .. ".py"
    local alternate = {}
    if port_file then
      alternate[#alternate + 1] = port_file
    end
    if is_file(root .. "/" .. test_file) then
      alternate[#alternate + 1] = test_file
    end
    for _, fname in ipairs(py_files(root .. "/" .. pkg_dir)) do
      if fname ~= "__init__.py" and #alternate > 0 then
        projections[pkg_dir .. "/" .. fname] = { alternate = { alternate[1], alternate[2] } }
      end
    end
    if port_file and is_file(root .. "/" .. test_file) then
      projections[test_file] = { alternate = { port_file } }
    end
  end

  for key, port_file in pairs(port_files) do
    local app, token = key:match("^(.-):(.+)$")
    local adapter_files = {}
    for _, adapter in ipairs(adapters) do
      if adapter.app == app and adapter.port_token == token then
        for _, fname in ipairs(py_files(root .. "/src/" .. adapter.dir .. "/src/" .. adapter.pkg)) do
          if fname ~= "__init__.py" then
            adapter_files[#adapter_files + 1] = "src/" .. adapter.dir .. "/src/" .. adapter.pkg .. "/" .. fname
          end
        end
      end
    end
    if #adapter_files > 0 then
      projections[port_file] = { alternate = adapter_files }
    end
  end

  return projections
end

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "ProjectionistDetect",
    callback = function()
      local file = vim.g.projectionist_file
      local append = vim.fn["projectionist#append"]
      if not file or not append then
        return
      end
      local root = find_root(file)
      if root then
        append(root, build_projections(root))
      end
    end,
  })
end

M.setup()

return M
