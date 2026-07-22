-- Moss — dark olive-khaki green; earthy sage and lime accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'moss',
  background = 'dark',
  palette = {
    bg = '#1a1f12', fg = '#dcdcc0', fg_dim = '#a8ab88', fg_muted = '#6d7154', sel = '#34381f',
    accent = '#c3d16b', accent2 = '#d0c98a',
    keyword = '#d98f6a', func = '#a9c46b', string = '#c3d16b', number = '#e0b95f',
    type = '#8fc99a', constant = '#e0b95f', operator = '#bcb06a',
    red = '#d97b6a', green = '#a9c46b', yellow = '#e0b95f',
  },
  terminal = {
    '#23281a', '#d97b6a', '#a9c46b', '#e0b95f', '#7fb59c', '#c99abf', '#8fc99a', '#e8e8cc',
    '#7f8269', '#df9082', '#b7cd83', '#e5c479', '#93c1ac', '#d2aac9', '#a1d2aa', '#e9e9cf',
  },
})
