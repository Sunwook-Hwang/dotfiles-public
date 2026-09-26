-- LSP breadcrumbs without Treesitter or font icons.
do
	local enabled = true
	local expression = "%{%v:lua.dropbar()%}"
	local path_cache = {}
	local path_source = {
		get_symbols = function(buf, win, cursor)
			local key = { buf, vim.api.nvim_buf_get_name(buf), vim.fn.getcwd(win), vim.bo[buf].modified }
			local cached = path_cache[win]
			if not cached or not vim.deep_equal(cached.key, key) then
				cached = { key = key, symbols = require("dropbar.sources.path").get_symbols(buf, win, cursor) }
				path_cache[win] = cached
			end
			-- Bars truncate symbols and attach menus; give each draw fresh instances.
			return vim.tbl_map(function(symbol)
				return symbol:merge({})
			end, cached.symbols)
		end,
	}
	local group = vim.api.nvim_create_augroup("online-dropbar", { clear = true })
	vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost", "TermClose" }, {
		group = group,
		callback = function()
			path_cache = {}
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		callback = function(args)
			path_cache[tonumber(args.match)] = nil
		end,
	})
	local function eligible(buf, win)
		return enabled
			and vim.bo[buf].buftype == ""
			and vim.api.nvim_buf_get_name(buf) ~= ""
			and not vim.b[buf].large_file
			and vim.api.nvim_win_get_config(win).relative == ""
			and (vim.wo[win].winbar == "" or vim.wo[win].winbar == expression)
	end
	require("dropbar").setup({
		sources = { path = { preview = false } },
		icons = {
			enable = false,
			ui = { bar = { separator = " > ", extends = "..." }, menu = { indicator = "> " } },
		},
		bar = {
			enable = eligible,
			-- The LSP source also uses these events to request document symbols.
			update_events = { buf = { "TextChanged", "FileChangedShellPost", "BufFilePost" } },
			sources = function()
				local sources = require("dropbar.sources")
				return { path_source, sources.lsp }
			end,
		},
	})
	local function refresh_window(win)
		local buf = vim.api.nvim_win_get_buf(win)
		if eligible(buf, win) then
			if vim.wo[win].winbar ~= expression then
				vim.wo[win][0].winbar = expression
			end
		elseif vim.wo[win].winbar == expression then
			vim.wo[win][0].winbar = ""
		end
	end
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = group,
		callback = function()
			refresh_window(vim.api.nvim_get_current_win())
		end,
	})
	vim.keymap.set("n", "<leader>Td", function()
		enabled = not enabled
		path_cache = {}
		if not enabled then
			local bars = {}
			for _, windows in pairs(require("dropbar.utils.bar").get()) do
				for _, bar in pairs(windows) do
					bars[#bars + 1] = bar
				end
			end
			for _, bar in ipairs(bars) do
				-- Invalidate queued updates before removing the hidden bar.
				bar.last_update_request_time = nil
				bar:del()
			end
		end
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			refresh_window(win)
		end
	end, { desc = "Toggle breadcrumb bar" })
end

