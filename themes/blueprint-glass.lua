-- Blueprint with semi-transparent WezTerm window; Neovim uses transparent editor (see blueprint-glass colors).
return {
  name = 'Blueprint Glass',
  wezterm = {
    window_background_opacity = 0.88,
    colors = {
      background = '#102132',
      foreground = '#b0d4d4',
      cursor_bg = '#c5f0f0',
      cursor_fg = '#102132',
      selection_bg = '#2a4a6a',
      selection_fg = '#b0d4d4',
      ansi = {
        '#102132', '#c47a7a', '#8eb8a8', '#b8c49a',
        '#5a8aaa', '#7a9eb8', '#a3c8c8', '#b0d4d4',
      },
      brights = {
        '#344a5f', '#d49494', '#a8d4c4', '#c8d4aa',
        '#6a9aba', '#94b4c8', '#c5f0f0', '#d8ecec',
      },
    },
  },
  nvim = {
    colorscheme = 'blueprint-glass',
    background = 'dark',
  },
  shell_palette = {
    '#c47a7a', '#8eb8a8', '#b8c49a', '#5a8aaa',
    '#7a9eb8', '#a3c8c8', '#b8c49a', '#c47a7a',
    '#5a8aaa', '#7a9eb8', '#b0d4d4', '#8eb8a8', '#c5f0f0', '#c47a7a',
  },
}
