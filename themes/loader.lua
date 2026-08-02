-- Theme loader: shared between WezTerm and NeoVim
local M = {}

local themes_dir = '/Users/Shared/dotfiles/themes'

M.default_theme = 'catppuccin-mocha'

function M.themes_dir()
  return themes_dir
end

function M.read_current()
  local f = io.open(themes_dir .. '/current', 'r')
  if not f then return M.default_theme end
  local name = f:read('*l')
  f:close()
  if not name or name == '' then return M.default_theme end
  return name:match('^%s*(.-)%s*$')
end

function M.write_current(name)
  local f = io.open(themes_dir .. '/current', 'w')
  if f then
    f:write(name .. '\n')
    f:close()
  end
end

-- Colour maths, used only by normalise_ansi below --------------------------

local function parse_hex(hex)
  local r, g, b = tostring(hex):match('^#(%x%x)(%x%x)(%x%x)$')
  if not r then return nil end
  return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

local function to_hex(r, g, b)
  local function clamp(x) return math.max(0, math.min(1, x)) end
  return string.format('#%02x%02x%02x',
    math.floor(clamp(r) * 255 + 0.5),
    math.floor(clamp(g) * 255 + 0.5),
    math.floor(clamp(b) * 255 + 0.5))
end

local function rgb_to_hsl(r, g, b)
  local mx, mn = math.max(r, g, b), math.min(r, g, b)
  local l = (mx + mn) / 2
  if mx == mn then return 0, 0, l end
  local d = mx - mn
  local s = l > 0.5 and d / (2 - mx - mn) or d / (mx + mn)
  local h
  if mx == r then h = (g - b) / d + (g < b and 6 or 0)
  elseif mx == g then h = (b - r) / d + 2
  else h = (r - g) / d + 4 end
  return h / 6, s, l
end

local function hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end

local function hsl_to_hex(h, s, l)
  if s == 0 then return to_hex(l, l, l) end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return to_hex(hue_to_rgb(p, q, h + 1 / 3), hue_to_rgb(p, q, h), hue_to_rgb(p, q, h - 1 / 3))
end

