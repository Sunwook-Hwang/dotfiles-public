local shared = require("state")

-- Share file sessions with Pack; auxiliary windows and mode-specific options stay local.
local session_dir = (vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")) .. "/nvim/sessions/"
vim.fn.mkdir(session_dir, "p")
local save_session = true
local function session_path()
	return session_dir .. vim.fn.getcwd():gsub("[\\/:]+", "%%") .. ".vim"
end
local function sessions()
	local paths = vim.fn.glob(session_dir .. "*.vim", false, true)
	table.sort(paths, function(a, b)
		return vim.uv.fs_stat(a).mtime.sec > vim.uv.fs_stat(b).mtime.sec
	end)
	return paths
end
local function write_session()
	if not save_session then
		return
	end
	local has_file = false
	local excluded = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			has_file = true
		elseif vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "" then
			excluded[#excluded + 1] = buf
		end
	end
	if not has_file then
		return
	end
	for _, buf in ipairs(excluded) do
		vim.bo[buf].buflisted = false
	end
	local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(session_path()))
	for _, buf in ipairs(excluded) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.bo[buf].buflisted = true
		end
	end
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end
local function restore_session(path)
	if path and vim.fn.filereadable(path) == 1 then
		vim.cmd("source " .. vim.fn.fnameescape(path))
	else
		vim.notify("No saved session")
	end
end
function shared.select_session()
	vim.ui.select(sessions(), {
		prompt = "Sessions:",
		format_item = function(path)
			local directory = path:sub(#session_dir + 1, -5):gsub("%%", "/")
			if vim.fn.has("win32") == 1 then
				directory = directory:gsub("^(%w)/", "%1:/")
			end
			return vim.fn.fnamemodify(directory, ":p:~")
		end,
	}, restore_session)
end
shared.map("n", "<leader>pr", function()
	restore_session(session_path())
end, "Restore directory session")
shared.map("n", "<leader>pl", function()
	restore_session(sessions()[1])
end, "Restore last session")
shared.map("n", "<leader>pd", function()
	save_session = false
end, "Stop saving session")
shared.map("n", "<leader>pS", shared.select_session, "Select session")
vim.api.nvim_create_autocmd("VimLeavePre", { callback = write_session })
