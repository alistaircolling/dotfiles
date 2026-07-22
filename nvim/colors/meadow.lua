-- Meadow — pale green paper; fresh grass and ocean accents on forest ink.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'meadow',
  background = 'light',
  palette = {
    bg = '#eef3e2', fg = '#33402c', fg_dim = '#5c6b4f', fg_muted = '#8a9678', sel = '#d3e2bf',
    accent = '#4f9d5b', accent2 = '#3f8f7a',
    keyword = '#b0632f', func = '#2f7d9d', string = '#5a9a3a', number = '#b58a2f',
    type = '#3f8f7a', constant = '#8a5fb0', operator = '#3f8f7a',
    red = '#b24a3a', green = '#4f8f36', yellow = '#9a7a1f',
  },
  terminal = {
    '#33402c', '#b24a3a', '#4f8f36', '#9a7a1f', '#2f6d9d', '#9a4f9a', '#2f8f7a', '#f2f6ea',
    '#79846a', '#9d4133', '#467e30', '#886b1b', '#29608a', '#884688', '#297e6b', '#f2f6ea',
  },
})
