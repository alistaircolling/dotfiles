-- Theme tools for Neovim + WezTerm (writes themes/current; same file as shell `theme` command).
local M = {}

M.themes = {}
M.favorites = {}
M.current_theme = nil
M.default_theme = 'catppuccin-mocha'
M.loader_path = '/Users/Shared/dotfiles/themes/loader.lua'

local function loader()
  return dofile(M.loader_path)
end

function M.load_themes()
  M.themes = loader().list_themes()
end

function M.load_favorites()
  M.favorites = loader().read_favorites()
end

function M.theme_label(key)
  local t = loader().load_theme(key)
  return t and t.name or key
end

function M.apply_key(key)
  local l = loader()
  l.write_current(key)
  require('theme_apply').apply(key)
  M.current_theme = key
end

function M.show(key)
  key = key or M.current_theme
  local total = #M.themes
  local idx = 0
  for i, t in ipairs(M.themes) do
    if t == key then
      idx = i
      break
    end
  end
  local star = vim.tbl_contains(M.favorites, key) and ' *fav' or ''
  local is_default = (key == M.default_theme) and ' (default)' or ''
  vim.notify(
    string.format('Theme [%d/%d]: %s — %s%s%s', idx, total, key, M.theme_label(key), is_default, star),
    vim.log.levels.INFO
  )
end

function M.next()
  if #M.themes == 0 then
    return
  end
  local l = loader()
  local cur = l.read_current()
  local next_key = l.next_theme(cur)
  M.apply_key(next_key)
  M.show(next_key)
end

function M.prev()
  if #M.themes == 0 then
    return
  end
  local l = loader()
  local cur = l.read_current()
  local prev_key = l.prev_theme(cur)
  M.apply_key(prev_key)
  M.show(prev_key)
end

function M.search()
  if #M.themes == 0 then
    vim.notify('No themes found in dotfiles/themes', vim.log.levels.WARN)
    return
  end

  local query = vim.fn.input('Theme search: ')
  if query == nil or vim.trim(query) == '' then
    return
  end
  local q = query:lower()
  local matches = {}
  for _, key in ipairs(M.themes) do
    if key:lower():find(q, 1, true) or M.theme_label(key):lower():find(q, 1, true) then
      table.insert(matches, key)
    end
  end

  if #matches == 0 then
    vim.notify('No matching themes', vim.log.levels.WARN)
    return
  end

  vim.ui.select(matches, {
    prompt = 'Select theme',
    format_item = function(key)
      return key .. ' — ' .. M.theme_label(key)
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.apply_key(choice)
    M.show(choice)
  end)
end

function M.favorite_add(name)
  local target = name or M.current_theme or loader().read_current()
  if vim.tbl_contains(M.favorites, target) then
    vim.notify('Already in favorites: ' .. target, vim.log.levels.INFO)
    return
  end
  table.insert(M.favorites, target)
  loader().write_favorites(M.favorites)
  M.load_favorites()
  vim.notify('Added favorite: ' .. target, vim.log.levels.INFO)
end

function M.favorite_remove(name)
  local target = name or M.current_theme
  if not target then
    vim.notify('No current theme to remove', vim.log.levels.WARN)
    return
  end

  if target == M.default_theme then
    vim.notify('Default theme cannot be removed from favorites', vim.log.levels.WARN)
    return
  end

  local next_favorites = {}
  local removed = false
  for _, key in ipairs(M.favorites) do
    if key ~= target then
      table.insert(next_favorites, key)
    else
      removed = true
    end
  end

  if not removed then
    vim.notify('Not in favorites: ' .. target, vim.log.levels.INFO)
    return
  end

  loader().write_favorites(next_favorites)
  M.load_favorites()
  vim.notify('Removed favorite: ' .. target, vim.log.levels.INFO)
end

function M.favorite_next()
  local l = loader()
  if #M.favorites == 0 then
    return
  end
  local cur = l.read_current()
  local key = l.next_favorite(cur)
  M.apply_key(key)
  M.show(key)
end

function M.favorite_prev()
  local l = loader()
  if #M.favorites == 0 then
    return
  end
  local cur = l.read_current()
  local key = l.prev_favorite(cur)
  M.apply_key(key)
  M.show(key)
end

function M.favorite_pick()
  M.load_favorites()
  if #M.favorites == 0 then
    vim.notify('No favorites', vim.log.levels.WARN)
    return
  end
  vim.ui.select(M.favorites, {
    prompt = 'Favorite theme',
    format_item = function(key)
      return key .. ' — ' .. M.theme_label(key)
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.apply_key(choice)
    M.show(choice)
  end)
end

function M.reset()
  M.apply_key(M.default_theme)
  M.show(M.default_theme)
end

function M.setup()
  M.load_themes()
  M.load_favorites()
  M.current_theme = loader().read_current()

  vim.keymap.set('n', '<leader>tn', M.next, { desc = 'Next theme (all)' })
  vim.keymap.set('n', '<leader>tp', M.prev, { desc = 'Previous theme (all)' })
  vim.keymap.set('n', '<leader>td', M.reset, { desc = 'Default theme' })
  vim.keymap.set('n', '<leader>ts', M.search, { desc = 'Search theme' })
  vim.keymap.set('n', '<leader>ta', M.favorite_add, { desc = 'Add favorite theme' })
  vim.keymap.set('n', '<leader>tx', M.favorite_remove, { desc = 'Remove favorite theme' })
  vim.keymap.set('n', '<leader>t]', M.favorite_next, { desc = 'Next favorite theme' })
  vim.keymap.set('n', '<leader>t[', M.favorite_prev, { desc = 'Previous favorite theme' })
  vim.keymap.set('n', '<leader>tF', M.favorite_pick, { desc = 'Pick favorite theme' })
end

return M
