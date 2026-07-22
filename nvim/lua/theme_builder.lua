-- theme_builder.lua — shared Neovim colorscheme builder for dotfiles themes.
--
-- One place that turns a compact semantic palette into the full set of
-- highlight groups (editor + syntax + treesitter + common plugins) plus the
-- terminal ANSI palette. Each nvim/colors/<key>.lua is a thin file that calls
-- M.build{ ... }.
--
-- Design:
-- - Pass a small palette; anything you omit is derived (see `resolve`), so a
--   new theme usually sets ~12 colors and looks complete.
-- - `transparent = true` drops window backgrounds (glass themes over a
--   semi-transparent terminal) and blends floats — like blueprint-glass.
-- - `mono = true` collapses syntax to a near-monochrome look (foreground with
--   bold accents) — like the Stickies note theme.
-- - `overrides = { Group = {...} }` is applied last for anything bespoke.

local M = {}

-- --- hex helpers ----------------------------------------------------------
local function clamp(n) return math.max(0, math.min(255, n)) end

local function hex2rgb(h)
  h = h:gsub('#', '')
  return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

local function rgb2hex(r, g, b)
  return string.format('#%02x%02x%02x', clamp(r + 0.5), clamp(g + 0.5), clamp(b + 0.5))
end

-- Mix `t` (0..1) of c2 into c1.
local function blend(c1, c2, t)
  local r1, g1, b1 = hex2rgb(c1)
  local r2, g2, b2 = hex2rgb(c2)
  return rgb2hex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end

M.blend = blend

-- --- palette resolution ---------------------------------------------------
-- Fill in every role the builder needs, deriving sensible values from the few
-- the theme actually provided. Direction-agnostic: shades are blended toward
-- `fg`/`bg`, so the same rules work for dark and light themes.
local function resolve(p)
  local c = {}
  for k, v in pairs(p) do c[k] = v end

  local function d(key, fallback) if c[key] == nil then c[key] = fallback end end

  -- Foreground ramp
  d('fg_dim', blend(c.fg, c.bg, 0.30))
  d('fg_muted', blend(c.fg, c.bg, 0.52))
  d('border', blend(c.fg, c.bg, 0.72))
  d('nontext', c.border)

  -- Background ramp (tinted toward fg so it reads on both dark and light)
  d('bg_alt', blend(c.bg, c.fg, 0.08))
  d('bg_line', blend(c.bg, c.fg, 0.05))
  d('bg_status', blend(c.bg, c.fg, 0.14))

  -- Accents
  d('accent2', c.accent)
  d('sel', blend(c.bg, c.accent, 0.28))
  d('visual', c.sel)
  d('cursor', c.accent)

  -- Semantic (red/green/yellow are expected; the rest fall back)
  d('info', c.accent)
  d('hint', c.accent2)

  -- Syntax roles
  d('keyword', c.accent)
  d('func', c.accent)
  d('statement', c.keyword)
  d('type', c.accent2)
  d('string', c.green)
  d('number', c.accent2)
  d('boolean', c.number)
  d('constant', c.accent2)
  d('operator', c.accent2)
  d('label', c.accent2)
  d('preproc', c.accent2)
  d('macro', c.accent)
  d('tag', c.preproc)
  d('special', c.yellow)
  d('property', c.accent)
  d('variable', c.fg)
  d('parameter', c.fg_dim)
  d('title', c.accent2)
  d('strong', c.yellow)

  -- Search / matches
  d('search', c.yellow)
  d('incsearch', c.accent)
  d('cursearch', c.accent)
  d('matchparen', c.accent)

  -- Diff backgrounds
  d('diff_add_bg', blend(c.bg, c.green, 0.16))
  d('diff_del_bg', blend(c.bg, c.red, 0.16))
  d('diff_change_bg', c.bg_line)

  -- Git
  d('git_add', c.green)
  d('git_change', c.yellow)
  d('git_delete', c.red)

  return c
end

