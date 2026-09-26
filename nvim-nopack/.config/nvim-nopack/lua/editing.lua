local shared = require("state")

-- =========================================
-- ========== UNDO / WHITESPACE ==========
-- =========================================
-- Replay a copy of the undo history in the preview; only Enter changes the source.
local function undo_picker()
	shared.focus_editor()
	local source = vim.api.nvim_get_current_buf()
	if vim.bo[source].buftype ~= "" or not vim.bo[source].modifiable then
		vim.notify("Undo history is available for editable file buffers", vim.log.levels.WARN)
		return
	end
	if vim.o.columns < 44 then
		vim.notify("Undo preview requires at least 44 terminal columns", vim.log.levels.WARN)
		return
	end
	local tree, entries = vim.fn.undotree(), {}
	local function collect(branch)
		for _, entry in ipairs(branch) do
			entries[#entries + 1] = entry
			if entry.alt then
				collect(entry.alt)
			end
		end
	end
	collect(tree.entries)
	if #entries == 0 then
		vim.notify("No undo history for this buffer yet", vim.log.levels.INFO)
		return
	end
	table.sort(entries, function(a, b)
		return a.seq > b.seq
	end)
	entries[#entries + 1] = { seq = 0 }
	local tick = vim.api.nvim_buf_get_changedtick(source)
	local lines = vim.api.nvim_buf_get_lines(source, 0, -1, false)
	local syntax, path = vim.bo[source].syntax, vim.fn.tempname()
	local items, ready, shown = {}, false, nil
	for _, entry in ipairs(entries) do
		local seq = entry.seq
		items[#items + 1] = {
			seq = seq,
			label = string.format(
				"#%-5d %s%s%s",
				seq,
				seq == 0 and "Initial state" or vim.fn.strftime("%m-%d %H:%M:%S", entry.time),
				entry.save and " [saved]" or "",
				seq == tree.seq_cur and " [current]" or ""
			),
			action = function()
				if not vim.api.nvim_buf_is_valid(source) or vim.api.nvim_buf_get_changedtick(source) ~= tick then
					vim.notify("Buffer changed while browsing undo history; reopen the list", vim.log.levels.WARN)
					return
				end
				vim.api.nvim_set_current_buf(source)
				vim.cmd.undo(seq)
			end,
		}
	end
	local ok, err = pcall(function()
		vim.cmd("silent wundo! " .. vim.fn.fnameescape(path))
		shared.open_picker("Undo · Enter: apply · Esc: cancel", {
			items = items,
			preview = function(item, buf, win)
				vim.api.nvim_win_call(win, function()
					if not ready then
						vim.bo[buf].modifiable = true
						vim.bo[buf].undofile = false
						vim.bo[buf].undolevels = 1000
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
						vim.cmd("silent rundo " .. vim.fn.fnameescape(path))
						vim.bo[buf].syntax = syntax
						vim.wo[win][0].number = true
						ready = true
					end
					if shown ~= item.seq then
						vim.bo[buf].modifiable = true
						vim.cmd("silent undo " .. item.seq)
						vim.bo[buf].modifiable = false
						vim.cmd("normal! zz")
						vim.api.nvim_win_set_config(win, { title = "State #" .. item.seq .. " · Ctrl-f/b: scroll" })
						shown = item.seq
					end
				end)
			end,
		})
	end)
	-- The preview has its own in-memory undo tree once rundo has completed.
	vim.fn.delete(path)
	if not ok then
		if shared.active_picker then
			shared.active_picker.close()
		end
		vim.notify("Unable to preview undo history: " .. tostring(err), vim.log.levels.ERROR)
	end
end
shared.map("n", "<leader>u", undo_picker, "Preview undo states (Enter to apply)")
-- Space Th: show other occurrences only while resting on a word.
do
	local enabled = false
	local function clear(win)
		if not vim.api.nvim_win_is_valid(win) then
			return
		end
		local id = vim.w[win].cursor_word_match
		if id then
			pcall(vim.fn.matchdelete, id, win)
			vim.w[win].cursor_word_match = nil
		end
	end
	local function highlight()
		if not enabled then
			return
		end
		local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
		if vim.bo[buf].buftype ~= "" or vim.b[buf].nopack_large_file or vim.fn.mode() ~= "n" then
			return
		end
		local word = vim.fn.expand("<cword>")
		if word == "" or vim.fn.matchstr(vim.api.nvim_get_current_line(), "\\%" .. vim.fn.col(".") .. "c\\k") == "" then
			return
		end
		clear(win)
		vim.w[win].cursor_word_match =
			vim.fn.matchadd("CursorWord", "\\C\\V\\<" .. vim.fn.escape(word, "\\") .. "\\>", -1)
	end
	vim.cmd("highlight default link CursorWord Visual")
	local group = vim.api.nvim_create_augroup("nopack-cursor-word", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			vim.cmd("highlight default link CursorWord Visual")
		end,
	})
	vim.api.nvim_create_autocmd("CursorHold", { group = group, callback = highlight })
	vim.api.nvim_create_autocmd(
		{ "CursorMoved", "InsertEnter", "ModeChanged", "WinLeave", "BufLeave", "TextChanged" },
		{
			group = group,
			callback = function()
				if enabled then
					clear(vim.api.nvim_get_current_win())
				end
			end,
		}
	)
	shared.map("n", "<leader>Th", function()
		enabled = not enabled
		if enabled then
			highlight()
		else
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				clear(win)
			end
		end
	end, "Toggle cursor word highlight")
end
-- Space Ti: 내장 들여쓰기 가이드와 탭·후행 공백 표시 토글.
shared.map("n", "<leader>Ti", "<Cmd>set list!<CR>", "Toggle indent guides / whitespace markers")
shared.map("n", "<leader>Tl", function()
	shared.language_status_visible = not shared.language_status_visible
	vim.cmd("redrawstatus")
end, "Toggle LSP / formatter status")

-- Space TS: animate native Ctrl-d/u views, including wrapped lines and folds.
do
	local enabled, animation = false, nil
	local keys_ns = vim.api.nvim_create_namespace("nopack-smooth-scroll")
	local function stop(finish)
		local state = animation
		animation = nil
		vim.on_key(nil, keys_ns)
		if
			finish
			and state
			and vim.api.nvim_get_current_win() == state.win
			and vim.api.nvim_get_current_buf() == state.buf
			and vim.api.nvim_buf_get_changedtick(state.buf) == state.tick
			and (not state.view or vim.deep_equal(state.view, vim.fn.winsaveview()))
		then
			vim.fn.winrestview(state.target)
		end
	end
	local function scroll(key)
		stop(true)
		local count = vim.v.count
		local keys = (count > 0 and tostring(count) or "") .. vim.keycode(key)
		local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
		if
			not enabled
			or vim.api.nvim_win_get_config(win).relative ~= ""
			or vim.wo[win].diff
			or vim.wo[win].scrollbind
			or vim.wo[win].cursorbind
			or vim.bo[buf].buftype ~= ""
			or vim.bo[buf].filetype == "netrw"
			or vim.b[buf].nopack_large_file
			or vim.fn.reg_executing() ~= ""
			or vim.fn.reg_recording() ~= ""
		then
			vim.cmd.normal({ keys, bang = true })
			return
		end
		local first = vim.fn.winsaveview()
		vim.cmd.normal({ keys, bang = true })
		local target, amount = vim.fn.winsaveview(), vim.wo[win].scroll
		if vim.deep_equal(first, target) then
			return
		end
		local frames, steps = {}, math.min(8, amount)
		-- Ask Neovim for intermediate views instead of guessing screen rows.
		for step = 1, steps - 1 do
			vim.fn.winrestview(first)
			vim.cmd.normal({ math.floor(amount * step / steps) .. vim.keycode(key), bang = true })
			frames[step] = vim.fn.winsaveview()
		end
		frames[steps] = target
		vim.wo[win][0].scroll = amount -- retain the native count / 'scroll' behavior
		vim.fn.winrestview(first)
		local state = { win = win, buf = buf, tick = vim.api.nvim_buf_get_changedtick(buf), target = target }
		local width, height = vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
		animation = state
		local step = 0
		local function advance()
			if animation ~= state then
				return
			end
			if
				vim.api.nvim_get_current_win() ~= win
				or vim.api.nvim_get_current_buf() ~= buf
				or vim.api.nvim_buf_get_changedtick(buf) ~= state.tick
				or vim.fn.mode() ~= "n"
				or vim.api.nvim_win_get_width(win) ~= width
				or vim.api.nvim_win_get_height(win) ~= height
				or state.view and not vim.deep_equal(state.view, vim.fn.winsaveview())
			then
				stop(false)
				return
			end
			step = step + 1
			vim.fn.winrestview(frames[step])
			vim.cmd("redraw")
			state.view = vim.fn.winsaveview()
			if step < steps then
				vim.defer_fn(advance, 16)
			else
				stop(false)
			end
		end
		-- Complete the pending move before processing the next key; never queue animations.
		vim.on_key(function()
			stop(true)
		end, keys_ns)
		advance()
	end
	shared.map("n", "<C-d>", function()
		scroll("<C-d>")
	end, "Scroll down half a page")
	shared.map("n", "<C-u>", function()
		scroll("<C-u>")
	end, "Scroll up half a page")
	shared.map("n", "<leader>TS", function()
		stop(true)
		enabled = not enabled
		vim.notify("Smooth scroll " .. (enabled and "enabled" or "disabled"))
	end, "Toggle smooth scroll")
	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "ModeChanged", "VimResized" }, {
		group = vim.api.nvim_create_augroup("nopack-smooth-scroll", { clear = true }),
		callback = function()
			stop(false)
		end,
	})
end
