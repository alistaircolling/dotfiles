-- Blueprint phosphor — navy blueprint / CRT mint-cyan (matches themes/blueprint.lua).
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'blueprint',
  background = 'dark',
  palette = {
    bg = '#102132', bg_alt = '#1a354d', bg_line = '#152a3d', bg_status = '#2a4a6a',
    fg = '#b0d4d4', fg_dim = '#8aa8a8', fg_muted = '#4a6070',
    border = '#344a5f', nontext = '#344a5f', sel = '#2a4a6a',
    accent = '#c5f0f0', accent2 = '#a3c8c8', cursor = '#c5f0f0',
    keyword = '#c5f0f0', func = '#c5f0f0', statement = '#c5f0f0', boolean = '#c5f0f0',
    type = '#a3c8c8', constant = '#a3c8c8', operator = '#a3c8c8', macro = '#a3c8c8',
    string = '#8eb8a8', number = '#6a8a9a',
    label = '#5a8aaa', preproc = '#5a8aaa', tag = '#5a8aaa', title = '#5a8aaa',
    property = '#c5f0f0',
    red = '#c47a7a', green = '#8eb8a8', yellow = '#b8c49a', info = '#c5f0f0', hint = '#6a8a9a',
    special = '#b8c49a', strong = '#e8b840', search = '#a3c8c8', matchparen = '#c5f0f0',
    git_add = '#8eb8a8', git_change = '#b8c49a', git_delete = '#c47a7a',
    diff_add_bg = '#0f2a24', diff_del_bg = '#2a1515', diff_change_bg = '#152a3d',
  },
  terminal = {
    '#102132', '#c47a7a', '#8eb8a8', '#b8c49a', '#5a8aaa', '#7a9eb8', '#a3c8c8', '#b0d4d4',
    '#344a5f', '#d49494', '#a8d4c4', '#c8d4aa', '#6a9aba', '#94b4c8', '#c5f0f0', '#d8ecec',
  },
  overrides = {
    Typedef = { fg = '#c5f0f0' },
    ['@field'] = { fg = '#a3c8c8' },
    ['@type.builtin'] = { fg = '#c5f0f0' },
    ['@tag'] = { fg = '#c47a7a' },
    TelescopeMatching = { fg = '#b8c49a', bold = true },
  },
})
