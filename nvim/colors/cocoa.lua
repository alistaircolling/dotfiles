-- Cocoa — warm espresso brown; caramel, sage and honey on latte cream.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'cocoa',
  background = 'dark',
  palette = {
    bg = '#1e1712', fg = '#ecdcc9', fg_dim = '#c2a88c', fg_muted = '#856a52', sel = '#38291f',
    accent = '#d9a86a', accent2 = '#c9b48f',
    keyword = '#d98a7a', func = '#c9a86b', string = '#a9c48a', number = '#e0b878',
    type = '#8fc4b0', constant = '#e0b878', operator = '#cbb088',
    red = '#e08a7a', green = '#a9c47f', yellow = '#e0be70',
  },
  terminal = {
    '#2a2019', '#e08a7a', '#a9c47f', '#e0be70', '#90b4c4', '#cf9fb0', '#86c4b4', '#f2e6d6',
    '#947c67', '#e59d8f', '#b7cd93', '#e5c887', '#a2c0cd', '#d7aebd', '#99cdc0', '#f3e8d8',
  },
})
