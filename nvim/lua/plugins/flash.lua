return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Search modes: you can configure how flash searches
    -- Default settings are great; jump uses character-based search
    modes = {
      search = { enabled = true }, -- integrates with / and ?
      char = {
        enabled = true,
        jump_labels = true,
        -- Labels shown near targets; priority order
        labels = "asdfghjklqwertyuiopzxcvbnm",
      },
    },
  },
  keys = {
    {
      "<leader>j",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Jump to character(s)",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash treesitter",
    },
  },
}
