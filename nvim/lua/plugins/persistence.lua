return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>sc", function() require("persistence").load() end, desc = "Restore Current Dir Session" },
    { "<leader>sl", function() require("persistence").select() end, desc = "Session List" },
    { "<leader>sL", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>sd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    {
      "<leader>ss",
      function()
        local name = vim.fn.input("Session name: ")
        if name ~= "" then
          require("persistence").save(name)
          vim.notify("Session saved: " .. name)
        end
      end,
      desc = "Save Named Session",
    },
    {
      "<leader>sx",
      function()
        local dir = require("persistence.config").options.dir
        local files = vim.fn.globpath(dir, "*.vim", false, true)
        if #files == 0 then
          vim.notify("No sessions found", vim.log.levels.INFO)
          return
        end
        local items = {}
        for _, f in ipairs(files) do
          table.insert(items, vim.fn.fnamemodify(f, ":t"))
        end
        vim.ui.select(items, { prompt = "Delete session:" }, function(choice)
          if choice then
            os.remove(dir .. choice)
            vim.notify("Deleted: " .. choice)
          end
        end)
      end,
      desc = "Delete Session",
    },
  },
}
