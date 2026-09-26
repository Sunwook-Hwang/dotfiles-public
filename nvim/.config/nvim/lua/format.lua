-- -------------------------------------
-- Formatting: conform.nvim (manual)
-- -------------------------------------
require("conform").setup({
	notify_on_error = false,
	default_format_opts = { lsp_format = "fallback" },
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		cuda = { "clang_format" },
		python = { "ruff_format", "black", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		less = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
		graphql = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		handlebars = { "prettierd", "prettier", stop_after_first = true },
		bzl = { "buildifier" },
		proto = { "buf", "clang_format", stop_after_first = true },
		sh = { "shfmt" },
		cmake = { "cmake_format" },
		tex = { "latexindent" },
		plaintex = { "latexindent" },
		rust = { "rustfmt" },
	},
})
vim.keymap.set("n", "<leader>lf", function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable then
		vim.notify("Open an editable file before formatting")
		return
	end
	if vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 2 * 1024 * 1024 then
		vim.notify("Formatting skipped: file exceeds 2 MiB")
		return
	end
	require("conform").format({ bufnr = buf, async = true })
end, { desc = "Format buffer with Conform" })
