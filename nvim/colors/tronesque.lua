-- Tronesque — dark Tron-inspired colors (matches themes/tronesque.lua).
-- Palette from the Tronesque iTerm2 theme (GPL-3+):
-- https://github.com/aurelienbottazini/tronesque
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'tronesque',
  background = 'dark',
  transparent = true,
  blend = 18,
  palette = {
    bg = '#102132', bg_alt = '#1a354d', bg_line = '#152a3d', bg_status = '#1a426f',
    fg = '#cbf9ea', fg_dim = '#aecdda', fg_muted = '#8593cf',
    border = '#235fa0', nontext = '#235fa0', sel = '#264e78', visual = '#1a426f',
    accent = '#caeffe', accent2 = '#62f6c0', cursor = '#caeffe',
    keyword = '#235fa0', statement = '#235fa0', func = '#caeffe', boolean = '#ffff4d',
    type = '#62f6c0', constant = '#a1b1fa', operator = '#ffff4d', macro = '#62f6c0',
    string = '#62f6c0', number = '#f0a554',
    label = '#a1b1fa', preproc = '#a1b1fa', tag = '#a1b1fa', title = '#a1b1fa',
    property = '#caeffe',
    red = '#f85242', green = '#62f6c0', yellow = '#ffff4d', info = '#caeffe', hint = '#a1b1fa',
    special = '#ffff4d', strong = '#e8b840',
    search = '#ffff4d', incsearch = '#f0a554', cursearch = '#62f6c0', matchparen = '#ffff4d',
    git_add = '#62f6c0', git_change = '#ffff4d', git_delete = '#f85242',
    diff_add_bg = '#0a2a22', diff_del_bg = '#2a1010', diff_change_bg = '#152a3d',
  },
  terminal = {
    '#2c3f52', '#f85242', '#62f6c0', '#ffff4d', '#aecdda', '#8593cf', '#caeffe', '#cbf9ea',
    '#4d6a86', '#f0a554', '#9bf1d5', '#1a426f', '#235fa0', '#a1b1fa', '#fffed3', '#ecfffe',
  },
  overrides = {
    Character = { fg = '#caeffe' },
    StorageClass = { fg = '#caeffe', bold = true },
    Typedef = { fg = '#caeffe' },
    Debug = { fg = '#f0a554' },
    WarningMsg = { fg = '#f0a554', bold = true },
    DiagnosticWarn = { fg = '#f0a554' },
    DiagnosticUnderlineWarn = { undercurl = true, sp = '#f0a554' },
    SpellCap = { undercurl = true, sp = '#f0a554' },
    ['@keyword.function'] = { fg = '#caeffe', bold = true },
    ['@field'] = { fg = '#62f6c0' },
    ['@type.builtin'] = { fg = '#caeffe' },
    ['@tag'] = { fg = '#f85242' },
    ['@constant.builtin'] = { fg = '#f0a554', bold = true },
    TelescopePreviewTitle = { fg = '#102132', bg = '#235fa0', bold = true },
  },
})
