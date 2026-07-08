-- One :q quits Nvim when there is only one "real" window (e.g. neo-tree + one file).

local SIDEBAR_FT = {
  ["neo-tree"] = true,
  NvimTree = true,
}

local function count_non_sidebar_wins()
  local n = 0
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_config(win).relative == "" then
        local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
        if not SIDEBAR_FT[ft] then
          n = n + 1
        end
      end
    end
  end
  return n
end

local function expand_quit()
  if vim.fn.getcmdtype() ~= ":" then
    return "q"
  end
  local line = vim.fn.getcmdline()
  local bang = line:sub(-1) == "!"
  local base = bang and line:sub(1, -2) or line
  if base ~= "q" and base ~= "quit" then
    return line
  end
  if count_non_sidebar_wins() <= 1 then
    return bang and "qa!" or "qa"
  end
  return vim.fn.getcmdline()
end

local M = {}

M.setup = function()
  for _, lhs in ipairs({ "q", "q!", "quit", "quit!" }) do
    vim.cmd(string.format(
      [[cnoreabbrev <expr> %s v:lua.require("smart_quit")._expand()]],
      lhs
    ))
  end
end

-- Called from v:lua (must be global-ish for cabbrev)
M._expand = expand_quit

return M
