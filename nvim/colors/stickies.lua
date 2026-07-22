-- stickies.lua — macOS Stickies post-it note colorscheme
-- Black on yellow, minimal syntax highlighting

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'stickies'
vim.o.background = 'light'

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Post-it note palette
local bg        = '#FDFD96'  -- classic post-it yellow
local bg_dark   = '#F5F07A'  -- slightly darker yellow (cursorline)
local bg_darker = '#E8D44D'  -- statusline / accents
local bg_gutter = '#F8F48B'  -- gutter background
local fg        = '#000000'  -- black text
local fg_dim    = '#5C4A00'  -- dark amber (secondary text)
local fg_muted  = '#8B7D52'  -- warm brown (comments, line numbers)
local sel       = '#F0D060'  -- selection highlight
local visual    = '#EDCA4E'  -- visual mode
local error_red = '#A52A2A'  -- brown-red for errors
local warn      = '#8B6914'  -- dark goldenrod for warnings
local hint      = '#6B5B00'  -- hints
local border    = '#D4C84A'  -- window borders, separators

-- Editor basics
hi('Normal',       { fg = fg, bg = bg })
hi('NormalFloat',  { fg = fg, bg = bg_dark })
hi('NormalNC',     { fg = fg, bg = bg })
hi('EndOfBuffer',  { fg = bg, bg = bg })
hi('SignColumn',   { fg = fg_muted, bg = bg })
hi('LineNr',       { fg = fg_muted, bg = bg })
hi('CursorLineNr', { fg = fg, bg = bg_dark, bold = true })
hi('CursorLine',  { bg = bg_dark })
hi('CursorColumn', { bg = bg_dark })
hi('ColorColumn',  { bg = bg_dark })
hi('VertSplit',    { fg = border, bg = bg })
hi('WinSeparator', { fg = border, bg = bg })
hi('Folded',       { fg = fg_dim, bg = bg_dark })
hi('FoldColumn',   { fg = fg_muted, bg = bg })
hi('NonText',      { fg = border })
hi('SpecialKey',   { fg = border })
hi('Conceal',      { fg = fg_dim })
hi('MatchParen',   { fg = fg, bg = sel, bold = true })
hi('Whitespace',   { fg = border })

-- Cursor
hi('Cursor',       { fg = bg, bg = fg })
hi('iCursor',      { fg = bg, bg = fg_dim })
hi('lCursor',      { fg = bg, bg = fg })
hi('CursorIM',     { fg = bg, bg = fg })
hi('TermCursor',   { fg = bg, bg = fg })
hi('TermCursorNC', { fg = bg, bg = fg_muted })

-- Selection / Visual
hi('Visual',       { bg = visual })
hi('VisualNOS',    { bg = visual })

-- Search
hi('Search',       { fg = fg, bg = sel, bold = true })
hi('IncSearch',    { fg = bg, bg = fg, bold = true })
hi('CurSearch',    { fg = bg, bg = fg_dim, bold = true })
hi('Substitute',   { fg = bg, bg = fg_dim })

-- Popup / Completion menu
hi('Pmenu',        { fg = fg, bg = bg_dark })
hi('PmenuSel',     { fg = bg, bg = fg, bold = true })
hi('PmenuSbar',    { bg = bg_darker })
hi('PmenuThumb',   { bg = fg_muted })

-- Status / Tab / Win bars
hi('StatusLine',   { fg = fg, bg = bg_darker, bold = true })
hi('StatusLineNC', { fg = fg_dim, bg = bg_dark })
hi('TabLine',      { fg = fg_dim, bg = bg_dark })
hi('TabLineSel',   { fg = fg, bg = bg_darker, bold = true })
hi('TabLineFill',  { bg = bg_dark })
hi('WinBar',       { fg = fg, bg = bg, bold = true })
hi('WinBarNC',     { fg = fg_dim, bg = bg })

-- Messages
hi('ModeMsg',      { fg = fg, bold = true })
hi('MsgArea',      { fg = fg })
hi('MoreMsg',      { fg = fg_dim, bold = true })
hi('Question',     { fg = fg_dim, bold = true })
hi('WarningMsg',   { fg = warn, bold = true })
hi('ErrorMsg',     { fg = error_red, bg = bg, bold = true })
hi('Title',        { fg = fg, bold = true })
hi('Directory',    { fg = fg_dim })

-- Diff
hi('DiffAdd',      { fg = '#2E5A1E', bg = '#D4E8B0' })
hi('DiffChange',   { bg = '#F5EDB0' })
hi('DiffDelete',   { fg = error_red, bg = '#F5D0A9' })
hi('DiffText',     { fg = fg, bg = sel, bold = true })

-- Diagnostics
hi('DiagnosticError',          { fg = error_red })
hi('DiagnosticWarn',           { fg = warn })
hi('DiagnosticInfo',           { fg = fg_dim })
hi('DiagnosticHint',           { fg = hint })
hi('DiagnosticUnderlineError', { undercurl = true, sp = error_red })
hi('DiagnosticUnderlineWarn',  { undercurl = true, sp = warn })
hi('DiagnosticUnderlineInfo',  { undercurl = true, sp = fg_dim })
hi('DiagnosticUnderlineHint',  { undercurl = true, sp = hint })

-- Spell
hi('SpellBad',     { undercurl = true, sp = error_red })
hi('SpellCap',     { undercurl = true, sp = warn })
hi('SpellLocal',   { undercurl = true, sp = hint })
hi('SpellRare',    { undercurl = true, sp = fg_dim })

