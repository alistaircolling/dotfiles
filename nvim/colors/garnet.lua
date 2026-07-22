-- Garnet — saturated blood-red; bold garnet-pink, amber and gold accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'garnet',
  background = 'dark',
  palette = {
    bg = '#2a0d12', fg = '#f2d2cc', fg_dim = '#cf9a94', fg_muted = '#965a58', sel = '#4a1620',
    accent = '#ff6b7a', accent2 = '#ff9a86',
    keyword = '#ff7a8f', func = '#ffb26b', string = '#ffc27a', number = '#ff9a6b',
    type = '#f08a9a', constant = '#ffc27a', operator = '#ff9a86',
    red = '#ff5f6b', green = '#b8d17a', yellow = '#ffc060',
  },
  terminal = {
    '#3d1218', '#ff5f6b', '#b8d17a', '#ffc060', '#9aa9e0', '#ff8ad0', '#7fd0c0', '#ffe0da',
    '#a36e6c', '#ff7983', '#c3d88f', '#ffca79', '#aab7e5', '#ff9dd8', '#93d8ca', '#ffe2dc',
  },
})
