-- Abyss — deep navy ocean; calm cyan, azure and aqua on icy blue-white.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'abyss',
  background = 'dark',
  palette = {
    bg = '#0a1626', fg = '#cfe0f0', fg_dim = '#93aecb', fg_muted = '#52708f', sel = '#1e3a5a',
    accent = '#5fc7e8', accent2 = '#6fa8e8',
    keyword = '#7fb4ff', func = '#59c9e0', string = '#7fd6b4', number = '#e0b06a',
    type = '#59d0d0', constant = '#e0b06a', operator = '#7fb4e8',
    red = '#ef7a8a', green = '#7fd6a1', yellow = '#e6c46a',
  },
  terminal = {
    '#12233a', '#ef7a8a', '#7fd6a1', '#e6c46a', '#6fa8ff', '#b79aef', '#5fd0e8', '#e2eefa',
    '#67819c', '#f28f9d', '#93ddb0', '#eacd82', '#86b6ff', '#c3aaf2', '#79d8ec', '#e4effa',
  },
})
