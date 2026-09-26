local Snacks = require("snacks")

local terminal_cwd
local function toggle_bottom_terminal()
	terminal_cwd = terminal_cwd or vim.fn.getcwd()
	Snacks.terminal.toggle(nil, { cwd = terminal_cwd, count = 1 })
end

-- Keep a single bottom terminal even when the editor's cwd changes.
vim.keymap.set({ "n", "t" }, "<C-t>", toggle_bottom_terminal, { desc = "Toggle bottom terminal" })

-- Toggle lazygit independently of the bottom shell terminal.
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Toggle lazygit" })
