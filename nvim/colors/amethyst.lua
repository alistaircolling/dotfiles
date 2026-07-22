-- Amethyst — deep purple jewel; orchid, periwinkle, mint and amber.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'amethyst',
  background = 'dark',
  palette = {
    bg = '#1c1230', fg = '#e6dcf5', fg_dim = '#b8a8d6', fg_muted = '#74608f', sel = '#33224f',
    accent = '#c79aff', accent2 = '#e08ad0',
    keyword = '#e08ad0', func = '#9a9dff', string = '#8fd6b4', number = '#ffb86b',
    type = '#6fd0e8', constant = '#ffb86b', operator = '#c79aff',
    red = '#ff8098', green = '#8fd6a1', yellow = '#ffcf6b',
  },
  terminal = {
    '#281a40', '#ff8098', '#8fd6a1', '#ffcf6b', '#8fa8ff', '#d99aff', '#6fd6e0', '#f0e8fb',
    '#85739c', '#ff94a8', '#a1ddb0', '#ffd783', '#a1b6ff', '#dfaaff', '#86dde5', '#f1e9fb',
  },
})
