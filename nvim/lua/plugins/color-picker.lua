return {
  "uga-rosa/ccc.nvim",
  keys = {
    { "<leader>cp", "<cmd>CccPick<cr>", desc = "Color Picker" },
    { "<leader>cc", "<cmd>CccConvert<cr>", desc = "Convert Color Format" },
  },
  cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
  config = function()
    local ccc = require("ccc")
    ccc.setup({
      inputs = {
        ccc.input.hsl,
        ccc.input.rgb,
        ccc.input.cmyk,
      },
      outputs = {
        ccc.output.hex,
        ccc.output.hex_short,
        ccc.output.css_rgb,
        ccc.output.css_hsl,
      },
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    })
  end,
}
