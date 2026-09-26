local shared = require("state")

-- =========================================
-- ======= LSP: SERVER DEFINITIONS =======
-- =========================================
-- Neovim 0.12 내장 클라이언트. 아래 목록의 실행 파일이 이미 설치되어 있어야 합니다.
-- PATH → 기존 stdpath(data)/mason/bin 순서.
-- Mason 로드·자동 설치는 하지 않습니다.
local tsserver = shared.resolve_tool("tsserver")
local servers = {
	{ cmd = { "clangd" }, ft = { "c", "cpp", "objc", "objcpp", "cuda" } },
	{ cmd = { "mlir-lsp-server" }, ft = { "mlir" } },
	{ cmd = { "starpls", "server" }, ft = { "bzl" } },
	{ cmd = { "buf", "lsp", "serve" }, ft = { "proto" } },
	{ cmd = { "bash-language-server", "start" }, ft = { "sh" } },
	{
		alternatives = { { "neocmakelsp", "stdio" }, { "cmake-language-server" } },
		ft = { "cmake" },
	},
	{ cmd = { "yaml-language-server", "--stdio" }, ft = { "yaml" } },
	{ cmd = { "texlab" }, ft = { "tex", "plaintex" } },
	{ cmd = { "rust-analyzer" }, ft = { "rust" } },
	{ alternatives = { { "ty", "server" }, { "pyright-langserver", "--stdio" } }, ft = { "python" } },
	{ cmd = { "lua-language-server" }, ft = { "lua" }, settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
	{
		cmd = { "typescript-language-server", "--stdio" },
		init_options = tsserver ~= "" and { tsserver = { fallbackPath = tsserver } } or nil,
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	{ cmd = { "vscode-html-language-server", "--stdio" }, ft = { "html" } },
	{ cmd = { "vscode-css-language-server", "--stdio" }, ft = { "css", "scss", "less" } },
	{
		cmd = { "tailwindcss-language-server", "--stdio" },
		markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts" },
		dependency = "tailwindcss",
		ft = { "html", "css", "javascriptreact", "typescriptreact", "svelte" },
	},
	{ cmd = { "svelteserver", "--stdio" }, ft = { "svelte" } },
	{ cmd = { "graphql-lsp", "server", "-m", "stream" }, ft = { "graphql" } },
	{
		cmd = { "emmet-ls", "--stdio" },
		ft = { "html", "css", "javascriptreact", "typescriptreact" },
		markers = { ".emmet.json", "emmet.json" },
	},
	{ cmd = { "prisma-language-server", "--stdio" }, ft = { "prisma" } },
	{
		cmd = { "vscode-eslint-language-server", "--stdio" },
		markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			".eslintrc",
			".eslintrc.json",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yml",
			".eslintrc.yaml",
		},
		dependency = "eslint",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
}
-- =========================================
-- ====== PYTHON: INTERPRETER PICKER ======
-- =========================================
-- Space lv: 현재 프로젝트의 Python LSP 분석 환경 선택. 재실행 전까지 프로젝트별로 기억합니다.
-- 가상환경을 생성하거나 셸/포맷터 PATH를 바꾸지 않습니다. symlink 경로는 그대로 보존합니다.
local python_paths = {}
local function apply_python_path(client, path)
	client.settings = vim.deepcopy(client.settings)
	if client.name == "ty" then
		client.settings.ty = client.settings.ty or {}
		client.settings.ty.configuration = client.settings.ty.configuration or {}
		local configuration = client.settings.ty.configuration
		configuration.environment = configuration.environment or {}
		configuration.environment.python = path
		if not next(configuration.environment) then
			configuration.environment = vim.empty_dict()
		end
	else
		client.settings.python = client.settings.python or vim.empty_dict()
		client.settings.python.pythonPath = path
	end
	client.config.settings = client.settings
end
shared.map("n", "<leader>lv", function()
	if vim.bo.filetype ~= "python" then
		vim.notify("Open a Python file to select its environment")
		return
	end
	local root = shared.project_root()
	local choices, seen = {}, {}
	local function add(label, path)
		if path and path ~= "" and not seen[path] and vim.fn.executable(path) == 1 then
			seen[path] = true
			choices[#choices + 1] = { label = label .. ": " .. path, path = path }
		end
	end
	add("Selected", python_paths[root])
	add("Project .venv", root .. "/.venv/bin/python")
	add("Project venv", root .. "/venv/bin/python")
	add("Active venv", vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python")
	add("Active Conda", vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX .. "/bin/python")
	add("PATH python", vim.fn.exepath("python"))
	add("PATH python3", vim.fn.exepath("python3"))
	choices[#choices + 1] = { label = "Enter Python path...", manual = true }
	choices[#choices + 1] = { label = "Automatic (project settings / inherited PATH)" }
	local function select_path(path)
		local changed = python_paths[root] ~= path
		python_paths[root] = path
		local attached, restarting = false, false
		for _, client in ipairs(vim.lsp.get_clients()) do
			if (client.name == "ty" or client.name == "pyright-langserver") and client.config.root_dir == root then
				attached = true
				if changed then
					if client.name == "ty" then
						-- Restart ty so versions without didChangeConfiguration also reload imports.
						local buffers = vim.tbl_keys(client.attached_buffers)
						local config = vim.deepcopy(client.config)
						client:stop(true)
						local id = vim.lsp.start(config, { attach = false })
						if id then
							for _, buf in ipairs(buffers) do
								if vim.api.nvim_buf_is_loaded(buf) and not vim.b[buf].nopack_large_file then
									vim.lsp.buf_attach_client(buf, id)
								end
							end
						end
						restarting = id ~= nil
					else
						apply_python_path(client, path)
						client:notify("workspace/didChangeConfiguration", { settings = client.settings })
					end
				end
			end
		end
		vim.notify(
			"Python: "
				.. (path or "automatic")
				.. (restarting and " (restarting ty)" or (attached and "" or " (applies when Python LSP attaches)"))
		)
	end
	local function choose(item)
		if not item then
			return
		end
		if not item.manual then
			select_path(item.path)
			return
		end
		vim.ui.input({ prompt = "Python executable or venv directory: ", completion = "file" }, function(path)
			if not path or path == "" then
				return
			end
			path = vim.fs.normalize(path)
			if path:sub(1, 1) ~= "/" then
				path = vim.fs.normalize(root .. "/" .. path)
			end
			if vim.fn.isdirectory(path) == 1 then
				path = path .. "/bin/python"
			end
			if vim.fn.executable(path) ~= 1 then
				vim.notify("Python executable not found: " .. path, vim.log.levels.WARN)
				return
			end
			select_path(path)
		end)
	end
	local function items()
		return vim.tbl_map(function(choice)
			return {
				label = choice.label,
				action = function()
					choose(choice)
				end,
			}
		end, choices)
	end
	local picker = shared.open_picker("Python environment: " .. vim.fn.fnamemodify(root, ":t"), {
		items = items(),
		cancel = function()
			shared.cancel_command("conda-envs")
		end,
	})
	local conda = vim.fn.exepath("conda")
	if conda == "" and vim.env.CONDA_EXE and vim.fn.executable(vim.env.CONDA_EXE) == 1 then
		conda = vim.env.CONDA_EXE
	end
	if conda ~= "" then
		shared.run_command(
			"conda-envs",
			{ conda, "env", "list", "--json" },
			{ cwd = root, quiet = true },
			function(output)
				if picker.closed then
					return
				end
				local ok, result = pcall(vim.json.decode, output)
				if not ok or type(result) ~= "table" or type(result.envs) ~= "table" then
					return
				end
				for _, env in ipairs(result.envs) do
					if type(env) == "string" then
						local path = vim.fs.normalize(env)
						add("Conda " .. vim.fs.basename(path), path .. "/bin/python")
					end
				end
				picker.set_items(items())
			end
		)
	end
end, "Select Python environment for this project")
-- =========================================
-- ==== LSP: COMPLETION / BUFFER KEYS ====
-- =========================================
-- 서버 연결 시 자동완성과 파일 버퍼 전용 키를 설정합니다.
-- gd/gr/gD/K: 직접 이동·조회; gR/gi/gt: picker; Space la/lr/Tr: 액션·이름 변경·심볼.
local function attach(client, buf)
	if vim.b[buf].nopack_large_file then
		vim.lsp.buf_detach_client(buf, client.id)
		return
	end
	-- gd handles provider selection; native tag operations must read the ctags file.
	vim.bo[buf].tagfunc = ""
	if client:supports_method("textDocument/completion") then
		-- Use server-defined triggers; Ctrl-Space requests completion explicitly.
		vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
		vim.bo[buf].autocomplete = false
	end
	local actions = {
		gr = "references",
		gD = "declaration",
		K = "hover",
		["<leader>lr"] = "rename",
	}
	-- Direct jumps stay direct; the original Telescope mappings remain selectable lists.
	for key, method in pairs({ gR = "references", gi = "implementation", gt = "type_definition" }) do
		vim.keymap.set("n", key, function()
			local opts = {
				on_list = function(list)
					shared.location_picker(method, list.items)
				end,
			}
			if method == "references" then
				vim.lsp.buf.references(nil, opts)
			else
				vim.lsp.buf[method](opts)
			end
		end, { buf = buf, desc = "Select LSP " .. method })
	end
	for key, action in pairs(actions) do
		vim.keymap.set("n", key, vim.lsp.buf[action], { buf = buf, desc = "LSP: " .. action })
	end
	vim.keymap.set({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { buf = buf, desc = "Code action" })
end
-- =========================================
-- ======== LSP: RESOLVE / ENABLE ========
-- =========================================
-- 실행 파일 탐색 후 vim.lsp.config/enable로 해당 언어 파일에 연결합니다.
-- 큰 파일은 연결하지 않습니다. Space ls는 현재 버퍼의 클라이언트만 재시작합니다.
-- Auxiliary servers need project evidence; primary language servers also support standalone files.
local function project_uses_server(server, dir)
	if not server.markers or vim.fs.root(dir, server.markers) then
		return true
	end
	if not server.dependency then
		return false
	end
	for _, path in ipairs(vim.fs.find("package.json", { path = dir, upward = true, type = "file", limit = math.huge })) do
		local file = io.open(path, "r")
		if file then
			local content = file:read(65536)
			file:close()
			local ok, package = pcall(vim.json.decode, content or "")
			if ok and type(package) == "table" then
				for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies" }) do
					if type(package[field]) == "table" and package[field][server.dependency] then
						return true
					end
				end
				if server.dependency == "eslint" and package.eslintConfig then
					return true
				end
			end
		end
	end
	return false
end
for _, server in ipairs(servers) do
	local spec, executable
	for _, candidate in ipairs(server.alternatives or { server.cmd }) do
		local path = shared.resolve_tool(candidate[1])
		if path ~= "" then
			spec, executable = candidate, path
			break
		end
	end
	if spec then
		local name = spec[1]
		local command = vim.deepcopy(spec)
		command[1] = executable
		vim.lsp.config(name, {
			cmd = command,
			filetypes = server.ft,
			settings = server.settings,
			init_options = server.init_options,
			on_init = function(client)
				if client.name == "ty" or client.name == "pyright-langserver" then
					-- Apply once before workspace/configuration and didOpen, including pending starts.
					apply_python_path(client, python_paths[client.config.root_dir])
				end
			end,
			on_attach = attach,
			root_dir = function(buf, on_dir)
				if vim.b[buf].nopack_large_file then
					return
				end
				local file = vim.api.nvim_buf_get_name(buf)
				if file == "" or not project_uses_server(server, vim.fs.dirname(file)) then
					return
				end
				on_dir((shared.find_project(vim.fs.dirname(file))))
			end,
		})
		vim.lsp.enable(name)
	end
end
shared.map("n", "<leader>ls", "<Cmd>lsp restart<CR>", "Restart current buffer LSP clients")

-- :edit opens a buffer before a file exists. Only its first successful write
-- needs a directory refresh and recovery of ty's cached missing-module state.
do
	local writes, pending_files, pending_clients = {}, {}, {}
	local scheduled = false
	local group = vim.api.nvim_create_augroup("nopack-new-file", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(args)
			writes[args.buf] = nil
			if vim.bo[args.buf].buftype ~= "" then
				return
			end
			local stat, _, code = vim.uv.fs_stat(args.match)
			if not stat and code == "ENOENT" then
				writes[args.buf] = {
					file = args.match,
					clients = vim.bo[args.buf].filetype == "python"
							and vim.lsp.get_clients({ bufnr = args.buf, name = "ty" })
						or {},
				}
			end
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(args)
			writes[args.buf] = nil
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(args)
			local write = writes[args.buf]
			writes[args.buf] = nil
			if not write or write.file ~= args.match or not vim.uv.fs_stat(write.file) then
				return
			end
			pending_files[write.file] = true
			for _, client in ipairs(write.clients) do
				pending_clients[client.id] = client
			end
			if scheduled then
				return
			end
			scheduled = true
			vim.schedule(function()
				local files, clients = pending_files, pending_clients
				pending_files, pending_clients, scheduled = {}, {}, false
				-- Batch :wall into one restart per affected ty instance. Reattach
				-- its loaded buffers without reloading files or changing their text.
				for _, client in pairs(clients) do
					if not client:is_stopped() then
						local attached = vim.tbl_keys(client.attached_buffers)
						local config = vim.deepcopy(client.config)
						client:stop(true)
						local id = vim.lsp.start(config, { attach = false })
						if id then
							for _, buf in ipairs(attached) do
								if vim.api.nvim_buf_is_loaded(buf) and not vim.b[buf].nopack_large_file then
									vim.lsp.buf_attach_client(buf, id)
								end
							end
						end
					end
				end
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "netrw" then
						local top = shared.netrw_git_top(win, buf)
						top = vim.uv.fs_realpath(top) or vim.fs.normalize(top)
						for file in pairs(files) do
							file = vim.uv.fs_realpath(file) or vim.fs.normalize(file)
							if vim.startswith(file, top:gsub("/+$", "") .. "/") then
								vim.api.nvim_win_call(win, function()
									-- Refresh expanded subdirectories too, retaining the tree/view.
									shared.netrw_refresh()
								end)
								break
							end
						end
					end
				end
			end)
		end,
	})
end
