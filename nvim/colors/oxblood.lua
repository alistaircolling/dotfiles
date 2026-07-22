-- Oxblood — deep wine-burgundy; rose, gold and violet on rose-cream text.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'oxblood',
  background = 'dark',
  palette = {
    bg = '#24101a', fg = '#ecd0d8', fg_dim = '#c49aa6', fg_muted = '#8a5f6c', sel = '#3d1b2a',
    accent = '#e8899f', accent2 = '#d98aa0',
    keyword = '#e07a9a', func = '#c9a0e0', string = '#d8a86a', number = '#e39a7a',
    type = '#b98ad9', constant = '#e0b060', operator = '#cf9aae',
    red = '#e0708a', green = '#a8c47a', yellow = '#e0b060',
  },
  terminal = {
    '#331623', '#e0708a', '#a8c47a', '#e0b060', '#a89ae0', '#d98ac9', '#7fc4b8', '#f2dce2',
    '#98727e', '#e5879d', '#b6cd8f', '#e5bd79', '#b6aae5', '#df9dd2', '#93cdc3', '#f3dee4',
  },
})
