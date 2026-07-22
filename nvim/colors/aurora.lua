-- Aurora — dark slate-blue night; aurora green, teal and violet.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'aurora',
  background = 'dark',
  palette = {
    bg = '#0d1720', fg = '#d6e6e0', fg_dim = '#97b4b0', fg_muted = '#566f70', sel = '#1e3640',
    accent = '#6fe0b0', accent2 = '#9a8fe8',
    keyword = '#9a8fe8', func = '#5fc9e8', string = '#86e0a1', number = '#e0c47a',
    type = '#6fd6d0', constant = '#e0c47a', operator = '#7fd6c4',
    red = '#ef8a8a', green = '#6fe0a1', yellow = '#e6cf7a',
  },
  terminal = {
    '#16232e', '#ef8a8a', '#6fe0a1', '#e6cf7a', '#6fa8e8', '#b79ae8', '#5fd6d0', '#e6f2ec',
    '#6a8081', '#f29d9d', '#86e5b0', '#ead78f', '#86b6ec', '#c3aaec', '#79ddd8', '#e8f3ed',
  },
})
