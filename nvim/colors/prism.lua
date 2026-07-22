-- Prism — neutral dark; a balanced full-spectrum rainbow of accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'prism',
  background = 'dark',
  palette = {
    bg = '#14151c', fg = '#e2e4ee', fg_dim = '#a4a8bc', fg_muted = '#5f6478', sel = '#2a2c38',
    accent = '#7fd0ff', accent2 = '#ff9ec4',
    keyword = '#c79aff', func = '#7fb0ff', string = '#8ee089', number = '#ffb86b',
    type = '#5fd6d0', constant = '#ffcf6b', operator = '#ff9ec4',
    red = '#ff8090', green = '#8ee089', yellow = '#ffd06b',
  },
  terminal = {
    '#20222c', '#ff8090', '#8ee089', '#ffd06b', '#7fb0ff', '#d79aff', '#5fd6e0', '#eef0f8',
    '#727788', '#ff94a2', '#a0e59c', '#ffd883', '#93bdff', '#ddaaff', '#79dde5', '#eff1f8',
  },
})
