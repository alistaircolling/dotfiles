return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules/", "%.git/", "%.venv/", "site%-packages/", "__pycache__/" },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = {
            "fd", "--type", "f", "--hidden", "--no-ignore-vcs",
            "--exclude", ".git",
            "--exclude", "node_modules",
            "--exclude", ".next",
            "--exclude", ".venv",
            "--exclude", "__pycache__",
          },
        },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fF", function() require("telescope.builtin").find_files({ no_ignore = true, hidden = true }) end, desc = "Find All Files (incl. ignored)" },
    },
  },
}
