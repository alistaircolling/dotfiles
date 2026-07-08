-- Font tools for Neovim + WezTerm.
local M = {}

M.fonts = {}
M.favorites = {}
M.current_font = nil
M.current_index = 0
M.default_font = 'Gyrotrope'
M.default_index = 1
M.font_size = 22
M.linespace = 0
M.font_file = '/Users/Shared/dotfiles/wezterm/font-override'
M.favorites_file = '/Users/Shared/dotfiles/wezterm/font-favorites'

function M.load_fonts()
  local output = vim.fn.system('fc-list : family')
  local seen = {}
  local fonts = {}
  for line in output:gmatch('[^\n]+') do
    local family = vim.trim(line:match('^([^,]+)') or line)
    if family ~= '' and not seen[family] then
      seen[family] = true
      table.insert(fonts, family)
    end
  end
  table.sort(fonts, function(a, b) return a:lower() < b:lower() end)
  M.fonts = fonts
end

function M.find_index(name, list)
  local source = list or M.fonts
  for i, f in ipairs(source) do
    if f == name then return i end
  end
  return nil
end

function M.ensure_default_font_in_list()
  if M.find_index(M.default_font) then return end
  table.insert(M.fonts, 1, M.default_font)
end

function M.write_lines(path, lines)
  local ok = pcall(vim.fn.writefile, lines, path)
  return ok
end

function M.load_favorites()
  local ok, lines = pcall(vim.fn.readfile, M.favorites_file)
  if not ok then
    M.favorites = { M.default_font }
    M.write_lines(M.favorites_file, M.favorites)
    return
  end

  local favorites = {}
  local seen = {}
  for _, line in ipairs(lines) do
    local name = vim.trim(line)
    if name ~= '' and not seen[name] then
      seen[name] = true
      table.insert(favorites, name)
    end
  end

  if #favorites == 0 then
    favorites = { M.default_font }
  end
  if not M.find_index(M.default_font, favorites) then
    table.insert(favorites, 1, M.default_font)
  end

  M.favorites = favorites
  M.write_lines(M.favorites_file, M.favorites)
end

function M.apply_font(name)
  local f = io.open(M.font_file, 'w')
  if f then
    f:write(name .. '\n')
    f:close()
  end
  vim.o.guifont = name:gsub(' ', '\\ ') .. ':h' .. M.font_size
  vim.opt.linespace = M.linespace
  M.current_font = name
  M.current_index = M.find_index(name) or M.current_index
  vim.cmd('redraw!')
end

function M.clear_override()
  os.remove(M.font_file)
  vim.o.guifont = M.default_font:gsub(' ', '\\ ') .. ':h' .. M.font_size
  vim.opt.linespace = M.linespace
  M.current_font = M.default_font
  M.current_index = M.default_index
  vim.cmd('redraw!')
end

function M.show(name)
  local total = #M.fonts
  local idx = M.find_index(name) or M.current_index
  local star = M.find_index(name, M.favorites) and ' *fav' or ''
  local is_default = (name == M.default_font) and ' (default)' or ''
  vim.notify(string.format('Font [%d/%d]: %s%s%s', idx, total, name, is_default, star), vim.log.levels.INFO)
end

