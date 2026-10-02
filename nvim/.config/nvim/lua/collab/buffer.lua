-- Only ordinary editor buffers are targets; plugin windows remain isolated.
local M = {}
function M.is_source(buf)
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "netrw"
end
function M.allows(buf)
	return vim.api.nvim_buf_is_loaded(buf) and M.is_source(buf)
end
function M.is_editor(win)
	win = win == 0 and vim.api.nvim_get_current_win() or win
	return vim.api.nvim_win_is_valid(win)
		and M.is_source(vim.api.nvim_win_get_buf(win))
		and vim.api.nvim_win_get_config(win).relative == ""
		and not vim.wo[win].previewwindow
end
function M.focus_editor()
	if M.is_editor(vim.api.nvim_get_current_win()) then
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if M.is_editor(win) then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.cmd("botright vnew")
end
return M
