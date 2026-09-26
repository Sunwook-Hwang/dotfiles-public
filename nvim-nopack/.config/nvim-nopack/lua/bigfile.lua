local shared = require("state")

-- =========================================
-- ========== LARGE FILE GUARDS ==========
-- =========================================
-- 2 MiB / 50,000줄 / 한 줄 10,000바이트 초과 시 무거운 기능을 중지합니다.
-- on_lines에서는 검사 범위만 합칩니다. 버퍼 조회/기능 중지는 textlock 밖에서 실행합니다.
local watched_buffers = {}
local function protect_large_file(buf)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local file = vim.api.nvim_buf_get_name(buf)
	file = vim.uv.fs_realpath(file) or file
	local root = file ~= "" and shared.find_project(vim.fs.dirname(file))
	local project = root and shared.tag_projects[root]
	if project and (project.pending[file] or (project.active and project.active.files[file])) then
		shared.cancel_tag_build(root, project)
		project.pending[file] = nil
		if next(project.pending) then
			shared.build_tags(root, false)
		end
	end
	shared.stop_git_sign_timer(buf)
	shared.git_sign_versions[buf], shared.git_sign_rendered[buf] = nil, nil
	if shared.git_diff_jobs[buf] then
		shared.git_diff_jobs[buf].pending = nil
	end
	shared.cancel_command("git-signs:" .. buf)
	vim.api.nvim_buf_clear_namespace(buf, shared.git_signs, 0, -1)
	pcall(vim.treesitter.stop, buf)
	vim.bo[buf].syntax = "OFF"
	vim.bo[buf].autocomplete = false
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		vim.lsp.buf_detach_client(buf, client.id)
	end
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		-- Like :setlocal: limit the guard to this buffer, preserving window defaults.
		vim.wo[win][0].foldmethod = "manual"
		vim.wo[win][0].cursorcolumn = false
		vim.wo[win][0].cursorline = false
		vim.wo[win][0].wrap = false
	end
end
local function check_large_file(buf, first, last)
	if vim.b[buf].nopack_large_file or not vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local count = vim.api.nvim_buf_line_count(buf)
	local large = count > 50000 or vim.api.nvim_buf_get_offset(buf, count) > 2 * 1024 * 1024
	if not large then
		first, last = math.max(0, math.min(first, count)), math.max(0, math.min(last, count))
		-- Fetch bounded batches, not a byte-offset lookup for every line.
		for start = first, last - 1, 512 do
			for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, start, math.min(start + 512, last), false)) do
				if #line > 10000 then
					large = true
					break
				end
			end
			if large then
				break
			end
		end
	end
	if large then
		vim.b[buf].nopack_large_file = true
		protect_large_file(buf)
	end
end
local function queue_large_file_check(buf, first, last, added)
	local state = watched_buffers[buf]
	if not state or vim.b[buf].nopack_large_file then
		return
	end
	state.first = math.min(state.first or first, first)
	-- Positive shifts conservatively extend the pending range; deletions are
	-- clamped at execution time. No changed line is lost during a paste burst.
	state.last = math.max(state.last and (state.last + math.max(0, added or 0)) or last, last)
	if state.pending then
		return
	end
	state.pending = true
	vim.schedule(function()
		if watched_buffers[buf] ~= state then
			return
		end
		state.pending = false
		local start, finish = state.first, state.last
		state.first, state.last = nil, nil
		if vim.api.nvim_buf_is_loaded(buf) then
			check_large_file(buf, start, finish)
		end
	end)
end
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
		vim.b[args.buf].nopack_large_file = stat and stat.size > 2 * 1024 * 1024 or false
	end,
})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType", "BufWinEnter" }, {
	callback = function(args)
		local buf = args.buf
		if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "netrw" then
			return
		end
		if not watched_buffers[buf] then
			watched_buffers[buf] = {}
			local attached = vim.api.nvim_buf_attach(buf, false, {
				on_lines = function(_, changed_buf, _, first, old_last, new_last)
					queue_large_file_check(changed_buf, first, new_last, new_last - old_last)
				end,
				on_reload = function(_, reloaded_buf)
					queue_large_file_check(reloaded_buf, 0, math.huge)
				end,
				on_detach = function(_, detached_buf)
					watched_buffers[detached_buf] = nil
				end,
			})
			if attached then
				queue_large_file_check(buf, 0, math.huge)
			else
				watched_buffers[buf] = nil
			end
		end
		if vim.b[buf].nopack_large_file then
			protect_large_file(buf)
		end
	end,
})