-- Syntax — kept minimal, like writing on a real sticky note
hi('Comment',      { fg = fg_muted, italic = true })
hi('Constant',     { fg = fg })
hi('String',       { fg = fg_dim })
hi('Character',    { fg = fg_dim })
hi('Number',       { fg = fg })
hi('Boolean',      { fg = fg, bold = true })
hi('Float',        { fg = fg })
hi('Identifier',   { fg = fg })
hi('Function',     { fg = fg, bold = true })
hi('Statement',    { fg = fg, bold = true })
hi('Conditional',  { fg = fg, bold = true })
hi('Repeat',       { fg = fg, bold = true })
hi('Label',        { fg = fg, bold = true })
hi('Operator',     { fg = fg })
hi('Keyword',      { fg = fg, bold = true })
hi('Exception',    { fg = fg, bold = true })
hi('PreProc',      { fg = fg_dim })
hi('Include',      { fg = fg_dim })
hi('Define',       { fg = fg_dim })
hi('Macro',        { fg = fg_dim })
hi('PreCondit',    { fg = fg_dim })
hi('Type',         { fg = fg })
hi('StorageClass', { fg = fg, bold = true })
hi('Structure',    { fg = fg })
hi('Typedef',      { fg = fg })
hi('Special',      { fg = fg_dim })
hi('SpecialChar',  { fg = fg_dim })
hi('Tag',          { fg = fg })
hi('Delimiter',    { fg = fg })
hi('Debug',        { fg = fg_dim })
hi('Underlined',   { fg = fg, underline = true })
hi('Ignore',       { fg = bg })
hi('Error',        { fg = error_red, bold = true })
hi('Todo',         { fg = fg, bg = bg_darker, bold = true })

-- Treesitter
hi('@comment',             { link = 'Comment' })
hi('@keyword',             { link = 'Keyword' })
hi('@keyword.function',    { fg = fg, bold = true })
hi('@keyword.return',      { fg = fg, bold = true })
hi('@function',            { fg = fg, bold = true })
hi('@function.builtin',    { fg = fg, bold = true })
hi('@method',              { fg = fg, bold = true })
hi('@constructor',         { fg = fg })
hi('@string',              { link = 'String' })
hi('@number',              { link = 'Number' })
hi('@boolean',             { link = 'Boolean' })
hi('@variable',            { fg = fg })
hi('@variable.builtin',    { fg = fg, italic = true })
hi('@parameter',           { fg = fg })
hi('@field',               { fg = fg })
hi('@property',            { fg = fg })
hi('@type',                { fg = fg })
hi('@type.builtin',        { fg = fg })
hi('@tag',                 { fg = fg })
hi('@tag.attribute',       { fg = fg })
hi('@tag.delimiter',       { fg = fg_dim })
hi('@punctuation',         { fg = fg })
hi('@punctuation.bracket', { fg = fg })
hi('@punctuation.delimiter', { fg = fg })
hi('@operator',            { fg = fg })
hi('@constant',            { fg = fg })
hi('@constant.builtin',    { fg = fg, bold = true })
hi('@namespace',           { fg = fg })
hi('@text',                { fg = fg })
hi('@text.strong',         { fg = fg_dim, bold = true })
hi('@text.emphasis',       { fg = fg, italic = true })
hi('@text.uri',            { fg = fg_dim, underline = true })

-- Git signs
hi('GitSignsAdd',          { fg = '#5A7A2E', bg = bg })
hi('GitSignsChange',       { fg = fg_muted, bg = bg })
hi('GitSignsDelete',       { fg = error_red, bg = bg })

-- Neo-tree
hi('NeoTreeNormal',        { fg = fg, bg = bg })
hi('NeoTreeNormalNC',      { fg = fg, bg = bg })
hi('NeoTreeCursorLine',    { bg = bg_dark })
hi('NeoTreeDirectoryIcon', { fg = fg_dim })
hi('NeoTreeDirectoryName', { fg = fg, bold = true })
hi('NeoTreeFileName',      { fg = fg })
hi('NeoTreeGitAdded',      { fg = '#5A7A2E' })
hi('NeoTreeGitModified',   { fg = fg_muted })
hi('NeoTreeGitDeleted',    { fg = error_red })
hi('NeoTreeIndentMarker',  { fg = border })
hi('NeoTreeRootName',      { fg = fg, bold = true })

-- Telescope
hi('TelescopeNormal',        { fg = fg, bg = bg })
hi('TelescopeBorder',        { fg = border, bg = bg })
hi('TelescopePromptNormal',  { fg = fg, bg = bg_dark })
hi('TelescopePromptBorder',  { fg = border, bg = bg_dark })
hi('TelescopePromptTitle',   { fg = fg, bg = bg_darker, bold = true })
hi('TelescopeResultsTitle',  { fg = fg, bg = bg_darker, bold = true })
hi('TelescopePreviewTitle',  { fg = fg, bg = bg_darker, bold = true })
hi('TelescopeSelection',     { bg = bg_dark, bold = true })
hi('TelescopeMatching',      { fg = fg, bold = true, underline = true })

-- Which-key
hi('WhichKey',              { fg = fg, bold = true })
hi('WhichKeyGroup',         { fg = fg_dim })
hi('WhichKeyDesc',          { fg = fg })
hi('WhichKeySeparator',     { fg = fg_muted })
hi('WhichKeyFloat',         { bg = bg_dark })

-- Indent / misc
hi('IndentBlanklineChar',          { fg = border })
hi('IndentBlanklineContextChar',   { fg = fg_muted })
hi('IblIndent',                    { fg = border })
hi('IblScope',                     { fg = fg_muted })