-- --- build ----------------------------------------------------------------
-- spec = {
--   name = 'verdant', background = 'dark'|'light',
--   transparent = false, blend = 18, mono = false,
--   palette = { ... }, terminal = { 16 hex } | false, overrides = { Group = {} },
-- }
function M.build(spec)
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = spec.name
  vim.o.background = spec.background or 'dark'

  local c = resolve(spec.palette)
  local glass = spec.transparent == true
  local blendv = spec.blend or 18
  local mono = spec.mono == true

  local set = vim.api.nvim_set_hl
  local function hi(group, opts) set(0, group, opts) end

  -- Editor background: opaque themes paint bg; glass themes leave it clear.
  -- (Cannot use `glass and nil or c.bg` — the `and nil` short-circuits to c.bg.)
  local editor_bg
  if not glass then editor_bg = c.bg end
  local function fbg(fg, bg, extra)  -- float/panel bg with glass blend
    local o = { fg = fg }
    if glass then o.bg = bg; o.blend = blendv else o.bg = bg end
    if extra then for k, v in pairs(extra) do o[k] = v end end
    return o
  end

  -- Editor basics --------------------------------------------------------
  hi('Normal',       { fg = c.fg, bg = editor_bg })
  hi('NormalNC',     { fg = c.fg, bg = editor_bg })
  hi('NormalFloat',  fbg(c.fg, c.bg_alt))
  hi('FloatBorder',  fbg(c.border, c.bg_alt))
  hi('FloatTitle',   fbg(c.title, c.bg_alt, { bold = true }))
  hi('EndOfBuffer',  { fg = editor_bg or c.bg, bg = editor_bg })
  hi('SignColumn',   { fg = c.fg_muted, bg = editor_bg })
  hi('LineNr',       { fg = c.fg_muted, bg = editor_bg })
  hi('CursorLineNr', glass and { fg = c.accent, bg = c.bg_line, blend = 22, bold = true }
                            or { fg = c.accent, bg = c.bg_line, bold = true })
  hi('CursorLine',   glass and { bg = c.bg_line, blend = 22 } or { bg = c.bg_line })
  hi('CursorColumn', glass and { bg = c.bg_line, blend = 22 } or { bg = c.bg_line })
  hi('ColorColumn',  glass and { bg = c.bg_line, blend = 22 } or { bg = c.bg_line })
  hi('VertSplit',    { fg = c.border, bg = editor_bg })
  hi('WinSeparator', { fg = c.border, bg = editor_bg })
  hi('Folded',       fbg(c.fg_dim, c.bg_alt))
  hi('FoldColumn',   { fg = c.fg_muted, bg = editor_bg })
  hi('NonText',      { fg = c.nontext })
  hi('SpecialKey',   { fg = c.nontext })
  hi('Conceal',      { fg = c.fg_muted })
  hi('MatchParen',   glass and { fg = c.matchparen, bg = c.sel, blend = 12, bold = true }
                            or { fg = c.matchparen, bg = c.sel, bold = true })
  hi('Whitespace',   { fg = c.nontext })
  hi('WinBar',       { fg = c.fg, bg = editor_bg, bold = true })
  hi('WinBarNC',     { fg = c.fg_dim, bg = editor_bg })

  -- Cursor ---------------------------------------------------------------
  hi('Cursor',       { fg = c.bg, bg = c.cursor })
  hi('lCursor',      { fg = c.bg, bg = c.cursor })
  hi('CursorIM',     { fg = c.bg, bg = c.cursor })
  hi('TermCursor',   { fg = c.bg, bg = c.cursor })
  hi('TermCursorNC', { fg = c.bg, bg = c.fg_muted })

  -- Selection ------------------------------------------------------------
  hi('Visual',    glass and { bg = c.visual, blend = 18 } or { bg = c.visual })
  hi('VisualNOS', glass and { bg = c.visual, blend = 18 } or { bg = c.visual })

  -- Search ---------------------------------------------------------------
  hi('Search',     { fg = c.bg, bg = c.search, bold = true })
  hi('IncSearch',  { fg = c.bg, bg = c.incsearch, bold = true })
  hi('CurSearch',  { fg = c.bg, bg = c.cursearch, bold = true })
  hi('Substitute', { fg = c.bg, bg = c.red })

  -- Popup menu -----------------------------------------------------------
  hi('Pmenu',      fbg(c.fg, c.bg_alt))
  hi('PmenuSel',   glass and { fg = c.bg, bg = c.accent2, blend = 10, bold = true }
                          or { fg = c.bg, bg = c.accent2, bold = true })
  hi('PmenuSbar',  { bg = c.bg_status })
  hi('PmenuThumb', { bg = c.accent2 })

  -- Status / tab / bars --------------------------------------------------
  hi('StatusLine',   { fg = c.fg, bg = c.bg_status, bold = true })
  hi('StatusLineNC', { fg = c.fg_dim, bg = c.bg_alt })
  hi('TabLine',      { fg = c.fg_dim, bg = c.bg_alt })
  hi('TabLineSel',   { fg = c.accent, bg = c.bg_status, bold = true })
  hi('TabLineFill',  { bg = c.bg_alt })

  -- Messages -------------------------------------------------------------
  hi('ModeMsg',    { fg = c.accent2, bold = true })
  hi('MsgArea',    { fg = c.fg })
  hi('MoreMsg',    { fg = c.accent, bold = true })
  hi('Question',   { fg = c.yellow, bold = true })
  hi('WarningMsg', { fg = c.yellow, bold = true })
  hi('ErrorMsg',   { fg = c.red, bg = editor_bg, bold = true })
  hi('Title',      { fg = c.title, bold = true })
  hi('Directory',  { fg = c.accent2 })

  -- Diff -----------------------------------------------------------------
  hi('DiffAdd',    { fg = c.green, bg = c.diff_add_bg })
  hi('DiffChange', { bg = c.diff_change_bg })
  hi('DiffDelete', { fg = c.red, bg = c.diff_del_bg })
  hi('DiffText',   { fg = c.fg, bg = c.sel, bold = true })

  -- Diagnostics ----------------------------------------------------------
  hi('DiagnosticError', { fg = c.red })
  hi('DiagnosticWarn',  { fg = c.yellow })
  hi('DiagnosticInfo',  { fg = c.info })
  hi('DiagnosticHint',  { fg = c.hint })
  hi('DiagnosticOk',    { fg = c.green })
  hi('DiagnosticUnderlineError', { undercurl = true, sp = c.red })
  hi('DiagnosticUnderlineWarn',  { undercurl = true, sp = c.yellow })
  hi('DiagnosticUnderlineInfo',  { undercurl = true, sp = c.accent2 })
  hi('DiagnosticUnderlineHint',  { undercurl = true, sp = c.hint })

  -- Spell ----------------------------------------------------------------
  hi('SpellBad',   { undercurl = true, sp = c.red })
  hi('SpellCap',   { undercurl = true, sp = c.yellow })
  hi('SpellLocal', { undercurl = true, sp = c.accent2 })
  hi('SpellRare',  { undercurl = true, sp = c.hint })

  -- Syntax ---------------------------------------------------------------
  if mono then
    -- Near-monochrome: emphasis via weight/dim, not hue (Stickies-style).
    local strong = { fg = c.fg, bold = true }
    local dim = { fg = c.fg_dim }
    hi('Comment',      { fg = c.fg_muted, italic = true })
    hi('Constant',     { fg = c.fg })
    hi('String',       dim); hi('Character', dim)
    hi('Number',       { fg = c.fg }); hi('Float', { fg = c.fg })
    hi('Boolean',      strong)
    hi('Identifier',   { fg = c.fg })
    hi('Function',     strong); hi('Statement', strong)
    hi('Conditional',  strong); hi('Repeat', strong); hi('Label', strong)
    hi('Operator',     { fg = c.fg }); hi('Keyword', strong); hi('Exception', strong)
    hi('PreProc',      dim); hi('Include', dim); hi('Define', dim)
    hi('Macro',        dim); hi('PreCondit', dim)
    hi('Type',         { fg = c.fg }); hi('StorageClass', strong)
    hi('Structure',    { fg = c.fg }); hi('Typedef', { fg = c.fg })
    hi('Special',      dim); hi('SpecialChar', dim)
    hi('Tag',          { fg = c.fg }); hi('Delimiter', { fg = c.fg })
    hi('Debug',        dim); hi('Underlined', { fg = c.fg, underline = true })
    hi('Ignore',       { fg = c.bg })
    hi('Error',        { fg = c.red, bold = true })
    hi('Todo',         { fg = c.fg, bg = c.bg_status, bold = true })
  else
    hi('Comment',      { fg = c.fg_muted, italic = true })
    hi('Constant',     { fg = c.constant })
    hi('String',       { fg = c.string })
    hi('Character',    { fg = c.string })
    hi('Number',       { fg = c.number })
    hi('Boolean',      { fg = c.boolean, bold = true })
    hi('Float',        { fg = c.number })
    hi('Identifier',   { fg = c.variable })
    hi('Function',     { fg = c.func, bold = true })
    hi('Statement',    { fg = c.statement, bold = true })
    hi('Conditional',  { fg = c.statement, bold = true })
    hi('Repeat',       { fg = c.statement, bold = true })
    hi('Label',        { fg = c.label })
    hi('Operator',     { fg = c.operator })
    hi('Keyword',      { fg = c.keyword, bold = true })
    hi('Exception',    { fg = c.red, bold = true })
    hi('PreProc',      { fg = c.preproc })
    hi('Include',      { fg = c.preproc })
    hi('Define',       { fg = c.preproc })
    hi('Macro',        { fg = c.macro })
    hi('PreCondit',    { fg = c.preproc })
    hi('Type',         { fg = c.type, bold = true })
    hi('StorageClass', { fg = c.keyword, bold = true })
    hi('Structure',    { fg = c.type })
    hi('Typedef',      { fg = c.type })
    hi('Special',      { fg = c.special })
    hi('SpecialChar',  { fg = c.number })
    hi('Tag',          { fg = c.tag })
    hi('Delimiter',    { fg = c.fg_dim })
    hi('Debug',        { fg = c.special })
    hi('Underlined',   { fg = c.accent2, underline = true })
    hi('Ignore',       { fg = c.bg })
    hi('Error',        { fg = c.red, bold = true })
    hi('Todo',         { fg = c.special, bg = c.bg_status, bold = true })
  end

  -- Treesitter -----------------------------------------------------------
  hi('@comment',             { link = 'Comment' })
  hi('@keyword',             { link = 'Keyword' })
  hi('@keyword.function',    { link = 'Keyword' })
  hi('@keyword.return',      { link = 'Statement' })
  hi('@keyword.operator',    { link = 'Operator' })
  hi('@function',            { link = 'Function' })
  hi('@function.builtin',    mono and { fg = c.fg, bold = true } or { fg = c.macro, bold = true })
  hi('@function.call',       { link = 'Function' })
  hi('@method',              { link = 'Function' })
  hi('@method.call',         { link = 'Function' })
  hi('@constructor',         mono and { fg = c.fg } or { fg = c.type })
  hi('@string',              { link = 'String' })
  hi('@string.escape',       { link = 'SpecialChar' })
  hi('@string.special',      { link = 'Special' })
  hi('@number',              { link = 'Number' })
  hi('@boolean',             { link = 'Boolean' })
  hi('@float',               { link = 'Number' })
  hi('@variable',            { fg = c.variable })
  hi('@variable.builtin',    mono and { fg = c.fg, italic = true } or { fg = c.hint, italic = true })
  hi('@variable.parameter',  { fg = c.parameter })
  hi('@parameter',           { fg = c.parameter })
  hi('@field',               mono and { fg = c.fg } or { fg = c.property })
  hi('@property',            mono and { fg = c.fg } or { fg = c.property })
  hi('@type',                { link = 'Type' })
  hi('@type.builtin',        mono and { fg = c.fg } or { fg = c.type })
  hi('@constant',            { link = 'Constant' })
  hi('@constant.builtin',    { link = 'Boolean' })
  hi('@namespace',           mono and { fg = c.fg } or { fg = c.preproc })
  hi('@tag',                 { link = 'Tag' })
  hi('@tag.attribute',       mono and { fg = c.fg } or { fg = c.number })
  hi('@tag.delimiter',       { fg = c.fg_dim })
  hi('@punctuation',         { fg = c.fg_dim })
  hi('@punctuation.bracket', { fg = c.fg })
  hi('@punctuation.delimiter', { fg = c.fg_dim })
  hi('@operator',            { link = 'Operator' })
  hi('@text',                { fg = c.fg })
  hi('@text.strong',         { fg = c.strong, bold = true })
  hi('@text.emphasis',       { fg = c.fg, italic = true })
  hi('@text.title',          { fg = c.title, bold = true })
  hi('@text.uri',            { fg = c.accent2, underline = true })
  hi('@markup.strong',       { fg = c.strong, bold = true })
  hi('@markup.italic',       { fg = c.fg, italic = true })
  hi('@markup.heading',      { fg = c.title, bold = true })
  hi('@markup.link',         { fg = c.accent2, underline = true })
  hi('@markup.raw',          { fg = c.string })

  -- Git signs ------------------------------------------------------------
  hi('GitSignsAdd',    { fg = c.git_add, bg = editor_bg })
  hi('GitSignsChange', { fg = c.git_change, bg = editor_bg })
  hi('GitSignsDelete', { fg = c.git_delete, bg = editor_bg })

  -- Neo-tree -------------------------------------------------------------
  hi('NeoTreeNormal',        { fg = c.fg, bg = editor_bg })
  hi('NeoTreeNormalNC',      { fg = c.fg, bg = editor_bg })
  hi('NeoTreeCursorLine',    glass and { bg = c.bg_line, blend = 22 } or { bg = c.bg_line })
  hi('NeoTreeDirectoryIcon', { fg = c.accent2 })
  hi('NeoTreeDirectoryName', { fg = c.accent, bold = true })
  hi('NeoTreeFileName',      { fg = c.fg })
  hi('NeoTreeGitAdded',      { fg = c.git_add })
  hi('NeoTreeGitModified',   { fg = c.git_change })
  hi('NeoTreeGitDeleted',    { fg = c.git_delete })
  hi('NeoTreeIndentMarker',  { fg = c.nontext })
  hi('NeoTreeRootName',      { fg = c.title, bold = true })

  -- Telescope ------------------------------------------------------------
  hi('TelescopeNormal',       { fg = c.fg, bg = editor_bg })
  hi('TelescopeBorder',       { fg = c.border, bg = editor_bg })
  hi('TelescopePromptNormal', fbg(c.fg, c.bg_alt))
  hi('TelescopePromptBorder', fbg(c.accent2, c.bg_alt))
  hi('TelescopePromptTitle',  { fg = c.bg, bg = c.accent, bold = true })
  hi('TelescopeResultsTitle', { fg = c.bg, bg = c.title, bold = true })
  hi('TelescopePreviewTitle', { fg = c.bg, bg = c.bg_status, bold = true })
  hi('TelescopeSelection',    glass and { bg = c.bg_line, blend = 20, bold = true } or { bg = c.bg_line, bold = true })
  hi('TelescopeMatching',     { fg = c.search, bold = true })

  -- Which-key ------------------------------------------------------------
  hi('WhichKey',          { fg = c.accent, bold = true })
  hi('WhichKeyGroup',     { fg = c.preproc })
  hi('WhichKeyDesc',      { fg = c.fg })
  hi('WhichKeySeparator', { fg = c.fg_muted })
  hi('WhichKeyFloat',     fbg(nil, c.bg_alt))

  -- Indent guides --------------------------------------------------------
  hi('IndentBlanklineChar',        { fg = c.nontext })
  hi('IndentBlanklineContextChar', { fg = c.accent2 })
  hi('IblIndent',                  { fg = c.nontext })
  hi('IblScope',                   { fg = c.accent2 })

  -- Terminal ANSI (Claude Code / :term). Pass `false` to skip. -----------
  if spec.terminal ~= false then
    local term = spec.terminal
    if type(term) == 'table' then
      for i, col in ipairs(term) do
        vim.g['terminal_color_' .. (i - 1)] = col
      end
    end
  end

  -- Bespoke last word ----------------------------------------------------
  if type(spec.overrides) == 'table' then
    for group, opts in pairs(spec.overrides) do
      hi(group, opts)
    end
  end
end

return M
