-- Use system clipboard for all yank/paste operations
vim.opt.clipboard = "unnamedplus"

-- MacBook notch compensation: when Neovim runs in a right-side WezTerm pane,
-- add a blank winbar so the first line isn't hidden under the camera cutout
local pane_id = os.getenv('WEZTERM_PANE')
if pane_id then
  vim.defer_fn(function()
    local handle = io.popen('wezterm cli list --format json 2>/dev/null')
    if not handle then return end
    local json_str = handle:read('*a')
    handle:close()
    if not json_str or json_str == '' then return end
    local ok, panes = pcall(vim.json.decode, json_str)
    if not ok or not panes then return end
    for _, p in ipairs(panes) do
      if tostring(p.pane_id) == pane_id and (p.left_col or 0) > 0 then
        vim.o.winbar = ' '
        return
      end
    end
  end, 50)
end

-- Font controls (<leader>fn / <leader>fp / <leader>fd / <leader>fs + favorites).
-- Monaspace texture healing: TUI uses WezTerm `harfbuzz_features` (calt/liga). Neovide: symlink
-- neovide/config.toml from this repo to ~/.config/neovide/config.toml ([font.features]).
require("font-cycler").setup()

-- Theme: themes/current syncs Neovim + WezTerm + shell `theme` (<leader>tn / <leader>tp / …).
require("theme-cycler").setup()

-- Option+3 → # when the terminal sends Meta+3 (WezTerm sends literal # via SendString; this helps other terminals)
vim.keymap.set({ "i", "c" }, "<M-3>", "#")

-- Copy relative file path to clipboard
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path" })
end, { desc = "Yank relative file path" })

-- Reveal current file in macOS Finder
vim.keymap.set("n", "<leader>of", function()
  local path = vim.fn.expand("%:p:h")
  vim.fn.system({ "open", path })
end, { desc = "Open current file's folder in Finder" })

-- Built-in gc/gcc require 'commentstring'; some filetypes leave it empty (e.g. prisma only
-- sets filetype via vim.filetype.add). Fill in so line/selection comment never errors.
-- Strict JSON has no comment syntax; jsonc uses //.
local commentstring_by_ft = {
  prisma = "// %s",
  jsonc = "// %s",
}
local ensure_commentstring = function()
  if vim.bo.filetype == "json" then
    return
  end
  if vim.bo.commentstring ~= "" then
    return
  end
  local ft = vim.bo.filetype
  vim.bo.commentstring = commentstring_by_ft[ft] or "# %s"
end
local _commentstring_au = vim.api.nvim_create_augroup("dotfiles_commentstring", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = _commentstring_au,
  callback = ensure_commentstring,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  group = _commentstring_au,
  callback = function()
    local msg = "Strict JSON has no comments; use jsonc if your tools allow //."
    local nope = function()
      vim.notify(msg, vim.log.levels.WARN)
    end
    vim.keymap.set("n", "<leader>;", nope, { buffer = true, desc = "JSON: no comments" })
    vim.keymap.set("x", "<leader>;", nope, { buffer = true, desc = "JSON: no comments" })
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = _commentstring_au,
  callback = function()
    if vim.bo.filetype == "" then
      ensure_commentstring()
    end
  end,
})

-- Toggle comment (built-in gc/gcc; same key comments and uncomments)
vim.keymap.set("n", "<leader>;", "gcc", { desc = "Toggle comment (line)", remap = true })
vim.keymap.set("x", "<leader>;", "gc", { desc = "Toggle comment (selection)", remap = true })

-- Window navigation with leader + hjkl
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to below pane" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to above pane" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move to right pane" })

-- Window splits
vim.keymap.set("n", "<leader>vs", "<cmd>vsplit<cr>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>hs", "<cmd>split<cr>", { desc = "Horizontal split" })

-- Toggle current window to 75% width / back to equal splits
local _win_expanded = false
vim.keymap.set("n", "<leader>wm", function()
  if _win_expanded then
    vim.cmd("wincmd =")
  else
    local target = math.floor(vim.o.columns * 0.75)
    vim.api.nvim_win_set_width(0, target)
  end
  _win_expanded = not _win_expanded
end, { desc = "Toggle window maximize (75%)" })

-- Case-insensitive search by default; case-sensitive if pattern has uppercase
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Filetype detection for Prisma schema files
vim.filetype.add({ extension = { prisma = "prisma" } })

-- Highlight the current cursor line
vim.opt.cursorline = true

-- Option A: subtle dark pink tint (syntax colors unchanged)
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   callback = function()
--     vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3d1f2e" })
--   end,
-- })
-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3d1f2e" })

-- Option B: hot pink solid background (kept for reference)
-- local function apply_hot_pink_cursorline()
--   vim.api.nvim_set_hl(0, "CursorLine", { bg = "#ff69b4" })
--   vim.api.nvim_set_hl(0, "CursorLineFold", { bg = "#ff69b4", fg = "#1a1a1a" })
--   vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "#ff69b4", fg = "#1a1a1a", bold = true })
--   vim.api.nvim_set_hl(0, "CursorLineSign", { bg = "#ff69b4" })
-- end
-- vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_hot_pink_cursorline })
-- apply_hot_pink_cursorline()

