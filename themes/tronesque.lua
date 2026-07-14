-- WezTerm + Neovim + shell palette. Colors converted from Tronesque iTerm2 theme
-- (GPL-3+): https://github.com/aurelienbottazini/tronesque — repo archived; no nvim port upstream.
return {
  name = 'Tronesque',
  wezterm = {
    colors = {
      background = '#102132',
      foreground = '#cbf9ea',
      cursor_bg = '#caeffe',
      cursor_fg = '#102132',
      selection_bg = '#264e78',
      selection_fg = '#cbf9ea',
      ansi = {
        '#2c3f52', '#f85242', '#62f6c0', '#ffff4d',
        '#aecdda', '#8593cf', '#caeffe', '#cbf9ea',
      },
      brights = {
        '#4d6a86', '#f0a554', '#9bf1d5', '#1a426f',
        '#235fa0', '#a1b1fa', '#fffed3', '#ecfffe',
      },
    },
  },
  nvim = {
    colorscheme = 'tronesque',
    background = 'dark',
  },
  shell_palette = {
    '#f85242', '#62f6c0', '#ffff4d', '#235fa0',
    '#a1b1fa', '#caeffe', '#f0a554', '#8593cf',
    '#9bf1d5', '#aecdda', '#ecfffe', '#62f6c0', '#fffed3', '#f85242',
  },
}
