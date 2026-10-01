local policy = require("buffer_policy")
local shared = require("state")

local handlers = {
	["textDocument/diagnostic"] = function(err, result, ctx)
		-- Cancellation is advisory: an older response can arrive after newer edits.
		-- Reject it before the native handler changes diagnostics or resultId state.
		if
			not policy.allows(ctx.bufnr)
			or (ctx.version ~= nil and ctx.version ~= vim.lsp.util.buf_versions[ctx.bufnr])
		then
			return
		end
		return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
	end,
}

-- =========================================
-- ============= DIAGNOSTICS =============
-- =========================================
-- Space ld/lD/sd: 현재 줄/버퍼 목록/전체 목록. [d/]d: 이동, Space lt: 표시 토글.
shared.map("n", "<leader>ld", policy.guard(vim.diagnostic.open_float), "Line diagnostics")
shared.map(
	"n",
	"<leader>lD",
	policy.guard(function()
		shared.location_picker("Buffer diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get(0)))
	end),
	"Select buffer diagnostic"
)
shared.map("n", "<leader>sd", function()
	shared.location_picker("Diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get()))
end, "Select diagnostic")
shared.map(
	"n",
	"[d",
	policy.guard(function()
		vim.diagnostic.jump({ count = -1 })
	end),
	"Previous diagnostic"
)
shared.map(
	"n",
	"]d",
	policy.guard(function()
		vim.diagnostic.jump({ count = 1 })
	end),
	"Next diagnostic"
)
local diagnostics_enabled = true
shared.map("n", "<leader>lt", function()
	diagnostics_enabled = not diagnostics_enabled
	vim.diagnostic.enable(diagnostics_enabled)
end, "Toggle diagnostics")

return { handlers = handlers }
