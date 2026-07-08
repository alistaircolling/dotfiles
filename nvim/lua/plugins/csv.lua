-- CSV/TSV viewing: colored columns + virtual table alignment.
-- - Each column gets a distinct rainbow color
-- - Aligns columns visually without editing the file
-- - Toggle on demand with <leader>cv
-- - Tab / Shift-Tab jump between fields
return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewToggle", "CsvViewEnable", "CsvViewDisable" },
  opts = {
    parser = { comments = { "#", "//" } },
    view = {
      -- Draw column separators as borders for a real table look
      display_mode = "border",
    },
    keymaps = {
      -- Field text objects (e.g. cif to change a cell)
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      -- Move across fields/rows
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
    },
  },
  keys = {
    { "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV table view" },
  },
}
