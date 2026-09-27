-- Shared eligibility for automatic editing features and code analysis.
local M = {}

function M.is_source(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "netrw"
end

function M.allows(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	return vim.api.nvim_buf_is_loaded(buf) and M.is_source(buf) and not vim.b[buf].nopack_large_file
end

function M.guard(callback)
	return function(...)
		if M.allows(0) then
			return callback(...)
		end
	end
end

function M.restrict(buf)
	if vim.b[buf].nopack_large_file then
		return
	end
	vim.b[buf].nopack_large_file = true
	vim.api.nvim_exec_autocmds("User", { pattern = "NopackBufferRestricted", data = { buf = buf }, modeline = false })
end

return M
