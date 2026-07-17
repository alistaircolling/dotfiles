local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Theme system: load active theme from themes/current
local themes_dir = '/Users/Shared/dotfiles/themes'
local loader = dofile(themes_dir .. '/loader.lua')
-- Shared, theme-independent config (accent + per-project color overrides).
-- Single source of truth, also read by shell/project-colors.zsh.
local ok_shared, shared = pcall(dofile, themes_dir .. '/shared.lua')
if not ok_shared or type(shared) ~= 'table' then shared = {} end
local current_theme_name = loader.read_current()
local theme = loader.load_theme(current_theme_name)
if not theme then
  current_theme_name = 'catppuccin-mocha'
  theme = loader.load_theme(current_theme_name)
end

-- Live-reload when theme changes or the active theme file is edited
wezterm.add_to_config_reload_watch_list(themes_dir .. '/current')
wezterm.add_to_config_reload_watch_list(themes_dir .. '/' .. current_theme_name .. '.lua')
wezterm.add_to_config_reload_watch_list(themes_dir .. '/shared.lua')

-- Dotfiles wezterm directory (opacity + font-override files live here)
local script_dir = '/Users/Shared/dotfiles/wezterm/'

-- Background opacity (1-100, written by `opa` shell command)
local opacity_file = script_dir .. 'opacity'
wezterm.add_to_config_reload_watch_list(opacity_file)
local function read_opacity()
  local f = io.open(opacity_file, 'r')
  if not f then return 1.0 end
  local val = tonumber(f:read('*l'))
  f:close()
  if not val then return 1.0 end
  val = math.max(1, math.min(100, val))
  return val / 100
end
local bg_opacity = read_opacity()
-- Optional per-theme window opacity (0–1), e.g. blueprint-glass. When unset, `opa` / opacity file applies.
if theme and theme.wezterm and type(theme.wezterm.window_background_opacity) == 'number' then
  bg_opacity = math.max(0, math.min(1, theme.wezterm.window_background_opacity))
end

-- Font (matches Neovim + shell defaults; theme can override)
local default_font = 'Gyrotrope'
local default_font_size = 22
local default_line_height = 1.0

-- Font override: Neovim font-cycler writes here to change font live
local font_override_file = script_dir .. 'font-override'
wezterm.add_to_config_reload_watch_list(font_override_file)

local function read_font_override()
  local f = io.open(font_override_file, 'r')
  if not f then return nil, nil, nil end
  local name = f:read('*l')
  local size_line = f:read('*l')
  local lh_line = f:read('*l')
  f:close()
  local font_name, font_size, line_height
  if name and name:match('%S') then font_name = name:match('^%s*(.-)%s*$') end
  if size_line then font_size = tonumber(size_line:match('^%s*(.-)%s*$')) end
  if lh_line then line_height = tonumber(lh_line:match('^%s*(.-)%s*$')) end
  return font_name, font_size, line_height
end

local font_override, font_size_override, line_height_override = read_font_override()

local active_font = font_override or ((theme and theme.wezterm) and theme.wezterm.font_family or nil) or default_font

-- Monaspace texture healing (calt) + coding ligatures (liga); see
-- https://github.com/githubnext/monaspace#texture-healing and https://wezterm.org/config/font-shaping.html
-- config.harfbuzz_features = { 'calt=0'}
config.harfbuzz_features = { 'calt=1', 'liga=1' }

config.font = wezterm.font(active_font)
config.font_size = font_size_override or (theme and theme.wezterm and theme.wezterm.font_size) or default_font_size
config.line_height = line_height_override or (theme and theme.wezterm and theme.wezterm.line_height) or default_line_height
if theme and theme.wezterm and theme.wezterm.cell_width then
  config.cell_width = theme.wezterm.cell_width
end

-- Cursor
config.default_cursor_style = 'SteadyBlock'

