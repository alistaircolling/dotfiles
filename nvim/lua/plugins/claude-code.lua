return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", mode = { "n", "v" }, desc = "Toggle Claude" },
    { "qq", "<cmd>ClaudeCode<cr>", mode = "t", desc = "Toggle Claude" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
