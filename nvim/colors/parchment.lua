-- Parchment — warm sepia paper; rust, olive and faded-blue ink.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'parchment',
  background = 'light',
  palette = {
    bg = '#f3ead6', fg = '#4a3f30', fg_dim = '#6f6350', fg_muted = '#9a8c72', sel = '#e2d3b4',
    accent = '#b06a2f', accent2 = '#7a6a3f',
    keyword = '#a44f3a', func = '#4a6d8f', string = '#5f7a3a', number = '#a0692f',
    type = '#3f7a6f', constant = '#8a5a2f', operator = '#7a6a3f',
    red = '#a84a38', green = '#5c7a34', yellow = '#8a6a1f',
  },
  terminal = {
    '#4a3f30', '#a84a38', '#5c7a34', '#8a6a1f', '#40638f', '#8a4f7a', '#3f7a6f', '#f8f1e0',
    '#887b64', '#944131', '#516b2e', '#795d1b', '#38577e', '#79466b', '#376b62', '#f8f1e0',
  },
})
