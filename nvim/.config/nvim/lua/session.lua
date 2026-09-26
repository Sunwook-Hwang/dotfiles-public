-- -------------------------------------
-- Session management: persistence.nvim
-- -------------------------------------
require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
})

vim.keymap.set("n", "<leader>pr", function()
	require("persistence").load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>pl", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>pd", function()
	require("persistence").stop()
end, { desc = "Stop saving session" })

vim.keymap.set("n", "<leader>pS", function()
	require("persistence").select()
end, { desc = "Select session" })
