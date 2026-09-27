-- Persistent outline with cursor tracking in both directions.
local policy = require("buffer_policy")
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
	ignore = {
		buftypes = function(buf)
			return not policy.allows(buf)
		end,
	},
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
						if policy.allows(buf) and require("aerial").is_open() then
							return callback(args)
						end
					end,
				})
			end
		end
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("PackOutlinePolicy", { clear = true }),
	pattern = "PackBufferRestricted",
	callback = function(args)
		local backends = package.loaded["aerial.backends"]
		local name = backends and backends.get_attached_backend(args.data.buf)
		if name then
			backends.get_backend_by_name(name).detach(args.data.buf)
			vim.b[args.data.buf].aerial_backend = nil
		end
	end,
})
vim.keymap.set("n", "<leader>o", function()
	if policy.allows(0) or require("aerial").is_open() then
		vim.cmd("AerialToggle")
	end
end, { desc = "Toggle symbols outline" })
