return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VimEnter',
  config = function()
    local alpha = require('alpha')

    local hl_group = 'DashboardHeader'
    local hl_ns = vim.api.nvim_create_namespace('dashboard_hl')

    local templates = {
      'EQU;  .%04d/%03d+%03d',
      '      ─────────────',
      '       %02dRTΔ> %02d(PΠ)',
    }

    local final_nums = { 93, 226, 784, 98, 34 }
    local settle_pcts = { 0.35, 0.55, 0.70, 0.85, 1.0 }

    local function build_text(nums)
      return {
        string.format(templates[1], nums[1], nums[2], nums[3]),
        templates[2],
        string.format(templates[3], nums[4], nums[5]),
      }
    end

    local function pad_top()
      local win_h = vim.api.nvim_win_get_height(0)
      local top = math.max(0, math.floor((win_h - 3) / 2) - 1)
      local lines = {}
      for _ = 1, top do lines[#lines + 1] = '' end
      return lines
    end

    local function build_display(text_lines)
      local lines = pad_top()
      for _, l in ipairs(text_lines) do
        lines[#lines + 1] = l
      end
      return lines
    end

    local function apply_hl(buf, lines)
      vim.api.nvim_buf_clear_namespace(buf, hl_ns, 0, -1)
      for i, line in ipairs(lines) do
        if #line > 0 then
          vim.api.nvim_buf_add_highlight(buf, hl_ns, hl_group, i - 1, 0, -1)
        end
      end
    end

    local function build_schedule()
      local delays = {}
      local total_ms = 0
      local delay = 50
      while total_ms < 5000 do
        delays[#delays + 1] = delay
        total_ms = total_ms + delay
        delay = math.min(500, math.floor(delay * 1.12))
      end
      return delays
    end

    local header = {
      type = 'text',
      val = build_display({ '', '', '' }),
      opts = { position = 'center', hl = hl_group },
    }

    alpha.setup({
      layout = { header },
      opts = { margin = 5, noautocmd = false },
    })

    local animation_timer = nil

    local function set_dashboard_font() end

    local function stop_animation()
      if animation_timer then
        animation_timer:stop()
        animation_timer:close()
        animation_timer = nil
      end
    end

    local function restore_normal_font()
      stop_animation()
    end

    local function run_animation()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype ~= 'alpha' then return end

      local schedule = build_schedule()
      local frame = 0
      local total_frames = #schedule

      local current = {}
      for i, target in ipairs(final_nums) do
        current[i] = target + math.random(-20, 20)
      end

      local function next_frame()
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'alpha' then
          stop_animation()
          return
        end

        frame = frame + 1
        local progress = math.min(1.0, frame / total_frames)

        local display = {}
        for i, target in ipairs(final_nums) do
          if progress >= settle_pcts[i] then
            display[i] = target
            current[i] = target
          else
            local drift = math.random(-2, 2)
            local diff = target - current[i]
            -- Bias toward target as we approach settle point
            local group_progress = progress / settle_pcts[i]
            if math.random() < group_progress * 0.4 then
              drift = diff > 0 and math.random(1, 2) or (diff < 0 and math.random(-2, -1) or 0)
            end
            current[i] = math.max(0, current[i] + drift)
            display[i] = current[i]
          end
        end

        local text = build_text(display)
        local lines = build_display(text)

        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        apply_hl(buf, lines)

        if frame >= total_frames then
          stop_animation()
          return
        end

        animation_timer = vim.uv.new_timer()
        animation_timer:start(schedule[frame], 0, vim.schedule_wrap(function()
          if animation_timer then animation_timer:stop(); animation_timer:close(); animation_timer = nil end
          next_frame()
        end))
      end

      next_frame()
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'AlphaReady',
      callback = function()
        set_dashboard_font()
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        apply_hl(buf, lines)
        vim.defer_fn(run_animation, 150)
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'AlphaClosed',
      callback = restore_normal_font,
    })

    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        if vim.bo.filetype ~= 'alpha' and vim.bo.filetype ~= '' then
          restore_normal_font()
        end
      end,
    })

    local function set_hl()
      vim.api.nvim_set_hl(0, hl_group, { fg = '#7acdca' })
    end
    set_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })
  end,
}
