return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "eslint",
        "tailwindcss",
        "cssls",
        "html",
        "jsonls",
      },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config('*', { capabilities = capabilities })

      -- ESLint 9 defaults to flat config and fails with "Could not find config
      -- file" in projects that still use a legacy .eslintrc.* file. Detect which
      -- style the project root uses and tell the server, so both kinds work.
      local eslint_before_init = vim.lsp.config.eslint.before_init
      local flat_config_names = {
        'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs',
        'eslint.config.ts', 'eslint.config.mts', 'eslint.config.cts',
      }
      vim.lsp.config('eslint', {
        before_init = function(params, config)
          if eslint_before_init then
            eslint_before_init(params, config)
          end
          local root = config.root_dir
          if not root then return end
          local has_flat = false
          for _, name in ipairs(flat_config_names) do
            if vim.uv.fs_stat(root .. '/' .. name) then
              has_flat = true
              break
            end
          end
          config.settings = config.settings or {}
          -- ESLint >= 8.57 only honours the top-level setting; the
          -- experimental one covers 8.21-8.56.
          config.settings.useFlatConfig = has_flat
          config.settings.experimental = config.settings.experimental or {}
          config.settings.experimental.useFlatConfig = has_flat
        end,
      })
      vim.lsp.enable({ "ts_ls", "eslint", "tailwindcss", "cssls", "html", "jsonls" })

      -- Keymaps (set once when any LSP attaches)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover info")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("gD", vim.lsp.buf.type_definition, "Type definition")
          map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })
    end,
  },
}