-- Apply theme colors
if theme and theme.wezterm then
  local tc = theme.wezterm.colors
  local accent = tc.ansi[6] or '#cba6f7'
  config.colors = {
    background = tc.background,
    foreground = tc.foreground,
    cursor_bg = tc.cursor_bg or '#ffffff',
    cursor_fg = tc.cursor_fg or '#1e1e2e',
    selection_bg = tc.selection_bg,
    selection_fg = tc.selection_fg,
    tab_bar = {
      background = 'rgba(0, 0, 0, 0)',
      active_tab = { bg_color = 'rgba(0, 0, 0, 0)', fg_color = accent, intensity = 'Bold' },
      inactive_tab = { bg_color = 'rgba(0, 0, 0, 0)', fg_color = accent },
      inactive_tab_hover = { bg_color = 'rgba(0, 0, 0, 0)', fg_color = accent },
      new_tab = { bg_color = 'rgba(0, 0, 0, 0)', fg_color = accent },
      new_tab_hover = { bg_color = 'rgba(0, 0, 0, 0)', fg_color = accent },
    },
    ansi = tc.ansi,
    brights = tc.brights,
  }

  -- Background: image if present, otherwise solid color
  if theme.wezterm.background_image then
    config.background = {
      {
        source = { File = theme.wezterm.background_image },
        hsb = { brightness = theme.wezterm.background_brightness or 0.1 },
        opacity = bg_opacity,
        width = 'Cover',
        height = 'Cover',
      },
      -- Dark scrim over the image so foreground text stays readable.
      -- Busy/bright image regions otherwise wash text out to grey.
      -- Tune per-theme via `background_scrim` (0 = off, 1 = fully hides image).
      {
        source = { Color = tc.background },
        opacity = (theme.wezterm.background_scrim or 0.5) * bg_opacity,
        width = '100%',
        height = '100%',
      },
    }
  end
end

-- Window background opacity (affects solid color backgrounds)
config.window_background_opacity = bg_opacity
config.macos_window_background_blur = 0

-- Window (matches Ghostty padding)
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Window appearance
config.window_decorations = 'RESIZE'

-- Tab bar configuration
config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
-- Retro cell height ~33px (22pt * 1.5lh); 3px shorter ≈ 30px → font_size 14
local frame_font = (theme and theme.wezterm and theme.wezterm.font_family) or default_font
config.window_frame = {
  font = wezterm.font(frame_font),
  font_size = 11.0,
  border_bottom_height = '4px',
  border_bottom_color = '#cba6f7',
}

-- Palette from active theme (used for directory coloring)
local PASTEL_PALETTE = (theme and theme.shell_palette) or {
  '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa',
  '#cba6f7', '#94e2d5', '#fab387', '#f5c2e7',
  '#74c7ec', '#b4befe', '#f2cdcd', '#eba0ac',
  '#89dceb', '#f5e0dc',
}

local function darken(hex, factor)
  -- factor 0.0 = black, 1.0 = original brightness; hue/saturation preserved
  local r = tonumber(hex:sub(2, 3), 16) / 255
  local g = tonumber(hex:sub(4, 5), 16) / 255
  local b = tonumber(hex:sub(6, 7), 16) / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v = 0, 0, max * factor
  local d = max - min
  if max ~= 0 then s = d / max end
  if d ~= 0 then
    if max == r then h = (g - b) / d % 6
    elseif max == g then h = (b - r) / d + 2
    else h = (r - g) / d + 4
    end
    h = h / 6
  end
  -- HSV back to RGB
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p, q, t = v*(1-s), v*(1-f*s), v*(1-(1-f)*s)
  local ro, go, bo
  i = i % 6
  if i==0 then ro,go,bo=v,t,p elseif i==1 then ro,go,bo=q,v,p
  elseif i==2 then ro,go,bo=p,v,t elseif i==3 then ro,go,bo=p,q,v
  elseif i==4 then ro,go,bo=t,p,v else ro,go,bo=v,p,q end
  return string.format('#%02x%02x%02x', math.floor(ro*255), math.floor(go*255), math.floor(bo*255))
end

-- Per-project color overrides — sourced from themes/shared.lua
local DIR_COLOR_OVERRIDES = shared.project_overrides or {}

