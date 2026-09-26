-- Persistent outline with cursor tracking in both directions.
require("aerial").setup({
	lazy_load = true,
	backends = { "lsp", "markdown", "asciidoc", "man" },
	layout = { default_direction = "right", max_width = { 40, 0.25 } },
	attach_mode = "global",
	autojump = true,
	close_on_select = false,
	show_guides = true,
	nerd_font = false,
	icons = { Collapsed = ">" },
	on_attach = function(buf)
		-- Aerial keeps its cursor listener after closing; only track a visible outline.
		for _, autocmd in
			ipairs(vim.api.nvim_get_autocmds({ group = "AerialBuffer", event = "CursorMoved", buffer = buf }))
		do
			local callback = autocmd.callback
			if type(callback) == "function" then
				vim.api.nvim_del_autocmd(autocmd.id)
				vim.api.nvim_create_autocmd("CursorMoved", {
					group = "AerialBuffer",
					buffer = buf,
					desc = autocmd.desc,
					callback = function(args)
						if require("aerial").is_open() then
							return callback(args)
						end
					end,
				})
			end
		end
	end,
})
vim.keymap.set("n", "<leader>o", "<Cmd>AerialToggle<CR>", { desc = "Toggle symbols outline" })
