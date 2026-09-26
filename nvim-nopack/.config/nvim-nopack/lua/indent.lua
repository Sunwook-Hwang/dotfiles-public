vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", lead = " ", leadmultispace = "┊   ", trail = ".", extends = ">", precedes = "<" }
local function update_indent_guides()
	if vim.bo.buftype ~= "" or vim.bo.filetype == "netrw" then
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