local function dir_color(path)
  local basename = path:match('([^/]+)/?$') or path
  if DIR_COLOR_OVERRIDES[basename] then
    return DIR_COLOR_OVERRIDES[basename]
  end
  local hash = 0
  for i = 1, #path do
    hash = (hash * 31 + string.byte(path, i)) % 99999997
  end
  return PASTEL_PALETTE[(hash % #PASTEL_PALETTE) + 1]
end

local function pane_dir_label(pane)
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local path = cwd_uri.file_path or tostring(cwd_uri)
    if path and path ~= '' then
      local basename = path:match('([^/]+)/?$') or path
      return basename, dir_color(path)
    end
  end

  local fallback = pane:get_title()
  if fallback and fallback ~= '' then
    return fallback, '#cba6f7'
  end

  return 'shell', '#cba6f7'
end

local function panes_touching_bottom(panes)
  local max_bottom = 0
  for _, pane_info in ipairs(panes) do
    local pane_bottom = pane_info.top + pane_info.height
    if pane_bottom > max_bottom then
      max_bottom = pane_bottom
    end
  end

  local bottom_panes = {}
  for _, pane_info in ipairs(panes) do
    if pane_info.top + pane_info.height == max_bottom then
      table.insert(bottom_panes, pane_info)
    end
  end

  table.sort(bottom_panes, function(a, b)
    if a.left == b.left then
      return a.index < b.index
    end
    return a.left < b.left
  end)

  return bottom_panes
end

--[[
wezterm.on('format-tab-title', function(tab)
  local cwd = tab.active_pane.current_working_dir
  local title
  if cwd then
    local path = cwd.file_path or tostring(cwd)
    title = path:match('([^/]+)/?$') or path
  else
    title = tab.active_pane.title
  end
  return ' ' .. title .. ' '
end)

-- Directory-based font color with transparent background
local transparent = 'rgba(0, 0, 0, 0)'

wezterm.on('update-status', function(window, pane)
  local fg = '#cba6f7' -- Catppuccin mauve fallback
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local path = cwd_uri.file_path
    if path and path ~= '' then
      fg = dir_color(path)
    end
  end

  window:set_config_overrides({
    colors = {
      tab_bar = {
        background = transparent,
        active_tab        = { bg_color = transparent, fg_color = fg, intensity = 'Bold' },
        inactive_tab      = { bg_color = transparent, fg_color = fg },
        inactive_tab_hover = { bg_color = transparent, fg_color = fg },
        new_tab           = { bg_color = transparent, fg_color = fg },
        new_tab_hover     = { bg_color = transparent, fg_color = fg },
      },
    },
  })
end)
]]

--[=[
wezterm.on('update-status', function(window, _)
  local panes = panes_touching_bottom(window:active_tab():panes_with_info())
  local status = {}
  local cursor_col = 0

  for _, pane_info in ipairs(panes) do
    local label, fg = pane_dir_label(pane_info.pane)
    local target_col = pane_info.left
    local left_pad = target_col - cursor_col
    if left_pad > 0 then
      table.insert(status, { Attribute = { Intensity = 'Normal' } })
      table.insert(status, { Foreground = { Color = '#585b70' } })
      table.insert(status, { Text = string.rep(' ', left_pad) })
      cursor_col = cursor_col + left_pad
    end

    local text = ' ' .. label .. ' '
    if wezterm.column_width(text) > pane_info.width then
      text = wezterm.truncate_right(text, math.max(1, pane_info.width))
    end

    table.insert(status, { Foreground = { Color = fg } })
    table.insert(status, { Attribute = { Intensity = pane_info.is_active and 'Bold' or 'Normal' } })
    table.insert(status, { Text = text })
    cursor_col = cursor_col + wezterm.column_width(text)
  end

  window:set_left_status(wezterm.format(status))
  window:set_right_status('')
end)
]=]

-- Bottom border: 3px line colored by the focused pane's directory
wezterm.on('update-status', function(window, pane)
  local color = '#cba6f7'
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local path = cwd_uri.file_path or tostring(cwd_uri)
    if path and path ~= '' then
      color = dir_color(path)
    end
  end
  window:set_config_overrides({
    window_frame = {
      font = wezterm.font(frame_font),
      font_size = 11.0,
      border_bottom_height = '5px',
      border_bottom_color = color,
    },
  })
end)

-- Window title = git branch, so each window is identifiable in the AeroSpace
-- switcher. Falls back to the directory name, then "shell".
-- - branch comes from a user var set by the shell (wez-claude.zsh)
-- - non-git dirs show the folder name
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local branch = pane.user_vars and pane.user_vars.git_branch
  if branch and branch ~= '' then
    return branch
  end
  local cwd = pane.current_working_dir
  if cwd then
    local path = cwd.file_path or tostring(cwd)
    local name = path:match('([^/]+)/?$')
    if name and name ~= '' then return name end
  end
  return 'shell'
end)

-- Shell
config.default_prog = { '/bin/zsh', '-l' }

-- Scrollback
config.scrollback_lines = 10000

-- Disable update checks (managed via brew)
config.check_for_updates = false

-- Option as Alt/Meta for the terminal (readline, Neovim, etc.), not macOS “composed”
-- characters. Defaults: left = false (already meta), right = true (Stickies-style).
-- Both false = Option always Meta; use config.keys SendString for symbols you still want (e.g. #).
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Leader key: Opt+Space (matches tmux prefix)
config.leader = { key = ' ', mods = 'OPT', timeout_milliseconds = 1500 }

local act = wezterm.action

config.keys = {
  -- Option+3 → # (shell + nvim in WezTerm; UK layout / Meta quirks)
  { key = '3', mods = 'OPT', action = act.SendString '#' },
  -- Cmd+Opt+3 → # fallback (AeroSpace grabs plain Opt+3 for workspace nav)
  { key = '3', mods = 'CMD|OPT', action = act.SendString '#' },

  -- Pane splits (Leader + | or -, like tmux)
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
    local new_pane = pane:split { direction = 'Right' }
    if new_pane then
      new_pane:inject_output('\r\n')
    end
  end) },
  { key = '-', mods = 'LEADER',       action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane navigation (Leader + h/j/k/l)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Close pane (Leader + x)
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- Rotate panes (Leader + o)
  { key = 'o', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },

  -- Zoom pane (Leader + z)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- Fullscreen (Leader + f)
  { key = 'f', mods = 'LEADER', action = act.ToggleFullScreen },

  -- New tab (Leader + c)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },

  -- Tab navigation (Leader + n/p)
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- Vim scrollback browser (Leader + t) — open scrollback in nvim for full text-object support (yi", yi(, etc.)
  { key = 't', mods = 'LEADER', action = wezterm.action_callback(function(window, pane)
    local scrollback = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
    local tmp = os.tmpname()
    local f = assert(io.open(tmp, 'w'))
    f:write(scrollback)
    f:close()
    -- Spawn nvim in a new tab so it works even when a TUI app (e.g. Claude) owns the pane
    window:perform_action(act.SpawnCommandInNewTab {
      args = { '/bin/zsh', '-c', '/opt/homebrew/bin/nvim -R "+normal G$" "+set nomodified" ' .. tmp .. '; rm -f ' .. tmp },
    }, pane)
  end) },

  -- Theme cycling (Leader + > = next, Leader + < = previous)
  { key = '>', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
    local l = dofile(themes_dir .. '/loader.lua')
    local cur = l.read_current()
    local next_name = l.next_theme(cur)
    l.write_current(next_name)
    local t = l.load_theme(next_name)
    local display = t and t.name or next_name
    window:toast_notification('Theme', display, nil, 2000)
  end) },
  { key = '<', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
    local l = dofile(themes_dir .. '/loader.lua')
    local cur = l.read_current()
    local prev_name = l.prev_theme(cur)
    l.write_current(prev_name)
    local t = l.load_theme(prev_name)
    local display = t and t.name or prev_name
    window:toast_notification('Theme', display, nil, 2000)
  end) },

  -- Tab by number (Leader + 1-9)
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },

  -- Pane by number (Cmd + 1-9)
  { key = '1', mods = 'CMD', action = act.ActivatePaneByIndex(0) },
  { key = '2', mods = 'CMD', action = act.ActivatePaneByIndex(1) },
  { key = '3', mods = 'CMD', action = act.ActivatePaneByIndex(2) },
  { key = '4', mods = 'CMD', action = act.ActivatePaneByIndex(3) },
  { key = '5', mods = 'CMD', action = act.ActivatePaneByIndex(4) },
  { key = '6', mods = 'CMD', action = act.ActivatePaneByIndex(5) },
  { key = '7', mods = 'CMD', action = act.ActivatePaneByIndex(6) },
  { key = '8', mods = 'CMD', action = act.ActivatePaneByIndex(7) },
  { key = '9', mods = 'CMD', action = act.ActivatePaneByIndex(8) },
}

return config