-- Option C: hot pink underline outline (transparent bg, syntax colors untouched)
-- local function apply_hot_pink_outline()
--   vim.api.nvim_set_hl(0, "CursorLine", { underline = true, sp = "#ff69b4" })
--   vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff69b4", bold = true })
--   vim.api.nvim_set_hl(0, "CursorLineSign", {})
--   vim.api.nvim_set_hl(0, "CursorLineFold", {})
-- end
-- vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_hot_pink_outline })
-- apply_hot_pink_outline()

-- Option D: accent cursor line – color only on empty space (before text & after EOL).
-- Text itself keeps the normal editor background so syntax colors stay readable.
-- Change ACCENT_COLOR to re-theme the cursor line everywhere.
local ACCENT_COLOR = '#5b8bd4'  -- dark blue
local accent_ns = vim.api.nvim_create_namespace('cursorline_accent')
-- Resolve the editor's effective background color so we can "erase" the accent
-- behind actual text characters while keeping it on leading whitespace & after EOL.
local function get_editor_bg()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  if normal.bg then
    return string.format('#%06x', normal.bg)
  end
  -- Transparent background – use the active dotfiles theme's terminal background,
  -- since that's what actually shows through (catppuccin's palette is wrong for
  -- light themes like solarized-light and painted a dark band over cursor-line text)
  local loader_ok, loader = pcall(dofile, '/Users/Shared/dotfiles/themes/loader.lua')
  if loader_ok and loader then
    local theme = loader.load_theme(loader.read_current())
    local bg = theme and theme.wezterm and theme.wezterm.colors and theme.wezterm.colors.background
    if bg then return bg end
  end
  return vim.o.background == 'light' and '#fdf6e3' or '#1e1e2e'
end

local ACCENT_BLEND = 50  -- 0 = opaque, 100 = invisible

local function apply_accent()
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = ACCENT_COLOR, blend = ACCENT_BLEND })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = ACCENT_COLOR, bold = true, blend = ACCENT_BLEND })
  vim.api.nvim_set_hl(0, 'CursorLineSign', { bg = ACCENT_COLOR, blend = ACCENT_BLEND })
  vim.api.nvim_set_hl(0, 'CursorLineFold', { bg = ACCENT_COLOR, blend = ACCENT_BLEND })
  -- Invert cursor/selection colors on light backgrounds
  -- - white cursor is invisible on light themes
  local light = vim.o.background == 'light'
  if light then
    vim.api.nvim_set_hl(0, 'Cursor', { bg = '#3c3836', fg = '#fbf1c7' })
  else
    vim.api.nvim_set_hl(0, 'Cursor', { bg = '#ffffff', fg = '#1e1e2e' })
  end
  vim.api.nvim_set_hl(0, 'iCursor', { bg = '#f0c674', fg = '#1e1e2e' })
  vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = ACCENT_COLOR, blend = ACCENT_BLEND })
  -- Make completion popup text readable (black on accent)
  vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#000000', bg = ACCENT_COLOR })
  if light then
    vim.api.nvim_set_hl(0, 'PmenuSel', { fg = '#fbf1c7', bg = '#3c3836', bold = true })
  else
    vim.api.nvim_set_hl(0, 'PmenuSel', { fg = '#000000', bg = '#ffffff', bold = true })
  end
  -- Highlight group that restores the normal bg over text characters
  vim.api.nvim_set_hl(0, 'CursorLineClear', { bg = get_editor_bg() })
end

apply_accent()
vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_accent })

vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-iCursor,r-cr-o:hor20-Cursor'

local last_buf, last_row = -1, -1

local function update_cursorline()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  if buf == last_buf and row == last_row then return end

  if last_buf >= 0 and vim.api.nvim_buf_is_valid(last_buf) then
    vim.api.nvim_buf_clear_namespace(last_buf, accent_ns, 0, -1)
  end
  last_buf, last_row = buf, row

  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  if not line then return end

  local line_len = #line
  if line_len == 0 then return end

  -- For tree/sidebar buffers, cover the entire line (icons & connectors aren't
  -- meaningful whitespace). For regular buffers, preserve accent on leading indent.
  local ft = vim.bo[buf].filetype
  local start_col
  if ft == 'neo-tree' or ft == 'NvimTree' then
    start_col = 0
  else
    local first_nonws = line:find('%S')
    if not first_nonws then return end -- blank lines stay fully accented
    start_col = first_nonws - 1
  end

  -- Extend the clear region by 1 char before text for a visual gap
  start_col = math.max(0, start_col - 1)

  -- Overlay text (plus 1-char left padding) with the normal bg.
  -- Only bg is set, so syntax/icon foreground colors show through untouched.
  pcall(vim.api.nvim_buf_set_extmark, buf, accent_ns, row, start_col, {
    end_col = line_len,
    hl_group = 'CursorLineClear',
    priority = 150,
  })

end

-- BufEnter/WinEnter ensure it fires when switching to Neo-tree or other sidebars
vim.api.nvim_create_autocmd(
  { 'CursorMoved', 'CursorMovedI', 'BufEnter', 'WinEnter' },
  {
    callback = function()
      -- Reset tracking on window/buffer switch so the extmark is always reapplied
      if vim.api.nvim_get_current_buf() ~= last_buf then
        last_buf, last_row = -1, -1
      end
      update_cursorline()
    end,
  }
)
