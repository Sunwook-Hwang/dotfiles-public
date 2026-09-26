local shared = require("state")

-- =========================================
-- =========== PROJECT SESSIONS ==========
-- =========================================
-- Persistence 대체: Space pr/pl/pS/pd = 현재 프로젝트 복원/마지막 복원/선택/저장 중지.
-- stdpath(data)/nopack/sessions에 저장. 세션은 미저장 편집 내용의 백업이 아닙니다.
local session_dir = shared.nopack_data .. "/sessions/"
vim.fn.mkdir(session_dir, "p")
local save_session = true
local function session_path(root)
	return session_dir .. vim.fn.sha256(root or vim.fn.getcwd()) .. ".vim"
end
local function write_session()
	local listed = shared.buffers()
	if
		not save_session
		or #listed == 0
		or vim.fn.argc() == 0 and #listed == 1 and vim.api.nvim_buf_get_name(listed[1]) == ""
	then
		return
	end
	local root = vim.fn.getcwd()
	local path = session_path(root)
	vim.cmd("mksession! " .. vim.fn.fnameescape(path))
	vim.fn.writefile({ root }, path .. ".root")
	vim.fn.writefile({ path }, session_dir .. "last")
end
local function restore_session(path)
	if path and vim.fn.filereadable(path) == 1 then
		vim.cmd("source " .. vim.fn.fnameescape(path))
	else
		vim.notify("No saved session")
	end
end
function shared.select_session()
	vim.ui.select(vim.fn.glob(session_dir .. "*.vim", false, true), {
		prompt = "Sessions:",
		format_item = function(path)
			local metadata = path .. ".root"
			if vim.fn.filereadable(metadata) == 1 then
				local roots = vim.fn.readfile(metadata, "", 1)
				if roots[1] and roots[1] ~= "" then
					return roots[1]
				end
			end
			local directory
			for _, line in ipairs(vim.fn.readfile(path)) do
				local local_directory = line:match("^lcd (.+)$")
				if local_directory then
					return local_directory
				end
				directory = directory or line:match("^cd (.+)$")
			end
			return directory or path
		end,
	}, restore_session)
end
shared.map("n", "<leader>pr", function()
	restore_session(session_path())
end, "Restore directory session")
shared.map("n", "<leader>pl", function()
	local last = session_dir .. "last"
	restore_session(vim.fn.filereadable(last) == 1 and vim.fn.readfile(last)[1] or nil)
end, "Restore last session")
shared.map("n", "<leader>pd", function()
	save_session = false
end, "Stop saving session")
shared.map("n", "<leader>pS", shared.select_session, "Select session")
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		pcall(write_session)
	end,
})
