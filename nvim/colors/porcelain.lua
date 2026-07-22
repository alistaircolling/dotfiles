-- Porcelain — cool porcelain white; clean blue, teal and violet on slate ink.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'porcelain',
  background = 'light',
  palette = {
    bg = '#eef1f5', fg = '#33383f', fg_dim = '#59616b', fg_muted = '#8a929c', sel = '#d7deea',
    accent = '#2f7db0', accent2 = '#2f8f8a',
    keyword = '#7a4fb0', func = '#2f6db0', string = '#3f8f5a', number = '#b06a2f',
    type = '#2f8f8a', constant = '#a04f8a', operator = '#2f8f8a',
    red = '#c04a4a', green = '#3f8f4a', yellow = '#96721f',
  },
  terminal = {
    '#33383f', '#c04a4a', '#3f8f4a', '#96721f', '#2f6db0', '#a04f9a', '#2f8f8a', '#f6f8fb',
    '#798089', '#a94141', '#377e41', '#84641b', '#29609b', '#8d4688', '#297e79', '#f6f8fb',
  },
})
