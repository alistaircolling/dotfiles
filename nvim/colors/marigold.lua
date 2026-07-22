-- Marigold — dark warm brown; golden marigold and honey accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'marigold',
  background = 'dark',
  palette = {
    bg = '#1c1810', fg = '#f2e4c4', fg_dim = '#ccb488', fg_muted = '#8a7250', sel = '#38301c',
    accent = '#f0b429', accent2 = '#ffd479',
    keyword = '#f0a552', func = '#e8c04f', string = '#c3cf6a', number = '#f5b942',
    type = '#a9c98f', constant = '#ffcf6b', operator = '#e8c86a',
    red = '#e88a5a', green = '#b8c96a', yellow = '#f5c942',
  },
  terminal = {
    '#292214', '#e88a5a', '#b8c96a', '#f5c942', '#8fb4a8', '#d9a878', '#8fc99f', '#f7ecd0',
    '#988365', '#ec9d74', '#c3d282', '#f7d260', '#a1c0b6', '#dfb68e', '#a1d2ae', '#f7edd3',
  },
})
