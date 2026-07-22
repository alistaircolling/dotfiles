-- Neon — near-black; maximal electric palette of every neon hue.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'neon',
  background = 'dark',
  palette = {
    bg = '#0c0d12', fg = '#e6ebf2', fg_dim = '#a0a8bc', fg_muted = '#5c6478', sel = '#23252f',
    accent = '#39f0d0', accent2 = '#ff4fa3',
    keyword = '#ff4fa3', func = '#39d6ff', string = '#7bf05a', number = '#ffcf3a',
    type = '#39f0d0', constant = '#ff8a3a', operator = '#b06bff',
    red = '#ff4f5a', green = '#57f05a', yellow = '#ffd23a',
  },
  terminal = {
    '#171821', '#ff4f5a', '#57f05a', '#ffd23a', '#39a8ff', '#ff4fd2', '#39f0e0', '#f2f5fa',
    '#707788', '#ff6b74', '#72f274', '#ffd95a', '#59b6ff', '#ff6bd9', '#59f2e5', '#f3f6fa',
  },
})
