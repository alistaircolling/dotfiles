return {
  dir = ".",
  name = "theme-watcher",
  lazy = false,
  priority = 999,
  config = function()
    local themes_dir = '/Users/Shared/dotfiles/themes'
    local current_file = themes_dir .. '/current'
    local apply = require('theme_apply')
    local loader = dofile(themes_dir .. '/loader.lua')

    -- Watch the active theme's .lua file so palette edits apply live
    -- - re-targets on theme switch
    local theme_file_handle = vim.uv.new_fs_event()
    local watch_theme_file

    local function apply_theme()
      apply.apply(loader.read_current())
      if watch_theme_file then watch_theme_file() end
    end

    watch_theme_file = function()
      if not theme_file_handle then return end
      theme_file_handle:stop()
      local theme_file = themes_dir .. '/' .. loader.read_current() .. '.lua'
      theme_file_handle:start(theme_file, {}, vim.schedule_wrap(function(err)
        if not err then
          apply_theme()
        end
      end))
    end

    apply_theme()

    local handle = vim.uv.new_fs_event()
    if handle then
      local function watch()
        handle:start(current_file, {}, vim.schedule_wrap(function(err)
          if not err then
            handle:stop()
            apply_theme()
            watch()
          end
        end))
      end
      watch()
    end

    -- Also watch the opacity file so Neovim reacts to `opa` shell command
    local opacity_file = '/Users/Shared/dotfiles/wezterm/opacity'
    local opacity_handle = vim.uv.new_fs_event()
    if opacity_handle then
      local function watch_opacity()
        opacity_handle:start(opacity_file, {}, vim.schedule_wrap(function(err)
          if not err then
            opacity_handle:stop()
            apply_theme()
            watch_opacity()
          end
        end))
      end
      watch_opacity()
    end
  end,
}
