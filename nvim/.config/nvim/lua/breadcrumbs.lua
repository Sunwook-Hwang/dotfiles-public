local policy = require("buffer_policy")
local Snacks = require("snacks")

-- LSP breadcrumbs without Treesitter or font icons.
do
	local enabled = true
	local symbol_source = require("breadcrumb_symbols").setup(function()
		return enabled
	end)
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
	local group = vim.api.nvim_create_augroup("pack-dropbar", { clear = true })
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
			and policy.allows(buf)
			and vim.api.nvim_buf_get_name(buf) ~= ""
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
			-- Bar redraws are separate from the symbol source's request lifecycle.
			update_events = { buf = { "TextChanged", "FileChangedShellPost", "BufFilePost" } },
			sources = function()
				return { path_source, symbol_source }
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
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "PackBufferRestricted",
		callback = function(args)
			symbol_source.clear(args.data.buf)
			local bars = vim.tbl_values(require("dropbar.utils.bar").get({ buf = args.data.buf }))
			for _, bar in ipairs(bars) do
				bar.last_update_request_time = nil
				bar:del()
			end
			for _, win in ipairs(vim.fn.win_findbuf(args.data.buf)) do
				path_cache[win] = nil
				refresh_window(win)
			end
		end,
	})
	Snacks.toggle({
		name = "Breadcrumb bar",
		get = function()
			return enabled
		end,
		set = function(state)
			enabled = state
			path_cache = {}
			if not enabled then
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					symbol_source.clear(buf)
				end
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
		end,
	}):map("<leader>Td")
end
