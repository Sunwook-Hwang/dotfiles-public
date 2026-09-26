local shared = require("state")

-- =========================================
-- ========== CODE OUTLINE / LSP + CTAGS ==========
-- =========================================
-- Space o: 현재 파일의 함수·클래스 계층을 오른쪽 사이드바로 토글합니다.
-- Enter: 해당 위치 이동, r: 새로고침, q/Space o: 닫기, Ctrl-h/j/k/l: 창 이동.
-- 열린 동안 파일 전환·저장·LSP 연결 시만 갱신합니다. 매 키 입력마다 요청하지 않습니다.
local function outline_text(state, lines)
	if not vim.api.nvim_buf_is_valid(state.buf) then
		return
	end
	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	vim.bo[state.buf].modifiable = false
end
shared.cancel_outline = function(state)
	state.version = state.version + 1
	if state.cancel then
		state.cancel()
		state.cancel = nil
	end
end
local function ctags_outline(state)
	local version, buf = state.version, state.source
	state.items = {}
	local root, file = shared.tag_context(buf)
	if not root then
		outline_text(state, { "Ctags unavailable or file exceeds size limits" })
		return
	end
	if file:find("[\r\n]") then
		return
	end
	local stat = vim.uv.fs_stat(file)
	local stamp = stat and (stat.size .. ":" .. stat.mtime.sec .. ":" .. stat.mtime.nsec)
	if stamp and state.ctags_file == file and state.ctags_stamp == stamp then
		state.items = state.ctags_items
		outline_text(state, state.ctags_lines)
		return
	end
	outline_text(state, { "Indexing saved file..." })
	shared.build_tags(root, false, { file }, function(output)
		if shared.outline ~= state or state.version ~= version or not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		local items = {}
		for _, line in ipairs(shared.records(output, "\n")) do
			if not line:match("^!_TAG_") and shared.tag_filename(line) == file then
				local name = line:match("^([^\t]+)")
				local row = tonumber(line:match("\tline:(%d+)"))
				local kind = line:match(';"\t([^\t]+)') or ""
				local scope = ""
				for _, field in ipairs({ "class", "struct", "namespace", "union", "enum", "function", "scope" }) do
					scope = line:match("\t" .. field .. ":([^\t]+)") or scope
				end
				if row then
					local depth = scope == "" and 0 or #vim.split(scope:gsub("::", "."), ".", { plain = true })
					items[#items + 1] = {
						lnum = row,
						label = string.rep("  ", depth)
							.. name
							.. " ["
							.. kind
							.. "]"
							.. (scope == "" and "" or " (" .. scope .. ")"),
					}
				end
			end
		end
		table.sort(items, function(a, b)
			return a.lnum < b.lnum
		end)
		state.items = items
		local lines = #items > 0 and vim.tbl_map(function(item)
			return item.label
		end, items) or { "No symbols in saved file" }
		state.ctags_file, state.ctags_stamp = file, stamp
		state.ctags_items, state.ctags_lines = items, lines
		outline_text(state, lines)
	end, function()
		if shared.outline == state and state.version == version then
			outline_text(state, { "Ctags indexing failed", "Press r to retry" })
		end
	end)
