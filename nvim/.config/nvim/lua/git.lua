-- =========================================
-- ============ PLUGINS: SETUP =============
-- =========================================
-- -------------------------------------
-- Git signs + hunk operations
-- -------------------------------------
require("gitsigns").setup({
	current_line_blame_opts = { delay = 150 },
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},

	on_attach = function(bufnr)
		if vim.b[bufnr].large_file then
			return false
		end
		local gs = package.loaded.gitsigns
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
		end

		-- Hunk navigation (leader g n/p)
		map("n", "<leader>gn", function()
			gs.nav_hunk("next", { wrap = true })
		end, "Git: Next hunk")
		map("n", "<leader>gp", function()
			gs.nav_hunk("prev", { wrap = true })
		end, "Git: Prev hunk")
		-- Optional: bracket navigation
		-- map("n", "]h", function() gs.nav_hunk("next", { wrap = true }) end, "Git: Next hunk")
		-- map("n", "[h", function() gs.nav_hunk("prev", { wrap = true }) end, "Git: Prev hunk")

		-- Stage/Reset hunk (normal + visual)
		map("n", "<leader>gs", gs.stage_hunk, "Git: Stage hunk")
		map("v", "<leader>gs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, "Git: Stage selection")
		map("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")
		map("v", "<leader>gr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, "Git: Reset selection")

		-- Stage/Reset buffer
		map("n", "<leader>gS", gs.stage_buffer, "Git: Stage buffer")
		map("n", "<leader>gU", gs.undo_stage_hunk, "Git: Undo stage hunk")
		map("n", "<leader>gR", gs.reset_buffer, "Git: Reset buffer")

		-- Preview/Blame/Diff/Deleted
		map("n", "<leader>gv", gs.preview_hunk_inline, "Git: Preview hunk (inline)")
		map("n", "<leader>gB", function()
			gs.blame_line({ full = true })
		end, "Git: Blame (full)")
		map("n", "<leader>gd", gs.diffthis, "Git: Diff against index")
		map("n", "<leader>gD", function()
			gs.diffthis("~")
		end, "Git: Diff against last commit")
		map("n", "<leader>gt", gs.toggle_deleted, "Git: Toggle deleted")

		-- Text object (hunk)
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Git: inner hunk")
	end,
})
vim.keymap.set("n", "<leader>gb", function()
	local enabled = require("gitsigns").toggle_current_line_blame()
	vim.notify("Inline blame: " .. (enabled and "on" or "off"))
end, { desc = "Toggle inline blame" })
