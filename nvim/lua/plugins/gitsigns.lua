return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 200,
    },
  },
  keys = {
    { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle git blame" },
    { "<leader>gB", "<cmd>Gitsigns blame<cr>", desc = "Full file blame" },
  },
}
