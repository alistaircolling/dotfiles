return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
  },
  opts = function()
    return {
      window = {
        -- base columns/6, then 56% wider
        width = math.floor(vim.o.columns / 6 * 1.56),
        auto_expand_width = false,
      },
      async_directory_scan = "always",
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    }
  end,
  config = function(_, opts)
    require("neo-tree").setup(opts)

    local aug = vim.api.nvim_create_augroup("NeoTreePersistSidebarWidth", { clear = true })
    vim.api.nvim_create_autocmd("WinResized", {
      group = aug,
      callback = function(ev)
        local winid = tonumber(ev.match)
        if not winid or not vim.api.nvim_win_is_valid(winid) then
          return
        end
        local buf = vim.api.nvim_win_get_buf(winid)
        if vim.bo[buf].filetype ~= "neo-tree" then
          return
        end
        local manager = require("neo-tree.sources.manager")
        local state = manager.get_state_for_window(winid)
        if not state then
          return
        end
        local pos = state.current_position
        if pos ~= "left" and pos ~= "right" then
          return
        end
        state.window.width = vim.api.nvim_win_get_width(winid)
      end,
    })
  end,
}
