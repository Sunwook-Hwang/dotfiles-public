vim.o.laststatus = 0
vim.o.cmdheight = 0
vim.o.showtabline = 0
vim.o.showmode = false
vim.o.ruler = false

vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = "no"


-- vim.o.guifont = "JetBrainsMono Nerd Font:h18"

-- Disable cursor animations/effects
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_vfx_mode = nil

vim.g.neovide_scale_factor = 1.0

local function change_scale(delta)
    local new = vim.g.neovide_scale_factor * (1 + delta)
    if new < 0.3 then
        new = 0.3
    end
    vim.g.neovide_scale_factor = new
end

-- Windows/Linux
vim.keymap.set({ "n", "i", "v" }, "<C-=>", function()
    change_scale(0.10)
end, { desc = "Zoom In (Neovide)" })
vim.keymap.set({ "n", "i", "v" }, "<C-->", function()
    change_scale(-0.10)
end, { desc = "Zoom Out (Neovide)" })
vim.keymap.set({ "n", "i", "v" }, "<C-0>", function()
    vim.g.neovide_scale_factor = 1.0
end, { desc = "Zoom Reset (Neovide)" })

-- macOS
vim.keymap.set({ "n", "i", "v" }, "<D-=>", function()
    change_scale(0.10)
end, { desc = "Zoom In (Neovide macOS)" })
vim.keymap.set({ "n", "i", "v" }, "<D-->", function()
    change_scale(-0.10)
end, { desc = "Zoom Out (Neovide macOS)" })
vim.keymap.set({ "n", "i", "v" }, "<D-0>", function()
    vim.g.neovide_scale_factor = 1.0
end, { desc = "Zoom Reset (Neovide macOS)" })

-- terminal 열기
vim.cmd("terminal")
vim.cmd("startinsert")
