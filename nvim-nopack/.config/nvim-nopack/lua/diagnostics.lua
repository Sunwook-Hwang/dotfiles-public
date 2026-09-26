local shared = require("state")

-- =========================================
-- ============= DIAGNOSTICS =============
-- =========================================
-- Space ld/lD/sd: 현재 줄/버퍼 목록/전체 목록. [d/]d: 이동, Space lt: 표시 토글.
shared.map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
shared.map("n", "<leader>lD", function()
	shared.location_picker("Buffer diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get(0)))
end, "Select buffer diagnostic")
shared.map("n", "<leader>sd", function()
	shared.location_picker("Diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get()))
end, "Select diagnostic")
shared.map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, "Previous diagnostic")
shared.map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, "Next diagnostic")
local diagnostics_enabled = true
shared.map("n", "<leader>lt", function()
	diagnostics_enabled = not diagnostics_enabled
	vim.diagnostic.enable(diagnostics_enabled)
end, "Toggle diagnostics")
