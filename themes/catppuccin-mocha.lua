return {
  name = 'Catppuccin Mocha',
  wezterm = {
    background_image = '/Users/Shared/dotfiles/themes/assets/bg.jpg',
    background_brightness = 0.1,
    background_scrim = 0.65,  -- dark overlay over bg.jpg so text stays readable
    colors = {
      background = '#1e1e2e',
      foreground = '#eef1fb', -- brightened from #cdd6f4 for readability over bg.jpg
      cursor_bg = '#f5e0dc',
      cursor_fg = '#1e1e2e',
      selection_bg = '#585b70',
      selection_fg = '#cdd6f4',
      ansi = {
        '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af',
        '#89b4fa', '#cba6f7', '#94e2d5', '#bac2de',
      },
      brights = {
        '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af',
        '#89b4fa', '#cba6f7', '#94e2d5', '#a6adc8',
      },
    },
  },
  nvim = {
    colorscheme = 'catppuccin-mocha',
    background = 'dark',
  },
  shell_palette = {
    '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa',
    '#cba6f7', '#94e2d5', '#fab387', '#f5c2e7',
    '#74c7ec', '#b4befe', '#f2cdcd', '#eba0ac',
    '#89dceb', '#f5e0dc',
  },
}
