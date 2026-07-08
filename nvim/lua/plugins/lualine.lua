return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto", -- Automatically matches your active colorscheme
        globalstatus = true, -- Use a single statusline for all windows
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            -- Custom component to display the current working directory
            function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            end,
            icon = "", -- Folder icon
            color = { gui = "bold" },
          },
          {
            "filename",
            path = 1, -- 1 = Relative path to the file
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
