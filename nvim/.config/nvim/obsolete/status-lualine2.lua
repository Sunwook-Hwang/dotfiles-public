local lualine = require("lualine")

local colors = {
  bg = "#202328",
  fg = "#bbc2cf",
  yellow = "#ECBE7B",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67",
}

-- Color table for highlights
local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local custom_gruvbox = require("lualine.themes.gruvbox")
-- custom_gruvbox.normal.c.bg = '#112233' -- rgb colors are supported
-- Config
local config = {
  options = {
    disabled_filetypes = { "dashboard", "alpha", "NvimTree" },
    component_separators = "",
    section_separators = "",
    theme = custom_gruvbox,
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left({
  function()
    return "▊"
  end,
  -- color = {fg = colors.blue}, -- Sets highlighting of component
  left_padding = 0, -- We don't need space before this
})

ins_left({
  "branch",
  icon = "",
  condition = conditions.check_git_workspace,
  -- color = {fg = colors.violet, gui = 'bold'}
})

ins_left({
  "filename",
  condition = conditions.buffer_not_empty,
  color = { fg = colors.yellow, gui = "bold" },
})

ins_left({
  "diff",
  symbols = { added = "+", modified = "~", removed = "-" },
  color_added = colors.green,
  color_modified = colors.orange,
  color_removed = colors.red,
  -- condition = conditions.hide_in_width
  condition = nil,
})

ins_right({
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " " },
  -- color_error = colors.red,
  -- color_warn = colors.yellow,
  -- color_info = colors.cyan
})

-- -- Insert mid section. You can make any number of sections in neovim :)
-- -- for lualine it's any number greater then 2
-- ins_left {function() return '%=' end}

ins_right({
  -- Lsp server name .
  function()
    local msg = "No Active Lsp"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = "  LSP:",
  -- color = {fg = '#ffffff', gui = 'bold'}
})

-- Add components to right sections
ins_right({
  "o:encoding", -- option component same as &encoding in viml
  upper = true, -- I'm not sure why it's upper case either ;)
  condition = conditions.hide_in_width,
  -- color = {fg = colors.green, gui = 'bold'}
})

ins_right({
  "fileformat",
  upper = true,
  icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  -- color = {fg = colors.green, gui = 'bold'}
})

ins_right({
  -- filesize component
  function()
    local function format_file_size(file)
      local size = vim.fn.getfsize(file)
      if size <= 0 then
        return ""
      end
      local sufixes = { "b", "k", "m", "g" }
      local i = 1
      while size > 1024 do
        size = size / 1024
        i = i + 1
      end
      return string.format("%.1f%s", size, sufixes[i])
    end

    local file = vim.fn.expand("%:p")
    if string.len(file) == 0 then
      return ""
    end
    return format_file_size(file)
  end,
  condition = conditions.buffer_not_empty,
})
ins_right({ "location" })
ins_right({ "progress", color = { fg = colors.fg, gui = "bold" } })
ins_right({
  function()
    return "▊"
  end,
  -- color = {fg = colors.blue},
  right_padding = 0,
})

-- Now don't forget to initialize lualine
lualine.setup(config)
