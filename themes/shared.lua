-- Shared, theme-independent config — single source of truth.
-- Read by BOTH wezterm/wezterm.lua and shell/project-colors.zsh.
-- (The simple `key = '#hex'` / `['name'] = '#hex'` shape below is parsed by the
-- zsh side with a line-based reader, so keep one entry per line and quoted hex.)
local M = {
  -- Accent for cursor, prompt caret, and terminal adornments
  accent = '#94e2d5',                       -- teal
  accent_rgba = 'rgba(148, 226, 213, 0.5)', -- 50% transparent

  -- Per-project color overrides (project dir name -> hex). Anything not listed
  -- gets an auto-assigned color from the active theme's palette.
  project_overrides = {
    ['dotfiles'] = '#f9e2af', -- yellow
  },
}

-- Merge extra overrides from the gitignored private overlay, if present
-- (same table shape; the zsh side reads that file directly).
local ok, priv = pcall(dofile, '/Users/Shared/dotfiles/private/themes/local.lua')
if ok and type(priv) == 'table' then
  for k, v in pairs(priv.project_overrides or {}) do
    M.project_overrides[k] = v
  end
end

return M
