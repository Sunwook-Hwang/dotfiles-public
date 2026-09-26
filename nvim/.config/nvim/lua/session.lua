-- -------------------------------------
-- Session management: persistence.nvim
-- -------------------------------------
require("persistence").setup({
	dir = (vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")) .. "/nvim/sessions/",
	branch = false,
})

-- Named auxiliary buffers must not become ordinary files on restore.
local excluded = {}
vim.api.nvim_create_autocmd("User", {
	pattern = "PersistenceSavePre",
	callback = function()
		excluded = {}
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "" then
				excluded[#excluded + 1] = buf
				vim.bo[buf].buflisted = false
			end
		end
	end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "PersistenceSavePost",
	callback = function()
		for _, buf in ipairs(excluded) do
			if vim.api.nvim_buf_is_valid(buf) then
				vim.bo[buf].buflisted = true
			end
		end
		excluded = {}
	end,
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
