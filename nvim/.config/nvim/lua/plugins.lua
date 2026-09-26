-- =========================================
-- ============ NATIVE PACKAGES ============
-- =========================================
local packages = {
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/persistence.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },

	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/Bekaboo/dropbar.nvim" },

	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
}

-- Load at startup; configure dependencies before their consumers below.
-- Update plugins with :lua vim.pack.update()
vim.pack.add(packages, { confirm = false })
