-- Tronesque — dark Tron-inspired colors for Neovim.
-- Palette from Tronesque iTerm2 theme (GPL-3+):
-- https://github.com/aurelienbottazini/tronesque/blob/master/themes/tronesque.itermcolors

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'tronesque'
vim.o.background = 'dark'

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg = '#102132'
local bg_alt = '#1a354d'
local bg_line = '#152a3d'
local bg_status = '#1a426f'
local fg = '#cbf9ea'
local fg_dim = '#aecdda'
local fg_muted = '#8593cf'
local cyan = '#62f6c0'
local cyan_bright = '#caeffe'
local red = '#f85242'
local orange = '#f0a554'
local yellow = '#ffff4d'
local amber = '#e8b840'
local blue = '#235fa0'
local violet = '#a1b1fa'
local sel = '#264e78'
local visual = '#1a426f'

-- No Normal bg so WezTerm window transparency shows through (same idea as blueprint-glass).
hi('Normal', { fg = fg })
hi('NormalFloat', { fg = fg, bg = bg_alt, blend = 18 })
hi('NormalNC', { fg = fg })
hi('EndOfBuffer', { fg = bg })
hi('SignColumn', { fg = fg_muted })
hi('LineNr', { fg = fg_muted })
hi('CursorLineNr', { fg = cyan_bright, bg = bg_line, blend = 22, bold = true })
hi('CursorLine', { bg = bg_line, blend = 22 })
hi('CursorColumn', { bg = bg_line, blend = 22 })
hi('ColorColumn', { bg = bg_line, blend = 22 })
hi('VertSplit', { fg = blue })
hi('WinSeparator', { fg = blue })
hi('Folded', { fg = fg_dim, bg = bg_alt, blend = 18 })
hi('FoldColumn', { fg = fg_muted })
hi('NonText', { fg = blue })
hi('SpecialKey', { fg = blue })
hi('Conceal', { fg = fg_muted })
hi('MatchParen', { fg = yellow, bg = sel, blend = 12, bold = true })
hi('Whitespace', { fg = blue })

hi('Cursor', { fg = bg, bg = cyan_bright })
hi('lCursor', { fg = bg, bg = cyan_bright })
hi('CursorIM', { fg = bg, bg = cyan_bright })
hi('TermCursor', { fg = bg, bg = cyan_bright })
hi('TermCursorNC', { fg = bg, bg = fg_muted })

hi('Visual', { bg = visual, blend = 18 })
hi('VisualNOS', { bg = visual, blend = 18 })

hi('Search', { fg = bg, bg = yellow, bold = true })
hi('IncSearch', { fg = bg, bg = orange, bold = true })
hi('CurSearch', { fg = bg, bg = cyan, bold = true })
hi('Substitute', { fg = bg, bg = red })

hi('Pmenu', { fg = fg, bg = bg_alt, blend = 18 })
hi('PmenuSel', { fg = bg, bg = cyan, blend = 10, bold = true })
hi('PmenuSbar', { bg = bg_status })
hi('PmenuThumb', { bg = cyan })

hi('StatusLine', { fg = fg, bg = bg_status, bold = true })
hi('StatusLineNC', { fg = fg_dim, bg = bg_alt })
hi('TabLine', { fg = fg_dim, bg = bg_alt })
hi('TabLineSel', { fg = cyan_bright, bg = bg_status, bold = true })
hi('TabLineFill', { bg = bg_alt })
hi('WinBar', { fg = fg, bold = true })
hi('WinBarNC', { fg = fg_dim })

hi('ModeMsg', { fg = cyan, bold = true })
hi('MsgArea', { fg = fg })
hi('MoreMsg', { fg = cyan_bright, bold = true })
hi('Question', { fg = yellow, bold = true })
hi('WarningMsg', { fg = orange, bold = true })
hi('ErrorMsg', { fg = red, bold = true })
hi('Title', { fg = violet, bold = true })
hi('Directory', { fg = cyan })

hi('DiffAdd', { fg = cyan, bg = '#0a2a22' })
hi('DiffChange', { bg = bg_line })
hi('DiffDelete', { fg = red, bg = '#2a1010' })
hi('DiffText', { fg = fg, bg = sel, bold = true })

hi('DiagnosticError', { fg = red })
hi('DiagnosticWarn', { fg = orange })
hi('DiagnosticInfo', { fg = cyan_bright })
hi('DiagnosticHint', { fg = violet })
hi('DiagnosticUnderlineError', { undercurl = true, sp = red })
hi('DiagnosticUnderlineWarn', { undercurl = true, sp = orange })
hi('DiagnosticUnderlineInfo', { undercurl = true, sp = cyan })
hi('DiagnosticUnderlineHint', { undercurl = true, sp = violet })

hi('SpellBad', { undercurl = true, sp = red })
hi('SpellCap', { undercurl = true, sp = orange })
hi('SpellLocal', { undercurl = true, sp = cyan })
hi('SpellRare', { undercurl = true, sp = violet })

