lvim.builtin.terminal.open_mapping = [[<c-t>]]

local M = {}

M.htop_toggle = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local htop = Terminal:new {
    cmd = "htop",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  htop:toggle()
end

M.gpu_toggle = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local gpu = Terminal:new {
    cmd = "watch nvidia-smi",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  gpu:toggle()
end

return M
