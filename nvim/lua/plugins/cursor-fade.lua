-- Cursor accent fade: blue while moving, fades to yellow when idle
return {
  name = "cursor-fade",
  dir = vim.fn.stdpath("config"),
  event = "VeryLazy",
  config = function()
    local BLUE = "#006e8c"
    local IDLE_COLOR = "#f0c674"
    local BLUE_FG = "#ffffff"
    local IDLE_FG = "#1e1e2e"
    local ACCENT_BLEND = 50

    local FADE_STEPS = 15
    local FADE_INTERVAL_MS = 30
    local IDLE_DELAY_MS = 500

    local fade_timer = vim.uv.new_timer()
    local idle_timer = vim.uv.new_timer()
    local current_step = 0
    local is_fading = false
    local is_slate = false

    local function hex_to_rgb(hex)
      return {
        tonumber(hex:sub(2, 3), 16),
        tonumber(hex:sub(4, 5), 16),
        tonumber(hex:sub(6, 7), 16),
      }
    end

    local function lerp(a, b, t)
      return math.floor(a + (b - a) * t + 0.5)
    end

    local blue_rgb = hex_to_rgb(BLUE)
    local idle_rgb = hex_to_rgb(IDLE_COLOR)
    local blue_fg_rgb = hex_to_rgb(BLUE_FG)
    local idle_fg_rgb = hex_to_rgb(IDLE_FG)

    local function set_accent(color, fg_color, line_color)
      vim.api.nvim_set_hl(0, "Cursor", { bg = color, fg = fg_color })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = line_color, blend = ACCENT_BLEND })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = line_color, bold = true, blend = ACCENT_BLEND })
      vim.api.nvim_set_hl(0, "CursorLineSign", { bg = line_color, blend = ACCENT_BLEND })
      vim.api.nvim_set_hl(0, "CursorLineFold", { bg = line_color, blend = ACCENT_BLEND })
      vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = line_color, blend = ACCENT_BLEND })
    end

    local function ease_out(t)
      return 1 - (1 - t) * (1 - t)
    end

    local function in_insert()
      local m = vim.fn.mode():sub(1, 1)
      return m == "i" or m == "R"
    end

    local function snap_to_blue()
      idle_timer:stop()
      fade_timer:stop()
      is_fading = false
      is_slate = false
      current_step = 0
      set_accent(BLUE, BLUE_FG, BLUE)
    end

    local function do_fade_step()
      current_step = current_step + 1
      if current_step > FADE_STEPS then
        fade_timer:stop()
        is_fading = false
        is_slate = true
        return
      end

      local t = ease_out(current_step / FADE_STEPS)
      local r = lerp(blue_rgb[1], idle_rgb[1], t)
      local g = lerp(blue_rgb[2], idle_rgb[2], t)
      local b = lerp(blue_rgb[3], idle_rgb[3], t)
      local color = string.format("#%02x%02x%02x", r, g, b)
      local fr = lerp(blue_fg_rgb[1], idle_fg_rgb[1], t)
      local fg = lerp(blue_fg_rgb[2], idle_fg_rgb[2], t)
      local fb = lerp(blue_fg_rgb[3], idle_fg_rgb[3], t)
      local fg_color = string.format("#%02x%02x%02x", fr, fg, fb)

      vim.schedule(function()
        if in_insert() then
          fade_timer:stop()
          is_fading = false
          snap_to_blue()
          return
        end
        set_accent(color, fg_color, BLUE)
      end)
    end

    local function start_fade()
      if in_insert() then return end
      current_step = 0
      is_fading = true
      fade_timer:start(0, FADE_INTERVAL_MS, do_fade_step)
    end

    local group = vim.api.nvim_create_augroup("CursorFade", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      callback = function()
        if is_fading or is_slate then
          snap_to_blue()
        end
        idle_timer:stop()
        -- Only fade in normal mode; keep cursor blue in insert mode
        if vim.fn.mode():sub(1, 1) ~= "i" then
          idle_timer:start(IDLE_DELAY_MS, 0, function()
            vim.schedule(start_fade)
          end)
        end
      end,
    })

    -- Snap to blue when entering insert mode
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function()
        snap_to_blue()
      end,
    })
  end,
}
