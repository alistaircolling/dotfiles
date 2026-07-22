-- Synthwave — retro outrun purple; hot-pink and electric-cyan neon.
-- Built from the shared palette-driven builder (nvim/lua/theme_builder.lua).

require('theme_builder').build({
  name = 'synthwave',
  background = 'dark',
  palette = {
    bg = '#191029', fg = '#f5e6ff', fg_dim = '#c9a8e0', fg_muted = '#7a5f9a', sel = '#331e4f',
    accent = '#ff5fd2', accent2 = '#4fe0e8',
    keyword = '#ff5fd2', func = '#4fe0e8', string = '#a6f05a', number = '#ffb84f',
    type = '#59d6ff', constant = '#ffb84f', operator = '#ff8ad0',
    red = '#ff5a7a', green = '#7af0a0', yellow = '#ffd44f',
  },
  terminal = {
    '#241638', '#ff5a7a', '#7af0a0', '#ffd44f', '#59a8ff', '#ff5fd2', '#4fe0e8', '#ffe0ff',
    '#8a72a6', '#ff748f', '#8ff2af', '#ffdb6b', '#74b6ff', '#ff79d9', '#6be5ec', '#ffe2ff',
  },
})
