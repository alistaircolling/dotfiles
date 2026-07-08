-- Blueprint phosphor — navy blueprint / CRT mint-cyan (matches themes/blueprint.lua).

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'blueprint'
vim.o.background = 'dark'

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg = '#102132'
local bg_alt = '#1a354d'
local bg_line = '#152a3d'
local bg_status = '#2a4a6a'
local fg = '#b0d4d4'
local fg_dim = '#8aa8a8'
local fg_muted = '#4a6070'
local accent = '#c5f0f0'
local mint = '#a3c8c8'
local string_c = '#8eb8a8'
local blue_mid = '#5a8aaa'
local blue_soft = '#6a8a9a'
local warn = '#b8c49a'
local err = '#c47a7a'
local sel = '#2a4a6a'
local visual = '#2a4a6a'

hi('Normal', { fg = fg, bg = bg })
hi('NormalFloat', { fg = fg, bg = bg_alt })
hi('NormalNC', { fg = fg, bg = bg })
hi('EndOfBuffer', { fg = bg, bg = bg })
hi('SignColumn', { fg = fg_muted, bg = bg })
hi('LineNr', { fg = fg_muted, bg = bg })
hi('CursorLineNr', { fg = accent, bg = bg_line, bold = true })
hi('CursorLine', { bg = bg_line })
hi('CursorColumn', { bg = bg_line })
hi('ColorColumn', { bg = bg_line })
hi('VertSplit', { fg = '#344a5f', bg = bg })
hi('WinSeparator', { fg = '#344a5f', bg = bg })
hi('Folded', { fg = fg_dim, bg = bg_alt })
hi('FoldColumn', { fg = fg_muted, bg = bg })
hi('NonText', { fg = '#344a5f' })
hi('SpecialKey', { fg = '#344a5f' })
hi('Conceal', { fg = fg_muted })
hi('MatchParen', { fg = accent, bg = sel, bold = true })
hi('Whitespace', { fg = '#344a5f' })

hi('Cursor', { fg = bg, bg = accent })
hi('lCursor', { fg = bg, bg = accent })
hi('CursorIM', { fg = bg, bg = accent })
hi('TermCursor', { fg = bg, bg = accent })
hi('TermCursorNC', { fg = bg, bg = fg_muted })

hi('Visual', { bg = visual })
hi('VisualNOS', { bg = visual })

hi('Search', { fg = bg, bg = mint, bold = true })
hi('IncSearch', { fg = bg, bg = accent, bold = true })
hi('CurSearch', { fg = bg, bg = accent, bold = true })
hi('Substitute', { fg = bg, bg = err })

hi('Pmenu', { fg = fg, bg = bg_alt })
hi('PmenuSel', { fg = bg, bg = mint, bold = true })
hi('PmenuSbar', { bg = bg_status })
hi('PmenuThumb', { bg = mint })

hi('StatusLine', { fg = fg, bg = bg_status, bold = true })
hi('StatusLineNC', { fg = fg_dim, bg = bg_alt })
hi('TabLine', { fg = fg_dim, bg = bg_alt })
hi('TabLineSel', { fg = accent, bg = bg_status, bold = true })
hi('TabLineFill', { bg = bg_alt })
hi('WinBar', { fg = fg, bg = bg, bold = true })
hi('WinBarNC', { fg = fg_dim, bg = bg })

hi('ModeMsg', { fg = mint, bold = true })
hi('MsgArea', { fg = fg })
hi('MoreMsg', { fg = accent, bold = true })
hi('Question', { fg = warn, bold = true })
hi('WarningMsg', { fg = warn, bold = true })
hi('ErrorMsg', { fg = err, bg = bg, bold = true })
hi('Title', { fg = blue_mid, bold = true })
hi('Directory', { fg = mint })

hi('DiffAdd', { fg = string_c, bg = '#0f2a24' })
hi('DiffChange', { bg = bg_line })
hi('DiffDelete', { fg = err, bg = '#2a1515' })
hi('DiffText', { fg = fg, bg = sel, bold = true })

hi('DiagnosticError', { fg = err })
hi('DiagnosticWarn', { fg = warn })
hi('DiagnosticInfo', { fg = accent })
hi('DiagnosticHint', { fg = blue_soft })
hi('DiagnosticUnderlineError', { undercurl = true, sp = err })
hi('DiagnosticUnderlineWarn', { undercurl = true, sp = warn })
hi('DiagnosticUnderlineInfo', { undercurl = true, sp = mint })
hi('DiagnosticUnderlineHint', { undercurl = true, sp = blue_soft })

hi('SpellBad', { undercurl = true, sp = err })
hi('SpellCap', { undercurl = true, sp = warn })
hi('SpellLocal', { undercurl = true, sp = mint })
hi('SpellRare', { undercurl = true, sp = blue_soft })