end
local function refresh_outline(state)
	shared.cancel_outline(state)
	local version, buf = state.version, state.source
	state.items = {}
	if not vim.api.nvim_buf_is_loaded(buf) then
		outline_text(state, { "Source buffer closed" })
		return
	end
	local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" })
	if #clients == 0 then
		ctags_outline(state)
		return
	end
	-- Use one provider to avoid duplicate symbols when several LSP clients attach.
	table.sort(clients, function(a, b)
		return a.id < b.id
	end)
	local client = clients[1]
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	outline_text(state, { "Loading symbols..." })
	local ok, request = client:request("textDocument/documentSymbol", {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
	}, function(err, symbols)
		vim.schedule(function()
			if shared.outline ~= state or state.version ~= version then
				return
			end
			state.cancel = nil
			if not vim.api.nvim_buf_is_loaded(buf) then
				return
			end
			if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
				outline_text(state, { "File changed; save or press r" })
				return
			end
			if err or symbols == nil or symbols == vim.NIL or #symbols == 0 then
				ctags_outline(state)
				return
			end
			local lines, items = {}, {}
			local function collect(nodes, depth)
				for _, symbol in ipairs(nodes) do
					local location = symbol.location
						or { uri = vim.uri_from_bufnr(buf), range = symbol.selectionRange or symbol.range }
					local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Symbol"
					lines[#lines + 1] = string.rep("  ", depth) .. kind .. " " .. symbol.name:gsub("[%c]", " ")
					items[#items + 1] = { location = location, range = symbol.range or location.range }
					if symbol.children then
						collect(symbol.children, depth + 1)
					end
				end
			end
			collect(symbols ~= vim.NIL and symbols or {}, 0)
			state.items, state.encoding = items, client.offset_encoding
			outline_text(state, #lines > 0 and lines or { "No symbols in this file" })
			if vim.api.nvim_win_is_valid(state.win) and vim.api.nvim_win_is_valid(state.source_win) then
				local row, selected = vim.api.nvim_win_get_cursor(state.source_win)[1] - 1, 1
				for i, item in ipairs(items) do
					if item.range.start.line <= row and item.range["end"].line >= row then
						selected = i
					end
				end
				vim.api.nvim_win_set_cursor(state.win, { selected, 0 })
			end
		end)
	end, buf)
	if not ok then
		ctags_outline(state)
		return
	end
	state.cancel = function()
		client:cancel_request(request)
	end
	vim.defer_fn(function()
		if shared.outline == state and state.version == version and state.cancel then
			shared.cancel_outline(state)
			ctags_outline(state)
		end
	end, 5000)
end
shared.map("n", "<leader>o", function()
	if shared.outline then
		vim.api.nvim_win_close(shared.outline.win, true)
		return
	end
	shared.focus_editor()
	if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then
		vim.notify("Open a code file to view its outline")
		return
	end
	local state = {
		source = vim.api.nvim_get_current_buf(),
		source_win = vim.api.nvim_get_current_win(),
		version = 0,
		items = {},
	}
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].filetype = "nopack_outline"
	state.win = vim.api.nvim_open_win(state.buf, true, {
		split = "right",
		win = state.source_win,
		width = shared.sidebar_width(),
	})
	shared.outline = state
	shared.fix_sidebar_width(state.win)
	-- Buffer-local window options must not become defaults for files opened here.
	vim.wo[state.win][0].number = false
	vim.wo[state.win][0].relativenumber = false
	vim.wo[state.win][0].signcolumn = "no"
	vim.wo[state.win][0].wrap = false
	vim.wo[state.win][0].cursorline = true
	vim.wo[state.win][0].cursorlineopt = "line"
	vim.wo[state.win][0].cursorcolumn = false
	vim.wo[state.win][0].winbar = " Outline: "
		.. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(state.source), ":t"):gsub("%%", "%%%%")
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(state.win, true)
	end, { buf = state.buf, desc = "Close outline" })
	vim.keymap.set("n", "r", function()
		refresh_outline(state)
	end, { buf = state.buf, desc = "Refresh outline" })
	vim.keymap.set("n", "<CR>", function()
		local item = state.items[vim.api.nvim_win_get_cursor(state.win)[1]]
		if not item then
			return
		end
		if vim.api.nvim_win_is_valid(state.source_win) then
			vim.api.nvim_set_current_win(state.source_win)
		else
			shared.focus_editor()
		end
		if item.location then
			vim.lsp.util.show_document(item.location, state.encoding, { focus = true })
		elseif vim.api.nvim_buf_is_valid(state.source) then
			vim.cmd("normal! m'")
			vim.api.nvim_win_set_buf(0, state.source)
			vim.api.nvim_win_set_cursor(0, { math.min(item.lnum, vim.api.nvim_buf_line_count(state.source)), 0 })
		end
		vim.cmd("normal! zvzz")
	end, { buf = state.buf, desc = "Jump to symbol" })
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(state.win),
		once = true,
		callback = function()
			shared.cancel_outline(state)
			if shared.outline == state then
				shared.outline = nil
			end
		end,
	})
	refresh_outline(state)
end, "Toggle code outline")
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "LspAttach", "LspDetach" }, {
	callback = function(args)
		local state = shared.outline
		-- Reusing the sidebar window ends its outline, even if a split still shows the old buffer.
		if state and vim.api.nvim_win_get_buf(state.win) ~= state.buf then
			shared.cancel_outline(state)
			shared.outline = nil
			return
		end
		if
			not state
			or vim.bo[args.buf].buftype ~= ""
			or vim.bo[args.buf].filetype == "netrw"
			or vim.api.nvim_win_get_tabpage(state.win) ~= vim.api.nvim_get_current_tabpage()
		then
			return
		end
		if args.event == "BufEnter" then
			local same_source = state.source == args.buf
			state.source, state.source_win = args.buf, vim.api.nvim_get_current_win()
			if same_source then
				return
			end
			vim.wo[state.win][0].winbar = " Outline: "
				.. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t"):gsub("%%", "%%%%")
		end
		if args.buf == state.source and not state.refresh_pending then
			state.refresh_pending = true
			vim.schedule(function()
				state.refresh_pending = false
				if shared.outline == state then
					refresh_outline(state)
				end
			end)
		end
	end,
})
