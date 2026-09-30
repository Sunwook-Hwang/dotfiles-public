local policy = require("buffer_policy")
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
	if not policy.is_source(buf) or not vim.bo[buf].modifiable then
		vim.notify("Open an editable file before formatting")
		return
	end
	if not policy.allows(buf) then
		vim.notify("Formatting skipped: large-file protection is active")
		return
	end
	require("conform").format({ bufnr = buf, async = true })
end, { desc = "Format buffer with Conform" })

-- Formatter availability belongs to formatting, including its invalidation lifecycle.
local M = {}
local format_status_cache = {}
vim.api.nvim_create_autocmd({ "FileType", "BufFilePost", "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("pack-format-status", { clear = true }),
	callback = function(args)
		format_status_cache[args.buf] = nil
	end,
})
local function invalidate_format_status()
	format_status_cache = {}
end
vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost", "TermLeave", "TermClose" }, {
	group = "pack-format-status",
	callback = invalidate_format_status,
})
vim.api.nvim_create_autocmd("User", {
	group = "pack-format-status",
	pattern = "PackRefresh",
	callback = invalidate_format_status,
})
for _, event in ipairs({ "package:install:success", "package:uninstall:success" }) do
	require("mason-registry"):on(event, vim.schedule_wrap(invalidate_format_status))
end
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufWipeout" }, {
	group = "pack-format-status",
	callback = function(args)
		format_status_cache[args.buf] = nil
		if args.event ~= "BufWipeout" then
			-- LspDetach fires before the client is removed from the buffer.
			vim.schedule(function()
				format_status_cache[args.buf] = nil
			end)
		end
	end,
})

function M.status(buf, win)
	if not policy.is_source(buf) then
		return ""
	end
	if not vim.bo[buf].modifiable or not policy.allows(buf) then
		return "[FORMAT X]"
	end
	-- Conform probes executable paths and project roots; do not repeat on every redraw.
	local cwd = vim.fn.getcwd(vim.fn.win_id2win(win))
	local by_cwd = format_status_cache[buf] or {}
	if by_cwd[cwd] then
		return by_cwd[cwd]
	end
	local formatters, lsp = require("conform").list_formatters_to_run(buf)
	local names = {}
	for _, formatter in ipairs(formatters) do
		names[vim.fn.fnamemodify(formatter.command, ":t"):gsub("[%c]", " ")] = true
	end
	if lsp then
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })) do
			if not client:is_stopped() then
				names[client.name:gsub("[%c]", " ")] = true
			end
		end
	end
	local sorted = vim.fn.sort(vim.tbl_keys(names))
	local text = #sorted > 0 and ("[FORMAT: " .. table.concat(sorted, ", ") .. "]") or "[FORMAT X]"
	by_cwd[cwd] = text
	format_status_cache[buf] = by_cwd
	return text
end

return M
