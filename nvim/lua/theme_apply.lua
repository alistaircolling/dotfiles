-- Apply a dotfiles theme key (themes/<key>.lua) inside Neovim.
-- Shared by theme-watcher and theme-cycler.
local M = {}

local themes_dir = '/Users/Shared/dotfiles/themes'
local loader_chunk = dofile(themes_dir .. '/loader.lua')
local opacity_file = '/Users/Shared/dotfiles/wezterm/opacity'

local function read_opacity()
  local f = io.open(opacity_file, 'r')
  if not f then return 100 end
  local val = tonumber(f:read('*l'))
  f:close()
  return math.max(1, math.min(100, val or 100))
end

-- Clear backgrounds on key highlight groups so terminal transparency shows through
local function apply_transparency()
  local groups = { 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer' }
  for _, group in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    hl.bg = nil
    vim.api.nvim_set_hl(0, group, hl)
  end
end

function M.apply(name)
  if not name or name == '' then
    name = loader_chunk.default_theme
  end

  local theme_path = themes_dir .. '/' .. name .. '.lua'
  local ok, theme = pcall(dofile, theme_path)
  if not ok or type(theme) ~= 'table' or not theme.nvim then
    vim.o.background = 'dark'
    pcall(vim.cmd.colorscheme, loader_chunk.default_theme)
    return
  end

  vim.o.background = theme.nvim.background or 'dark'

  local cs = theme.nvim.colorscheme
  local style = theme.nvim.style

  if cs == 'material' and style then
    vim.g.material_style = style
  end

  if cs == 'onedark' or cs == 'onelight' then
    local s = style or (cs == 'onelight' and 'light' or 'dark')
    local onedark_ok, onedark = pcall(require, 'onedark')
    if onedark_ok then
      onedark.setup({ style = s })
    end
    cs = 'onedark' -- navarasu/onedark registers only 'onedark'; style controls light/dark
  end

  if cs == 'ayu' and style then
    local ayu_ok, ayu = pcall(require, 'ayu')
    if ayu_ok then
      ayu.setup({ mirage = style == 'mirage' })
    end
  end

  if cs == 'fluoromachine' then
    local fm_ok, fm = pcall(require, 'fluoromachine')
    if fm_ok then
      fm.setup({ glow = true })
    end
  end

  pcall(vim.cmd.colorscheme, cs)

  -- Clear backgrounds when WezTerm opacity is < 100 so transparency shows through
  if read_opacity() < 100 then
    apply_transparency()
  end
end

return M
