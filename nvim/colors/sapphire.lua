-- Sapphire — royal indigo-blue jewel tones; periwinkle, violet and cyan.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'sapphire',
  background = 'dark',
  palette = {
    bg = '#131636', fg = '#dcdcf5', fg_dim = '#a6a8d6', fg_muted = '#6668a0', sel = '#2a2f5e',
    accent = '#8f9dff', accent2 = '#9d8fe8',
    keyword = '#b39aff', func = '#7fb0ff', string = '#86d9c0', number = '#f0b070',
    type = '#6fc9e8', constant = '#f0b070', operator = '#9d8fe8',
    red = '#f0808f', green = '#86d99a', yellow = '#ecc46a',
  },
  terminal = {
    '#1c2048', '#f0808f', '#86d99a', '#ecc46a', '#7fa8ff', '#c79aef', '#6fd0e8', '#eaeafb',
    '#787aab', '#f294a1', '#99dfaa', '#efcd82', '#93b6ff', '#d0aaf2', '#86d8ec', '#ebebfb',
  },
})
