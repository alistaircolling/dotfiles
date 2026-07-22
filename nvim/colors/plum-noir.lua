-- Plum Noir — dark aubergine charcoal; elegant muted orchid and dusty rose.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'plum-noir',
  background = 'dark',
  palette = {
    bg = '#1a141c', fg = '#e4d9e2', fg_dim = '#b4a4b2', fg_muted = '#6f5e70', sel = '#302636',
    accent = '#c79ad0', accent2 = '#d0a0b8',
    keyword = '#c79ad0', func = '#9aa8d9', string = '#a9c9a8', number = '#d9b088',
    type = '#8fc4c0', constant = '#d9b088', operator = '#cfa0c0',
    red = '#d98a94', green = '#a3c48f', yellow = '#d9bd82',
  },
  terminal = {
    '#26202a', '#d98a94', '#a3c48f', '#d9bd82', '#9aa8d9', '#cf9ad0', '#86c0c0', '#f0e6ee',
    '#807181', '#df9da5', '#b2cda1', '#dfc896', '#aab6df', '#d7aad8', '#99caca', '#f1e8ef',
  },
})
