return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>qq", "<cmd>confirm qa<cr>", desc = "Quit" },
  },
  opts = {
    triggers = {
      { "<auto>", mode = "nso" }, -- exclude x (visual) to fix vt. vf" etc.
    },
    layout = {
      width = { min = 20 },
      spacing = 3,
    },
    win = {
      no_overlap = true,
      padding = { 1, 2 },
    },
  },
}
