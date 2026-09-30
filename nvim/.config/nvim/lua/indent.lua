local policy = require("buffer_policy")
vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", lead = " ", leadmultispace = "┊   ", trail = ".", extends = ">", precedes = "<" }
local function update_indent_guides()
	if not policy.allows(0) then
		vim.opt_local.listchars:remove("leadmultispace")
		return
	end
	local width = vim.fn.shiftwidth()
	vim.opt_local.listchars:append({ leadmultispace = "┊" .. string.rep(" ", width - 1) })
end
local indent_group = vim.api.nvim_create_augroup("nopack-indent-guides", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = indent_group,
	callback = update_indent_guides,
})
vim.api.nvim_create_autocmd("OptionSet", {
	group = indent_group,
	pattern = { "shiftwidth", "tabstop", "vartabstop" },
	callback = update_indent_guides,
})

vim.api.nvim_create_autocmd("User", {
	group = indent_group,
	pattern = "NopackBufferRestricted",
	callback = function(args)
		for _, win in ipairs(vim.fn.win_findbuf(args.data.buf)) do
			vim.api.nvim_win_call(win, update_indent_guides)
		end
	end,
})
