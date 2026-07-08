return {
  -- Catppuccin (default)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      integrations = { treesitter = true, neo_tree = true },
    },
  },
  -- TokyoNight
  { "folke/tokyonight.nvim", lazy = true },
  -- Gruvbox
  { "ellisonleao/gruvbox.nvim", lazy = true },
  -- Nord
  { "shaunsingh/nord.nvim", lazy = true },
  -- Dracula
  { "Mofiqul/dracula.nvim", lazy = true },
  -- Everforest
  { "neanias/everforest-nvim", lazy = true },
  -- Kanagawa
  { "rebelot/kanagawa.nvim", lazy = true },
  -- Rose Pine
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  -- OneDark / OneLight
  { "navarasu/onedark.nvim", lazy = true },
  -- Nightfox family (nightfox, carbonfox, nordfox, terafox, dayfox, dawnfox)
  { "EdenEast/nightfox.nvim", lazy = true },
  -- Solarized Osaka
  { "craftzdog/solarized-osaka.nvim", lazy = true },
  -- Material
  { "marko-cerovac/material.nvim", lazy = true },
  -- Night Owl
  { "oxfist/night-owl.nvim", lazy = true },
  -- Moonfly
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
  -- Nightfly
  { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true },
  -- Ayu
  { "Shatur/neovim-ayu", lazy = true },
  -- Melange
  { "savq/melange-nvim", lazy = true },
  -- GitHub themes
  { "projekt0n/github-nvim-theme", lazy = true },
  -- Cyberdream
  { "scottmckendry/cyberdream.nvim", lazy = true },
  -- Horizon
  { "akinsho/horizon.nvim", lazy = true },
  -- Oxocarbon
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },
  -- Fluoromachine
  { "maxmx03/fluoromachine.nvim", lazy = true },
  -- Poimandres
  { "olivercederborg/poimandres.nvim", lazy = true },
}
