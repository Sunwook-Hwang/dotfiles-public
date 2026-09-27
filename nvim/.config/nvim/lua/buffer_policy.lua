-- Shared eligibility for automatic editing features and code analysis.
local M = {}

function M.is_source(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == ""
end

function M.allows(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	return vim.api.nvim_buf_is_loaded(buf) and M.is_source(buf) and not vim.b[buf].large_file
end

function M.guard(callback)
	return function(...)
		if M.allows(0) then
			return callback(...)
		end
	end
end

function M.restrict(buf)
	if vim.b[buf].large_file then
		return
	end
	vim.b[buf].large_file = true
	for _, feature in ipairs({ "indent", "scroll", "words", "scope", "dim" }) do
		vim.b[buf]["snacks_" .. feature] = false
	end
	vim.api.nvim_exec_autocmds("User", { pattern = "PackBufferRestricted", data = { buf = buf }, modeline = false })
end

return M
