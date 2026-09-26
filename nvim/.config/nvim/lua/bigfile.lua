-- Keep growth/long-line protection in addition to Snacks bigfile detection.
local protect_large_file
do
	local watched_buffers = {}
	protect_large_file = function(buf)
		if not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		if package.loaded.gitsigns then
			require("gitsigns").detach(buf)
		end
		vim.b[buf].snacks_indent = false
		vim.b[buf].snacks_scroll = false
		vim.b[buf].snacks_words = false
		pcall(vim.treesitter.stop, buf)
		vim.bo[buf].syntax = "OFF"
		vim.bo[buf].indentexpr = ""
		vim.bo[buf].autocomplete = false
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
			vim.lsp.buf_detach_client(buf, client.id)
		end
		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			vim.wo[win].foldmethod = "manual"
			vim.wo[win].cursorcolumn = false
			vim.wo[win].cursorline = false
			vim.wo[win].wrap = false
		end
	end
	local function check_large_file(buf, first, last)
		if vim.b[buf].large_file or not vim.api.nvim_buf_is_loaded(buf) then
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
			vim.b[buf].large_file = true
			protect_large_file(buf)
		end
	end
	local function queue_large_file_check(buf, first, last, added)
		local state = watched_buffers[buf]
		if not state or vim.b[buf].large_file then
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
			vim.b[args.buf].large_file = stat and stat.size > 2 * 1024 * 1024 or false
		end,
	})
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType", "BufWinEnter" }, {
		callback = function(args)
			local buf = args.buf
			if vim.bo[buf].buftype ~= "" then
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
					-- Check once before FileType plugins attach; edits are batched below.
					check_large_file(buf, 0, math.huge)
				else
					watched_buffers[buf] = nil
				end
			end
			if vim.b[buf].large_file then
				protect_large_file(buf)
			end
		end,
	})
end


return protect_large_file