local function luminance(hex)
  local r, g, b = parse_hex(hex)
  if not r then return nil end
  local function channel(x)
    if x <= 0.03928 then return x / 12.92 end
    return ((x + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

local function contrast(a, b)
  local la, lb = luminance(a), luminance(b)
  if not la or not lb then return math.huge end
  if la < lb then la, lb = lb, la end
  return (la + 0.05) / (lb + 0.05)
end

-- Keep TUI message bands readable ------------------------------------------
--
-- TUIs that follow the terminal palette (Claude Code on light-ansi, lazygit,
-- gh-dash) fill message bands and panels with slot 7 or 15, then draw slot 8
-- on top. Upstream palettes never designed those as a fill/text pair, so the
-- two can land on the same luminance and the text disappears. Widen the gap
-- just enough to clear a contrast floor, moving whichever slot is the fill:
--
--   * light schemes -- slots 7/15 are the fill, so hold them near the
--     background and darken slot 8 until it reads. A slot that has drifted
--     into text territory is rebuilt as a background tint.
--   * dark schemes -- slot 8 is the fill and slots 7/15 are the text, so dim
--     slot 8 first and lift the text slots only if that is not enough. Slot 8
--     never dims past DIM_VS_BG, or it would vanish into the background.

local LIGHT_FLOOR = 4.5   -- WCAG AA, where the reported bug was
local DARK_FLOOR  = 3.0   -- softer, so authored dark palettes keep their tint
local DIM_VS_BG   = 3.0   -- slot 8 must stay visible on the background
local BADGE_FLOOR = 3.0   -- white must read on the cyan session-name badge
local STEP        = 0.01

local function normalise_ansi(colors)
  local ansi, brights, bg = colors.ansi, colors.brights, colors.background
  if not (ansi and brights and bg) then return end
  if not (ansi[8] and brights[8] and brights[1] and luminance(bg)) then return end

  local light = luminance(bg) > 0.35
  local floor = light and LIGHT_FLOOR or DARK_FLOOR

  if light then
    local bh, bs, bl = rgb_to_hsl(parse_hex(bg))
    if contrast(ansi[8], bg) > 2.0 then
      ansi[8] = hsl_to_hex(bh, math.min(bs, 0.18), math.min(bl, 0.86))
    end
    if contrast(brights[8], bg) > 2.0 then
      brights[8] = hsl_to_hex(bh, math.min(bs, 0.12), math.min(bl, 0.94))
    end
  end

  -- Dim slot 8 until it clears both fills.
  local dh, ds, dl = rgb_to_hsl(parse_hex(brights[1]))
  while (contrast(brights[1], ansi[8]) < floor or contrast(brights[1], brights[8]) < floor)
    and dl > 0.03 do
    local candidate = hsl_to_hex(dh, ds, dl - STEP)
    if not light and contrast(candidate, bg) < DIM_VS_BG then break end
    dl, brights[1] = dl - STEP, candidate
  end

  -- Dark schemes only: lift the text slots if dimming alone fell short.
  if not light then
    for _, slots in ipairs({ ansi, brights }) do
      local h, s, l = rgb_to_hsl(parse_hex(slots[8]))
      while contrast(slots[8], brights[1]) < floor and l < 0.97 do
        l = l + STEP
        slots[8] = hsl_to_hex(h, s, l)
      end
    end
  end

  -- Keep Claude Code's session-name badge readable.
  --
  -- On an ANSI theme Claude Code fills the badge with slot 6 (cyan) and draws
  -- slot 7 (white) on top -- another fill/text pair upstream never designed
  -- together. Dark schemes often make cyan a light text tone, so white on it
  -- vanishes. Darken cyan until the lighter white clears the floor, but never
  -- past DIM_VS_BG or the badge itself would sink into the background.
  if not light and ansi[7] and luminance(ansi[7]) then
    local white = luminance(ansi[8]) > luminance(brights[8]) and ansi[8] or brights[8]
    local ch, cs, cl = rgb_to_hsl(parse_hex(ansi[7]))
    while contrast(white, ansi[7]) < BADGE_FLOOR and cl > 0.03 do
      local candidate = hsl_to_hex(ch, cs, cl - STEP)
      if contrast(candidate, bg) < DIM_VS_BG then break end
      cl, ansi[7] = cl - STEP, candidate
    end
  end
end

M.normalise_ansi = normalise_ansi

function M.load_theme(name)
  local path = themes_dir .. '/' .. name .. '.lua'
  local f = io.open(path, 'r')
  if not f then return nil end
  f:close()
  local ok, theme = pcall(dofile, path)
  if ok and type(theme) == 'table' then
    if theme.wezterm and theme.wezterm.colors then
      normalise_ansi(theme.wezterm.colors)
    end
    return theme
  end
  return nil
end

function M.list_themes()
  local themes = {}
  local handle = io.popen('ls "' .. themes_dir .. '"/*.lua 2>/dev/null')
  if handle then
    for line in handle:lines() do
      local basename = line:match('([^/]+)%.lua$')
      if basename and basename ~= 'loader' then
        table.insert(themes, basename)
      end
    end
    handle:close()
  end
  table.sort(themes)
  return themes
end

function M.next_theme(current)
  local themes = M.list_themes()
  if #themes == 0 then return current end
  for i, name in ipairs(themes) do
    if name == current then
      return themes[(i % #themes) + 1]
    end
  end
  return themes[1]
end

function M.prev_theme(current)
  local themes = M.list_themes()
  if #themes == 0 then return current end
  for i, name in ipairs(themes) do
    if name == current then
      return themes[((i - 2) % #themes) + 1]
    end
  end
  return themes[#themes]
end

function M.read_favorites()
  local path = themes_dir .. '/favorites'
  local default_theme = M.default_theme
  local raw = {}
  local f = io.open(path, 'r')
  if f then
    for line in f:lines() do
      local name = line:match('^%s*(.-)%s*$')
      if name and name ~= '' then
        table.insert(raw, name)
      end
    end
    f:close()
  end

  local seen = {}
  local deduped = {}
  for _, name in ipairs(raw) do
    if not seen[name] then
      seen[name] = true
      table.insert(deduped, name)
    end
  end

  local out
  if #deduped == 0 then
    out = { default_theme }
  elseif not seen[default_theme] then
    out = { default_theme, unpack(deduped) }
  else
    local rest = {}
    for _, name in ipairs(deduped) do
      if name ~= default_theme then
        table.insert(rest, name)
      end
    end
    out = { default_theme, unpack(rest) }
  end

  M.write_favorites(out)
  return out
end

function M.write_favorites(favs)
  local path = themes_dir .. '/favorites'
  local f = io.open(path, 'w')
  if not f then return end
  for _, name in ipairs(favs) do
    f:write(name .. '\n')
  end
  f:close()
end

function M.next_favorite(current)
  local favs = M.read_favorites()
  local n = #favs
  if n == 0 then return current end
  local idx = 0
  for i, name in ipairs(favs) do
    if name == current then
      idx = i
      break
    end
  end
  if idx == 0 then
    return favs[1]
  end
  return favs[(idx % n) + 1]
end

function M.prev_favorite(current)
  local favs = M.read_favorites()
  local n = #favs
  if n == 0 then return current end
  local idx = 0
  for i, name in ipairs(favs) do
    if name == current then
      idx = i
      break
    end
  end
  if idx == 0 then
    return favs[n]
  end
  idx = idx - 1
  if idx < 1 then
    idx = n
  end
  return favs[idx]
end

return M
