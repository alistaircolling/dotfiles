return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Git diff (all changes)" },
    { "<leader>gdm", function()
      -- Auto-detect default branch (main or master)
      local result = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
      local branch = "main"
      if #result > 0 and result[1] ~= "" then
        branch = result[1]:match("refs/remotes/origin/(.+)") or "main"
      else
        -- Fallback: check if origin/main exists, otherwise try master
        if vim.fn.system("git rev-parse --verify origin/main 2>/dev/null"):find("^%x") then
          branch = "main"
        else
          branch = "master"
        end
      end
      vim.cmd("DiffviewOpen origin/" .. branch .. "...HEAD")
    end, desc = "Diff against main/master" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
  },
  opts = {
    view = {
      default = { layout = "diff2_horizontal" },
    },
    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
    },
  },
}