hi('Comment', { fg = fg_muted, italic = true })
hi('Constant', { fg = violet })
hi('String', { fg = cyan })
hi('Character', { fg = cyan_bright })
hi('Number', { fg = orange })
hi('Boolean', { fg = yellow, bold = true })
hi('Float', { fg = orange })
hi('Identifier', { fg = fg })
hi('Function', { fg = cyan_bright, bold = true })
hi('Statement', { fg = blue, bold = true })
hi('Conditional', { fg = blue, bold = true })
hi('Repeat', { fg = blue, bold = true })
hi('Label', { fg = violet })
hi('Operator', { fg = yellow })
hi('Keyword', { fg = blue, bold = true })
hi('Exception', { fg = red, bold = true })
hi('PreProc', { fg = violet })
hi('Include', { fg = violet })
hi('Define', { fg = violet })
hi('Macro', { fg = cyan })
hi('PreCondit', { fg = violet })
hi('Type', { fg = cyan, bold = true })
hi('StorageClass', { fg = cyan_bright, bold = true })
hi('Structure', { fg = cyan })
hi('Typedef', { fg = cyan_bright })
hi('Special', { fg = yellow })
hi('SpecialChar', { fg = orange })
hi('Tag', { fg = violet })
hi('Delimiter', { fg = fg_dim })
hi('Debug', { fg = orange })
hi('Underlined', { fg = cyan, underline = true })
hi('Ignore', { fg = bg })
hi('Error', { fg = red, bold = true })
hi('Todo', { fg = yellow, bg = bg_status, bold = true })

hi('@comment', { link = 'Comment' })
hi('@keyword', { link = 'Keyword' })
hi('@keyword.function', { fg = cyan_bright, bold = true })
hi('@keyword.return', { fg = blue, bold = true })
hi('@function', { fg = cyan_bright, bold = true })
hi('@function.builtin', { fg = cyan, bold = true })
hi('@method', { fg = cyan_bright, bold = true })
hi('@constructor', { fg = cyan })
hi('@string', { link = 'String' })
hi('@string.special', { fg = yellow })
hi('@number', { link = 'Number' })
hi('@boolean', { link = 'Boolean' })
hi('@variable', { fg = fg })
hi('@variable.builtin', { fg = violet, italic = true })
hi('@parameter', { fg = fg_dim })
hi('@field', { fg = cyan })
hi('@property', { fg = cyan_bright })
hi('@type', { fg = cyan, bold = true })
hi('@type.builtin', { fg = cyan_bright })
hi('@tag', { fg = red })
hi('@tag.attribute', { fg = orange })
hi('@tag.delimiter', { fg = fg_dim })
hi('@punctuation', { fg = fg_dim })
hi('@punctuation.bracket', { fg = fg })
hi('@punctuation.delimiter', { fg = fg_dim })
hi('@operator', { link = 'Operator' })
hi('@constant', { fg = violet })
hi('@constant.builtin', { fg = orange, bold = true })
hi('@namespace', { fg = violet })
hi('@text', { fg = fg })
hi('@text.strong', { fg = amber, bold = true })
hi('@text.emphasis', { fg = fg, italic = true })
hi('@text.uri', { fg = cyan, underline = true })

hi('GitSignsAdd', { fg = cyan })
hi('GitSignsChange', { fg = yellow })
hi('GitSignsDelete', { fg = red })

hi('NeoTreeNormal', { fg = fg })
hi('NeoTreeNormalNC', { fg = fg })
hi('NeoTreeCursorLine', { bg = bg_line, blend = 22 })
hi('NeoTreeDirectoryIcon', { fg = cyan })
hi('NeoTreeDirectoryName', { fg = cyan_bright, bold = true })
hi('NeoTreeFileName', { fg = fg })
hi('NeoTreeGitAdded', { fg = cyan })
hi('NeoTreeGitModified', { fg = yellow })
hi('NeoTreeGitDeleted', { fg = red })
hi('NeoTreeIndentMarker', { fg = blue })
hi('NeoTreeRootName', { fg = violet, bold = true })

hi('TelescopeNormal', { fg = fg })
hi('TelescopeBorder', { fg = blue })
hi('TelescopePromptNormal', { fg = fg, bg = bg_alt, blend = 18 })
hi('TelescopePromptBorder', { fg = cyan, bg = bg_alt, blend = 18 })
hi('TelescopePromptTitle', { fg = bg, bg = cyan_bright, bold = true })
hi('TelescopeResultsTitle', { fg = bg, bg = violet, bold = true })
hi('TelescopePreviewTitle', { fg = bg, bg = blue, bold = true })
hi('TelescopeSelection', { bg = bg_line, blend = 20, bold = true })
hi('TelescopeMatching', { fg = yellow, bold = true })

hi('WhichKey', { fg = cyan_bright, bold = true })
hi('WhichKeyGroup', { fg = violet })
hi('WhichKeyDesc', { fg = fg })
hi('WhichKeySeparator', { fg = fg_muted })
hi('WhichKeyFloat', { bg = bg_alt, blend = 18 })

hi('IndentBlanklineChar', { fg = blue })
hi('IndentBlanklineContextChar', { fg = cyan })
hi('IblIndent', { fg = blue })
hi('IblScope', { fg = cyan })

-- Terminal (Claude Code / :term) — ANSI 0–15
local term = {
  '#2c3f52', '#f85242', '#62f6c0', '#ffff4d', '#aecdda', '#8593cf', '#caeffe', '#cbf9ea',
  '#4d6a86', '#f0a554', '#9bf1d5', '#1a426f', '#235fa0', '#a1b1fa', '#fffed3', '#ecfffe',
}
for i, c in ipairs(term) do
  vim.g['terminal_color_' .. (i - 1)] = c
end
