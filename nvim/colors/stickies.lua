-- stickies.lua — macOS Stickies post-it note colorscheme.
-- Black ink on post-it yellow, deliberately minimal syntax highlighting.
-- Built from the shared theme builder in monochrome mode; the UI accents that
-- differ from the builder's colourful defaults are set via `overrides`.

require('theme_builder').build({
  name = 'stickies',
  background = 'light',
  mono = true,
  terminal = false,
  palette = {
    bg = '#FDFD96', fg = '#000000',
    bg_alt = '#F5F07A', bg_line = '#F5F07A', bg_status = '#E8D44D',
    fg_dim = '#5C4A00', fg_muted = '#8B7D52', border = '#D4C84A', nontext = '#D4C84A',
    sel = '#F0D060', visual = '#EDCA4E',
    accent = '#000000', accent2 = '#5C4A00', cursor = '#000000',
    matchparen = '#000000', title = '#000000',
    incsearch = '#000000', cursearch = '#5C4A00', search = '#F0D060',
    variable = '#000000', parameter = '#000000', preproc = '#5C4A00', strong = '#5C4A00',
    red = '#A52A2A', green = '#5A7A2E', yellow = '#8B6914', info = '#5C4A00', hint = '#6B5B00',
    git_add = '#5A7A2E', git_change = '#8B7D52', git_delete = '#A52A2A',
    diff_del_bg = '#F5D0A9', diff_change_bg = '#F5EDB0',
  },
  overrides = {
    iCursor = { fg = '#FDFD96', bg = '#5C4A00' },
    Conceal = { fg = '#5C4A00' },
    SpellLocal = { undercurl = true, sp = '#6B5B00' },
    SpellRare = { undercurl = true, sp = '#5C4A00' },
    Search = { fg = '#000000', bg = '#F0D060', bold = true },
    Substitute = { fg = '#FDFD96', bg = '#5C4A00' },
    ModeMsg = { fg = '#000000', bold = true },
    MoreMsg = { fg = '#5C4A00', bold = true },
    Question = { fg = '#5C4A00', bold = true },
    PmenuSel = { fg = '#FDFD96', bg = '#000000', bold = true },
    PmenuThumb = { bg = '#8B7D52' },
    IndentBlanklineContextChar = { fg = '#8B7D52' },
    IblScope = { fg = '#8B7D52' },
    ['@punctuation'] = { fg = '#000000' },
    ['@punctuation.delimiter'] = { fg = '#000000' },
    DiffAdd = { fg = '#2E5A1E', bg = '#D4E8B0' },
    TelescopePromptBorder = { fg = '#D4C84A', bg = '#F5F07A' },
    TelescopePromptTitle = { fg = '#000000', bg = '#E8D44D', bold = true },
    TelescopeResultsTitle = { fg = '#000000', bg = '#E8D44D', bold = true },
    TelescopePreviewTitle = { fg = '#000000', bg = '#E8D44D', bold = true },
    TelescopeMatching = { fg = '#000000', bold = true, underline = true },
  },
})
