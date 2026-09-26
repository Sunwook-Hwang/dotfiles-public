local Snacks = require("snacks")

-- -------------------------------------
-- File explorer: use the same package / standard-library / project boundaries as offline.
-- -------------------------------------
do
	local function find_git_root(dir)
		local path = dir:gsub("/+$", "") .. "/"
		local packages, relative = path:match("^(.-/site%-packages/)(.*)$")
		if not packages then
			packages, relative = path:match("^(.-/dist%-packages/)(.*)$")
		end
		-- The first package directory is a browsing boundary, not evidence of Git ownership.
		-- A module directly in site-packages uses that directory as its boundary.
		local library_root = packages and (packages .. (relative:match("^[^/]+") or "")):gsub("/+$", "")
		local stop = library_root and vim.fs.dirname(library_root)
		local current = vim.fs.normalize(dir)
		local next_parent = vim.fs.parents(current)
		while current and current ~= stop do
			if vim.uv.fs_stat(current .. "/.git") then
				return current, library_root
			end
			-- Recognize the standard library by its contents, independent of Python version/layout.
			if
				not library_root
				and vim.fn.filereadable(current .. "/os.py") == 1
				and vim.fn.filereadable(current .. "/importlib/__init__.py") == 1
			then
				return nil, current
			end
			current = next_parent(nil, current)
		end
		return nil, library_root
	end

	local function find_project(dir)
		local git_root, library_root = find_git_root(dir)
		if git_root then
			return git_root, true, true
		end
		if library_root then
			return library_root, false, true
		end
		local marker = vim.fs.find({
			"CMakeLists.txt",
			"compile_commands.json",
			"Makefile",
			"package.json",
			"pyproject.toml",
			"Cargo.toml",
			"WORKSPACE",
			"WORKSPACE.bazel",
			"MODULE.bazel",
			"buf.yaml",
		}, { path = dir, upward = true, type = "file", limit = 1 })[1]
		return marker and vim.fs.dirname(marker) or dir, false, marker ~= nil
	end

	local roots = {}
	local function root_for(dir)
		if not roots[dir] then
			local root, _, recognized = find_project(dir)
			roots[dir] = { root = root, recognized = recognized }
		end
		return roots[dir]
	end
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("online-project-root", { clear = true }),
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			if vim.bo[args.buf].buftype ~= "" or file == "" then
				return
			end
			local dir = vim.fs.dirname(file)
			local cached = root_for(dir)
			if not cached.recognized then
				return
			end
			local root = cached.root
			if vim.fn.getcwd() ~= root then
				vim.cmd.lcd(vim.fn.fnameescape(root))
			end
			for _, explorer in ipairs(Snacks.picker.get({ source = "explorer", tab = true })) do
				if explorer:cwd() ~= root then
					explorer:set_cwd(root)
					explorer:find()
				end
			end
		end,
	})
	local function invalidate_roots()
		roots = {}
	end
	vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost", "TermClose" }, {
		group = "online-project-root",
		callback = invalidate_roots,
	})
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufFilePost" }, {
		group = "online-project-root",
		pattern = { ".git", "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml",
			"Cargo.toml", "WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel", "buf.yaml", "os.py", "__init__.py" },
		callback = invalidate_roots,
	})
	vim.api.nvim_create_autocmd("User", {
		group = "online-project-root",
		pattern = "OnlineRefresh",
		callback = invalidate_roots,
	})
	vim.api.nvim_create_user_command("OnlineRefresh", function()
		vim.api.nvim_exec_autocmds("User", { pattern = "OnlineRefresh", modeline = false })
		vim.api.nvim_exec_autocmds("BufEnter", { group = "online-project-root", buffer = 0, modeline = false })
		vim.cmd("redrawstatus")
	end, { desc = "Refresh project root and formatter availability" })
	vim.keymap.set("n", "<leader>e", function()
		local explorer = Snacks.picker.get({ source = "explorer", tab = true })[1]
		if explorer then
			explorer:close()
			return
		end
		local dir
		local wins = { vim.api.nvim_get_current_win() }
		vim.list_extend(wins, vim.api.nvim_tabpage_list_wins(0))
		for _, win in ipairs(wins) do
			local buf = vim.api.nvim_win_get_buf(win)
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.bo[buf].buftype == "" and name ~= "" then
				dir = vim.fs.dirname(name)
				break
			end
		end
		Snacks.explorer({ cwd = root_for(dir or vim.fn.getcwd()).root })
	end, { desc = "Toggle file explorer" })
end

