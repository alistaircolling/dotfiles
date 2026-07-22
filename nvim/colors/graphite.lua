-- Graphite — refined neutral slate-grey; understated steel and sage accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'graphite',
  background = 'dark',
  palette = {
    bg = '#1a1d21', fg = '#d6dade', fg_dim = '#a2a8b0', fg_muted = '#626a74', sel = '#2c3138',
    accent = '#7fb8c9', accent2 = '#9aa8b8',
    keyword = '#a3a0d9', func = '#7fb0c9', string = '#9ac49a', number = '#d9b57f',
    type = '#7fc4c0', constant = '#d9b57f', operator = '#9aa8b8',
    red = '#d98a8a', green = '#9ac48a', yellow = '#d9c07f',
  },
  terminal = {
    '#24282d', '#d98a8a', '#9ac48a', '#d9c07f', '#8fb0d0', '#b79ac9', '#7fc0c9', '#e6eaee',
    '#757c85', '#df9d9d', '#aacd9d', '#dfca93', '#a1bdd8', '#c3aad2', '#93cad2', '#e8ebef',
  },
})
