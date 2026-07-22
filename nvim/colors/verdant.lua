-- Verdant — deep pine-green forest; soft mint text with warm woodland accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'verdant',
  background = 'dark',
  palette = {
    bg = '#0d1f17', fg = '#d3e6d0', fg_dim = '#9db8a0', fg_muted = '#5f7d68', sel = '#274536',
    accent = '#7fd6a1', accent2 = '#a3d9c9',
    keyword = '#f4a988', func = '#8fd0e8', string = '#b8d98a', number = '#e8c07d',
    type = '#7fd6a1', constant = '#e8c07d', operator = '#a3d9c9',
    red = '#ef8080', green = '#93d977', yellow = '#e8c565',
  },
  terminal = {
    '#14261c', '#ef8080', '#93d977', '#e8c565', '#8fd0e8', '#d9a5e0', '#79d6b4', '#e6f0e2',
    '#728d7a', '#f29494', '#a4df8d', '#ecce7e', '#a1d8ec', '#dfb3e5', '#8eddc0', '#e8f1e4',
  },
})
