-- =========================================
-- ======== COMPLETION / SNIPPETS ========
-- =========================================
-- Native completion and snippets; LSP automatic popup is enabled on attach.
-- Ctrl-Space: request, Ctrl-n/p: select, Enter: accept, Tab/Shift-Tab: snippet/completion.
vim.keymap.set("i", "<C-Space>", function()
	if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" }) > 0 then
		vim.lsp.completion.get()
	else
		vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
	end
end, { desc = "Complete from LSP or buffer" })
vim.keymap.set("i", "<CR>", function()
	return vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected >= 0 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Accept selected completion / newline" })
for key, direction in pairs({ ["<Tab>"] = 1, ["<S-Tab>"] = -1 }) do
	vim.keymap.set({ "i", "s" }, key, function()
		if vim.snippet.active({ direction = direction }) then
			vim.snippet.jump(direction)
		elseif vim.fn.pumvisible() == 1 then
			vim.api.nvim_feedkeys(vim.keycode(direction == 1 and "<C-n>" or "<C-p>"), "n", false)
		else
			vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
		end
	end, { desc = "Snippet tabstop / completion / " .. key })
end
-- Buffers without completion providers use words/tags; connected providers use the async engine.
local completion_buffers = {}
local function buffer_completion(buf)
	vim.bo[buf].autocomplete = vim.bo[buf].buftype == ""
		and not vim.b[buf].large_file
		and #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) == 0
	completion_buffers[buf] = vim.bo[buf].buftype
end
local pending_completion = {}
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "LspDetach" }, {
	callback = function(args)
		if
			pending_completion[args.buf]
			or (args.event == "BufEnter" and completion_buffers[args.buf] == vim.bo[args.buf].buftype)
		then
			return
		end
		pending_completion[args.buf] = true
		vim.schedule(function()
			pending_completion[args.buf] = nil
			if vim.api.nvim_buf_is_loaded(args.buf) then
				buffer_completion(args.buf)
			end
		end)
	end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
	callback = function(args)
		completion_buffers[args.buf], pending_completion[args.buf] = nil, nil
	end,
})

