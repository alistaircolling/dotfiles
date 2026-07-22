-- Ember — dark warm coal with red undertone; fiery orange, coral and gold.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'ember',
  background = 'dark',
  palette = {
    bg = '#1f1310', fg = '#f0d6c4', fg_dim = '#c39a86', fg_muted = '#8a5f4d', sel = '#3d241c',
    accent = '#ff8c5a', accent2 = '#ffb08a',
    keyword = '#ff6f61', func = '#ffc15e', string = '#d9a066', number = '#ff9d5c',
    type = '#f0a37a', constant = '#ffc15e', operator = '#ffb08a',
    red = '#ff6a5a', green = '#9fce7e', yellow = '#ffc15e',
  },
  terminal = {
    '#2a1a14', '#ff6a5a', '#9fce7e', '#ffc15e', '#8fa9c9', '#e69ac0', '#7fc9b4', '#f5e2d4',
    '#987262', '#ff8274', '#aed693', '#ffcb78', '#a1b7d2', '#eaaaca', '#93d2c0', '#f6e4d7',
  },
})
