_G.dump = function(...)
  print(vim.inspect(...))
end

_G.prequire = function(...)
  local status, lib = pcall(require, ...)
  if status then
    return lib
  end
  return nil
end

local M = {}

local map = function(mode, key, cmd, opts, defaults)
  opts = vim.tbl_deep_extend("force", { silent = true }, defaults or {}, opts or {})

  if type(cmd) == "function" then
    table.insert(M.functions, cmd)
    if opts.expr then
      cmd = ([[luaeval('require("util").execute(%d)')]]):format(#M.functions)
    else
      cmd = ("<cmd>lua require('util').execute(%d)<cr>"):format(#M.functions)
    end
  end
  if opts.buffer ~= nil then
    local buffer = opts.buffer
    opts.buffer = nil
    return vim.api.nvim_buf_set_keymap(buffer, mode, key, cmd, opts)
  else
    return vim.keymap.set(mode, key, cmd, opts)
  end
end

function M.map(mode, key, cmd, opt, defaults)
  return map(mode, key, cmd, opt, defaults)
end

function M.nmap(key, cmd, opts)
  return map("n", key, cmd, opts)
end

function M.vmap(key, cmd, opts)
  return map("v", key, cmd, opts)
end

function M.tmap(key, cmd, opts)
  return map("t", key, cmd, opts)
end

function M.xmap(key, cmd, opts)
  return map("x", key, cmd, opts)
end

function M.imap(key, cmd, opts)
  return map("i", key, cmd, opts)
end

function M.omap(key, cmd, opts)
  return map("o", key, cmd, opts)
end

function M.smap(key, cmd, opts)
  return map("s", key, cmd, opts)
end

function M.nnoremap(key, cmd, opts)
  return map("n", key, cmd, opts, { noremap = true })
end

function M.vnoremap(key, cmd, opts)
  return map("v", key, cmd, opts, { noremap = true })
end

function M.tnoremap(key, cmd, opts)
  return map("t", key, cmd, opts, { noremap = true })
end

function M.xnoremap(key, cmd, opts)
  return map("x", key, cmd, opts, { noremap = true })
end

function M.inoremap(key, cmd, opts)
  return map("i", key, cmd, opts, { noremap = true })
end

function M.onoremap(key, cmd, opts)
  return map("o", key, cmd, opts, { noremap = true })
end

function M.snoremap(key, cmd, opts)
  return map("s", key, cmd, opts, { noremap = true })
end

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.exists(list, val)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set[val]
end

function M.log(msg, hl, name)
  name = name or "Neovim"
  hl = hl or "Todo"
  vim.api.nvim_echo({ { name .. ": ", hl }, { msg } }, true, {})
end

function M.warn(msg, name)
  vim.notify(msg, vim.log.levels.WARN, { title = name })
end

function M.error(msg, name)
  vim.notify(msg, vim.log.levels.ERROR, { title = name })
end

function M.info(msg, name)
  vim.notify(msg, vim.log.levels.INFO, { title = name })
end

function M.nvim_version(val)
  local version = (vim.version().major .. "." .. vim.version().minor) + 0.0
  val = val or 0.7
  if version >= val then
    return true
  else
    return false
  end
end

function M.nvim_nightly()
  return M.nvim_version(0.7)
end

return M