hi('Comment', { fg = fg_muted, italic = true })
hi('Constant', { fg = mint })
hi('String', { fg = string_c })
hi('Character', { fg = string_c })
hi('Number', { fg = blue_soft })
hi('Boolean', { fg = accent, bold = true })
hi('Float', { fg = blue_soft })
hi('Identifier', { fg = fg })
hi('Function', { fg = accent, bold = true })
hi('Statement', { fg = accent, bold = true })
hi('Conditional', { fg = accent, bold = true })
hi('Repeat', { fg = accent, bold = true })
hi('Label', { fg = blue_mid })
hi('Operator', { fg = mint })
hi('Keyword', { fg = accent, bold = true })
hi('Exception', { fg = err, bold = true })
hi('PreProc', { fg = blue_mid })
hi('Include', { fg = blue_mid })
hi('Define', { fg = blue_mid })
hi('Macro', { fg = mint })
hi('PreCondit', { fg = blue_mid })
hi('Type', { fg = mint, bold = true })
hi('StorageClass', { fg = accent, bold = true })
hi('Structure', { fg = mint })
hi('Typedef', { fg = accent })
hi('Special', { fg = warn })
hi('SpecialChar', { fg = blue_soft })
hi('Tag', { fg = blue_mid })
hi('Delimiter', { fg = fg_dim })
hi('Debug', { fg = warn })
hi('Underlined', { fg = mint, underline = true })
hi('Ignore', { fg = bg })
hi('Error', { fg = err, bold = true })
hi('Todo', { fg = warn, bg = bg_status, bold = true })

hi('@comment', { link = 'Comment' })
hi('@keyword', { link = 'Keyword' })
hi('@keyword.function', { fg = accent, bold = true })
hi('@keyword.return', { fg = accent, bold = true })
hi('@function', { fg = accent, bold = true })
hi('@function.builtin', { fg = mint, bold = true })
hi('@method', { fg = accent, bold = true })
hi('@constructor', { fg = mint })
hi('@string', { link = 'String' })
hi('@string.special', { fg = warn })
hi('@number', { link = 'Number' })
hi('@boolean', { link = 'Boolean' })
hi('@variable', { fg = fg })
hi('@variable.builtin', { fg = blue_soft, italic = true })
hi('@parameter', { fg = fg_dim })
hi('@field', { fg = mint })
hi('@property', { fg = accent })
hi('@type', { fg = mint, bold = true })
hi('@type.builtin', { fg = accent })
hi('@tag', { fg = err })
hi('@tag.attribute', { fg = blue_soft })
hi('@tag.delimiter', { fg = fg_dim })
hi('@punctuation', { fg = fg_dim })
hi('@punctuation.bracket', { fg = fg })
hi('@punctuation.delimiter', { fg = fg_dim })
hi('@operator', { link = 'Operator' })
hi('@constant', { fg = mint })
hi('@constant.builtin', { fg = accent, bold = true })
hi('@namespace', { fg = blue_mid })
hi('@text', { fg = fg })
hi('@text.strong', { fg = fg, bold = true })
hi('@text.emphasis', { fg = fg, italic = true })
hi('@text.uri', { fg = mint, underline = true })

hi('GitSignsAdd', { fg = string_c, bg = bg })
hi('GitSignsChange', { fg = warn, bg = bg })
hi('GitSignsDelete', { fg = err, bg = bg })

hi('NeoTreeNormal', { fg = fg, bg = bg })
hi('NeoTreeNormalNC', { fg = fg, bg = bg })
hi('NeoTreeCursorLine', { bg = bg_line })
hi('NeoTreeDirectoryIcon', { fg = mint })
hi('NeoTreeDirectoryName', { fg = accent, bold = true })
hi('NeoTreeFileName', { fg = fg })
hi('NeoTreeGitAdded', { fg = string_c })
hi('NeoTreeGitModified', { fg = warn })
hi('NeoTreeGitDeleted', { fg = err })
hi('NeoTreeIndentMarker', { fg = '#344a5f' })
hi('NeoTreeRootName', { fg = blue_mid, bold = true })

hi('TelescopeNormal', { fg = fg, bg = bg })
hi('TelescopeBorder', { fg = '#344a5f', bg = bg })
hi('TelescopePromptNormal', { fg = fg, bg = bg_alt })
hi('TelescopePromptBorder', { fg = mint, bg = bg_alt })
hi('TelescopePromptTitle', { fg = bg, bg = accent, bold = true })
hi('TelescopeResultsTitle', { fg = bg, bg = blue_mid, bold = true })
hi('TelescopePreviewTitle', { fg = bg, bg = bg_status, bold = true })
hi('TelescopeSelection', { bg = bg_line, bold = true })
hi('TelescopeMatching', { fg = warn, bold = true })

hi('WhichKey', { fg = accent, bold = true })
hi('WhichKeyGroup', { fg = blue_mid })
hi('WhichKeyDesc', { fg = fg })
hi('WhichKeySeparator', { fg = fg_muted })
hi('WhichKeyFloat', { bg = bg_alt })

hi('IndentBlanklineChar', { fg = '#344a5f' })
hi('IndentBlanklineContextChar', { fg = mint })
hi('IblIndent', { fg = '#344a5f' })
hi('IblScope', { fg = mint })

local term = {
  '#102132', '#c47a7a', '#8eb8a8', '#b8c49a', '#5a8aaa', '#7a9eb8', '#a3c8c8', '#b0d4d4',
  '#344a5f', '#d49494', '#a8d4c4', '#c8d4aa', '#6a9aba', '#94b4c8', '#c5f0f0', '#d8ecec',
}
for i, c in ipairs(term) do
  vim.g['terminal_color_' .. (i - 1)] = c
end
