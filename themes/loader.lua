-- Theme loader: shared between WezTerm and NeoVim
local M = {}

local themes_dir = '/Users/Shared/dotfiles/themes'

M.default_theme = 'catppuccin-mocha'

function M.themes_dir()
  return themes_dir
end

function M.read_current()
  local f = io.open(themes_dir .. '/current', 'r')
  if not f then return M.default_theme end
  local name = f:read('*l')
  f:close()
  if not name or name == '' then return M.default_theme end
  return name:match('^%s*(.-)%s*$')
end

function M.write_current(name)
  local f = io.open(themes_dir .. '/current', 'w')
  if f then
    f:write(name .. '\n')
    f:close()
  end
end

function M.load_theme(name)
  local path = themes_dir .. '/' .. name .. '.lua'
  local f = io.open(path, 'r')
  if not f then return nil end
  f:close()
  local ok, theme = pcall(dofile, path)
  if ok and type(theme) == 'table' then
    return theme
  end
  return nil
end

function M.list_themes()
  local themes = {}
  local handle = io.popen('ls "' .. themes_dir .. '"/*.lua 2>/dev/null')
  if handle then
    for line in handle:lines() do
      local basename = line:match('([^/]+)%.lua$')
      if basename and basename ~= 'loader' then
        table.insert(themes, basename)
      end
    end
    handle:close()
  end
  table.sort(themes)
  return themes
end

function M.next_theme(current)
  local themes = M.list_themes()
  if #themes == 0 then return current end
  for i, name in ipairs(themes) do
    if name == current then
      return themes[(i % #themes) + 1]
    end
  end
  return themes[1]
end

function M.prev_theme(current)
  local themes = M.list_themes()
  if #themes == 0 then return current end
  for i, name in ipairs(themes) do
    if name == current then
      return themes[((i - 2) % #themes) + 1]
    end
  end
  return themes[#themes]
end

function M.read_favorites()
  local path = themes_dir .. '/favorites'
  local default_theme = M.default_theme
  local raw = {}
  local f = io.open(path, 'r')
  if f then
    for line in f:lines() do
      local name = line:match('^%s*(.-)%s*$')
      if name and name ~= '' then
        table.insert(raw, name)
      end
    end
    f:close()
  end

  local seen = {}
  local deduped = {}
  for _, name in ipairs(raw) do
    if not seen[name] then
      seen[name] = true
      table.insert(deduped, name)
    end
  end

  local out
  if #deduped == 0 then
    out = { default_theme }
  elseif not seen[default_theme] then
    out = { default_theme, unpack(deduped) }
  else
    local rest = {}
    for _, name in ipairs(deduped) do
      if name ~= default_theme then
        table.insert(rest, name)
      end
    end
    out = { default_theme, unpack(rest) }
  end

  M.write_favorites(out)
  return out
end

function M.write_favorites(favs)
  local path = themes_dir .. '/favorites'
  local f = io.open(path, 'w')
  if not f then return end
  for _, name in ipairs(favs) do
    f:write(name .. '\n')
  end
  f:close()
end

function M.next_favorite(current)
  local favs = M.read_favorites()
  local n = #favs
  if n == 0 then return current end
  local idx = 0
  for i, name in ipairs(favs) do
    if name == current then
      idx = i
      break
    end
  end
  if idx == 0 then
    return favs[1]
  end
  return favs[(idx % n) + 1]
end

function M.prev_favorite(current)
  local favs = M.read_favorites()
  local n = #favs
  if n == 0 then return current end
  local idx = 0
  for i, name in ipairs(favs) do
    if name == current then
      idx = i
      break
    end
  end
  if idx == 0 then
    return favs[n]
  end
  idx = idx - 1
  if idx < 1 then
    idx = n
  end
  return favs[idx]
end

return M