function M.next()
  if #M.fonts == 0 then return end
  local idx = M.find_index(M.current_font) or M.current_index or M.default_index
  idx = (idx % #M.fonts) + 1
  M.apply_font(M.fonts[idx])
  M.show(M.fonts[idx])
end

function M.prev()
  if #M.fonts == 0 then return end
  local idx = M.find_index(M.current_font) or M.current_index or M.default_index
  idx = idx - 1
  if idx < 1 then idx = #M.fonts end
  M.apply_font(M.fonts[idx])
  M.show(M.fonts[idx])
end

function M.search()
  if #M.fonts == 0 then
    vim.notify('No fonts found from fc-list', vim.log.levels.WARN)
    return
  end

  local query = vim.fn.input('Font search: ')
  if query == nil or vim.trim(query) == '' then return end
  local q = query:lower()
  local matches = {}
  for _, name in ipairs(M.fonts) do
    if name:lower():find(q, 1, true) then
      table.insert(matches, name)
    end
  end

  if #matches == 0 then
    vim.notify('No matching fonts', vim.log.levels.WARN)
    return
  end

  vim.ui.select(matches, { prompt = 'Select font' }, function(choice)
    if not choice then return end
    M.apply_font(choice)
    M.show(choice)
  end)
end

function M.favorite_add(name)
  local target = name or M.current_font or M.default_font
  if M.find_index(target, M.favorites) then
    vim.notify('Already in favorites: ' .. target, vim.log.levels.INFO)
    return
  end
  table.insert(M.favorites, target)
  M.write_lines(M.favorites_file, M.favorites)
  vim.notify('Added favorite: ' .. target, vim.log.levels.INFO)
end

function M.favorite_remove(name)
  local target = name or M.current_font
  if not target then
    vim.notify('No current font to remove', vim.log.levels.WARN)
    return
  end

  if target == M.default_font then
    vim.notify('Default font cannot be removed from favorites', vim.log.levels.WARN)
    return
  end

  local next_favorites = {}
  local removed = false
  for _, font in ipairs(M.favorites) do
    if font ~= target then
      table.insert(next_favorites, font)
    else
      removed = true
    end
  end

  if not removed then
    vim.notify('Not in favorites: ' .. target, vim.log.levels.INFO)
    return
  end

  M.favorites = next_favorites
  M.write_lines(M.favorites_file, M.favorites)
  vim.notify('Removed favorite: ' .. target, vim.log.levels.INFO)
end

function M.favorite_next()
  if #M.favorites == 0 then return end
  local idx = M.find_index(M.current_font, M.favorites) or 0
  idx = (idx % #M.favorites) + 1
  local name = M.favorites[idx]
  M.apply_font(name)
  M.show(name)
end

function M.favorite_prev()
  if #M.favorites == 0 then return end
  local idx = M.find_index(M.current_font, M.favorites) or 1
  idx = idx - 1
  if idx < 1 then idx = #M.favorites end
  local name = M.favorites[idx]
  M.apply_font(name)
  M.show(name)
end

function M.reset()
  M.clear_override()
  M.show(M.default_font)
end

function M.setup()
  M.load_fonts()
  M.ensure_default_font_in_list()
  M.load_favorites()

  M.default_index = M.find_index(M.default_font) or 1

  local ok, lines = pcall(vim.fn.readfile, M.font_file)
  local saved = ok and lines[1] and vim.trim(lines[1]) or nil
  local starting_font = (saved and saved ~= '') and saved or M.default_font

  M.current_font = starting_font
  M.current_index = M.find_index(starting_font) or M.default_index
  vim.o.guifont = starting_font:gsub(' ', '\\ ') .. ':h' .. M.font_size
  vim.opt.linespace = M.linespace

  vim.keymap.set('n', '<leader>fn', M.next, { desc = 'Next font' })
  vim.keymap.set('n', '<leader>fp', M.prev, { desc = 'Previous font' })
  vim.keymap.set('n', '<leader>fd', M.reset, { desc = 'Default font' })
  vim.keymap.set('n', '<leader>fs', M.search, { desc = 'Search font' })
  vim.keymap.set('n', '<leader>fa', M.favorite_add, { desc = 'Add favorite font' })
  vim.keymap.set('n', '<leader>fx', M.favorite_remove, { desc = 'Remove favorite font' })
  vim.keymap.set('n', '<leader>f]', M.favorite_next, { desc = 'Next favorite font' })
  vim.keymap.set('n', '<leader>f[', M.favorite_prev, { desc = 'Previous favorite font' })
end

return M
