-- Lagoon — dark tropical teal; turquoise, seafoam and coral accents.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'lagoon',
  background = 'dark',
  palette = {
    bg = '#082420', fg = '#cfeae2', fg_dim = '#94c0b6', fg_muted = '#52807a', sel = '#16443c',
    accent = '#4fd6c4', accent2 = '#6fd0a8',
    keyword = '#f79ac0', func = '#59c9e8', string = '#a8dd7f', number = '#ffc46a',
    type = '#4fd6c4', constant = '#ffc46a', operator = '#6fd0b8',
    red = '#ff8a8a', green = '#86d97f', yellow = '#ffc861',
  },
  terminal = {
    '#0f302a', '#ff8a8a', '#86d97f', '#ffc861', '#59b4e8', '#e69ad0', '#4fd6c4', '#e0f2ec',
    '#678f8a', '#ff9d9d', '#99df93', '#ffd17a', '#74c0ec', '#eaaad8', '#6bddcd', '#e2f3ed',
  },
})
