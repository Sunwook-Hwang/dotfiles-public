local Snacks = require("snacks")

-- -------------------------------------
-- LSP: native client and buffer mappings
-- -------------------------------------
do
	local keymap = vim.keymap
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if vim.b[ev.buf].large_file then
				vim.lsp.buf_detach_client(ev.buf, client.id)
				return
			end
			if client:supports_method("textDocument/completion") then
				local completion = client.server_capabilities.completionProvider
				completion.triggerCharacters = completion.triggerCharacters or {}
				-- Also open completion while typing identifiers, not just after server punctuation.
				for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
					if not vim.tbl_contains(completion.triggerCharacters, char) then
						table.insert(completion.triggerCharacters, char)
					end
				end
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
				vim.bo[ev.buf].autocomplete = false
			end
			vim.diagnostic.enable(true, { bufnr = ev.buf })
			local opts = { buffer = ev.buf, silent = true }

			opts.desc = "Go to definition"
			keymap.set("n", "gd", function()
				Snacks.picker.lsp_definitions()
			end, opts)

			opts.desc = "References"
			keymap.set("n", "gr", function()
				Snacks.picker.lsp_references()
			end, opts)

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", function()
				Snacks.picker.lsp_references()
			end, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", function()
				Snacks.picker.lsp_declarations()
			end, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", function()
				Snacks.picker.lsp_implementations()
			end, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", function()
				Snacks.picker.lsp_type_definitions()
			end, opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = false })
			end, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = false })
			end, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>ls", "<Cmd>lsp restart<CR>", opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>lD", function()
				Snacks.picker.diagnostics_buffer()
			end, opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
		end,
	})

	-- Diagnostic config (default)
	vim.diagnostic.config({})

	-- Generic default for all servers configured below
	vim.lsp.config("*", {
		capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
			workspace = {
				fileOperations = {
					didCreate = true,
					willCreate = true,
					didRename = true,
					willRename = true,
					didDelete = true,
					willDelete = true,
				},
			},
		}),
	})

	-- Diagnostics toggle (global)
	vim.diagnostic.enable(true, {})
	local diagnostics = Snacks.toggle.diagnostics()
	vim.api.nvim_create_user_command("ToggleDiagnostics", function()
		diagnostics:toggle()
	end, {})
	diagnostics:map("<leader>lt")
end
-- -------------------------------------
-- LSP server definitions and Mason installation
-- -------------------------------------
-- Python projects use the same Git-first root discovery as nvim-nopack/init.lua.
local function python_project_root(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	local dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	local root = vim.fs.root(dir, ".git")
	if root then
		return root
	end
	local marker = vim.fs.find(
		{ "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml" },
		{ path = dir, upward = true, type = "file", limit = 1 }
	)[1]
	return marker and vim.fs.dirname(marker) or dir
end

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
vim.keymap.set("n", "<leader>lv", function()
	if vim.bo.filetype ~= "python" then
		vim.notify("Open a Python file to select its environment")
		return
	end
	local root = python_project_root(0)
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
			if (client.name == "ty" or client.name == "pyright") and client.config.root_dir == root then
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
								if vim.api.nvim_buf_is_loaded(buf) and not vim.b[buf].large_file then
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
	local function show_picker()
		vim.ui.select(choices, {
			prompt = "Python environment: " .. vim.fn.fnamemodify(root, ":t"),
			format_item = function(item)
				return item.label
			end,
		}, choose)
	end
	local conda = vim.fn.exepath("conda")
	if conda == "" and vim.env.CONDA_EXE and vim.fn.executable(vim.env.CONDA_EXE) == 1 then
		conda = vim.env.CONDA_EXE
	end
	if conda == "" then
		show_picker()
		return
	end
	vim.system({ conda, "env", "list", "--json" }, { cwd = root, text = true, timeout = 5000 }, function(result)
		vim.schedule(function()
			local ok, data = pcall(vim.json.decode, result.stdout or "")
			if result.code == 0 and ok and type(data) == "table" and type(data.envs) == "table" then
				for _, env in ipairs(data.envs) do
					if type(env) == "string" then
						local path = vim.fs.normalize(env)
						add("Conda " .. vim.fs.basename(path), path .. "/bin/python")
					end
				end
			end
			show_picker()
		end)
	end)
end, { desc = "Select Python environment for this project" })

-- Prefer PATH tools; append Mason's installed executables as a fallback.
require("mason").setup({
	PATH = "append",
	ui = { icons = { package_installed = "OK", package_pending = "...", package_uninstalled = "-" } },
})
local servers = {
	clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", ".git" },
	},
	mlir_lsp_server = {
		cmd = { "mlir-lsp-server" },
		filetypes = { "mlir" },
		root_markers = { "CMakeLists.txt", ".git" },
	},
	starpls = {
		cmd = { "starpls", "server" },
		filetypes = { "bzl" },
		root_markers = { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE", "BUILD.bazel", "BUILD", ".git" },
	},
	buf_ls = {
		cmd = { "buf", "lsp", "serve" },
		filetypes = { "proto" },
		root_markers = { "buf.yaml", ".git" },
	},
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh" },
		root_markers = { ".git" },
	},
	neocmake = {
		cmd = { "neocmakelsp", "stdio" },
		filetypes = { "cmake" },
		root_markers = { "CMakeLists.txt", ".git" },
		init_options = { format = { enable = true }, lint = { enable = true } },
	},
	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml" },
		root_markers = { ".git" },
	},
	texlab = {
		cmd = { "texlab" },
		filetypes = { "tex", "plaintex" },
		root_markers = { ".latexmkrc", "latexmkrc", ".git" },
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	},
	ty = { cmd = { "ty", "server" }, filetypes = { "python" }, root_markers = { "pyproject.toml", "ty.toml", ".git" } },
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyrightconfig.json", "pyproject.toml", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				completion = { callSnippet = "Replace" },
				workspace = {
					checkThirdParty = false,
					library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), { "${3rd}/luv/library" }),
				},
			},
		},
	},
	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		init_options = { hostInfo = "neovim" },
		before_init = function(_, config)
			-- Prefer project TypeScript; use PATH/Mason's tsserver as a fallback.
			local tsserver = vim.fn.exepath("tsserver")
			if tsserver ~= "" then
				config.init_options.tsserver = { fallbackPath = tsserver }
			end
		end,
	},
	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { "package.json", ".git" },
		init_options = {
			provideFormatter = true,
			embeddedLanguages = { css = true, javascript = true },
			configurationSection = { "html", "css", "javascript" },
		},
	},
	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { "package.json", ".git" },
		init_options = { provideFormatter = true },
		settings = { css = { validate = true }, scss = { validate = true }, less = { validate = true } },
	},
	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
		},
		root_markers = {
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.mjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.mjs",
			"postcss.config.cjs",
			"package.json",
		},
		workspace_required = true,
	},
	svelte = {
		cmd = { "svelteserver", "--stdio" },
		filetypes = { "svelte" },
		root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
		on_attach = function(client, buf)
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("svelte-changes-" .. client.id, { clear = true }),
				pattern = { "*.js", "*.ts" },
				callback = function(ctx)
					if client:is_stopped() then
						return true
					end
					client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
				end,
			})
		end,
	},
	graphql = {
		cmd = { "graphql-lsp", "server", "-m", "stream" },
		filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		root_markers = {
			".graphqlrc",
			".graphqlrc.json",
			".graphqlrc.yaml",
			".graphqlrc.yml",
			".graphqlrc.js",
			".graphqlrc.ts",
			"graphql.config.js",
			"graphql.config.ts",
			"graphql.config.yml",
			"graphql.config.yaml",
			"graphql.config.json",
		},
		workspace_required = true,
	},
	emmet_ls = {
		cmd = { "emmet-ls", "--stdio" },
		filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		root_markers = { ".git" },
	},
	prismals = {
		cmd = { "prisma-language-server", "--stdio" },
		filetypes = { "prisma" },
		settings = { prisma = { prismaFmtBinPath = "" } },
		root_markers = { "schema.prisma", "package.json", ".git" },
	},
	eslint = {
		cmd = { "vscode-eslint-language-server", "--stdio" },
		filetypes = {
			"html",
			"javascript",
			"typescript",
			"typescriptreact",
			"javascriptreact",
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
		},
		root_markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
			".eslintrc",
			".eslintrc.json",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yml",
			".eslintrc.yaml",
		},
		workspace_required = true,
		settings = {
			validate = "on",
			useESLintClass = false,
			experimental = {},
			format = true,
			quiet = false,
			codeActionOnSave = { enable = false, mode = "all" },
			onIgnoredFiles = "off",
			rulesCustomizations = {},
			run = "onType",
			problems = { shortenToSingleLine = false },
			nodePath = "",
			workingDirectory = { mode = "auto" },
			codeAction = {
				disableRuleComment = { enable = true, location = "separateLine" },
				showDocumentation = { enable = true },
			},
		},
		before_init = function(_, config)
			config.settings.workspaceFolder =
				{ uri = vim.uri_from_fname(config.root_dir), name = vim.fs.basename(config.root_dir) }
		end,
		handlers = {
			["eslint/openDoc"] = function(_, result)
				if result then
					vim.ui.open(result.url)
				end
				return {}
			end,
			["eslint/confirmESLintExecution"] = function()
				return 4
			end,
			["eslint/probeFailed"] = function()
				vim.notify("ESLint probe failed", vim.log.levels.WARN)
				return {}
			end,
			["eslint/noLibrary"] = function()
				vim.notify("ESLint library not found in project", vim.log.levels.WARN)
				return {}
			end,
		},
	},
}
for name, config in pairs(servers) do
	if name == "ty" or name == "pyright" then
		config.on_init = function(client)
			apply_python_path(client, python_paths[client.config.root_dir])
		end
	end
	config.root_dir = function(buf, on_dir)
		if vim.b[buf].large_file or vim.fn.executable(config.cmd[1]) == 0 then
			return
		end
		local file = vim.api.nvim_buf_get_name(buf)
		if file == "" then
			return
		end
		local root = (name == "ty" or name == "pyright") and python_project_root(buf)
			or vim.fs.root(buf, config.root_markers)
		if (name == "ts_ls" or name == "eslint") and vim.fs.root(buf, { "deno.json", "deno.jsonc", "deno.lock" }) then
			return
		end
		if root or not config.workspace_required then
			on_dir(root or vim.fs.dirname(file))
		end
	end
	vim.lsp.config(name, config)
end
local function enable_servers()
	for name, config in pairs(servers) do
		-- Keep pyright installed but disabled, matching the previous configuration.
		if name ~= "pyright" and not vim.lsp.is_enabled(name) and vim.fn.executable(config.cmd[1]) == 1 then
			vim.lsp.enable(name)
		end
	end
end
require("mason-registry"):on("package:install:success", vim.schedule_wrap(enable_servers))
require("mason-tool-installer").setup({
	run_on_start = false,
	integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
	ensure_installed = {
		"bash-language-server",
		"buf",
		"buildifier",
		"cmakelang",
		"latexindent",
		"neocmakelsp",
		"rust-analyzer",
		"shfmt",
		"starpls",
		"texlab",
		"yaml-language-server",
		"typescript-language-server",
		"html-lsp",
		"css-lsp",
		"clangd",
		"tailwindcss-language-server",
		"svelte-language-server",
		"lua-language-server",
		"graphql-language-service-cli",
		"emmet-ls",
		"prisma-language-server",
		"pyright",
		"ty",
		"ruff",
		"eslint-lsp",
		"prettier",
		"stylua",
		"clang-format",
		"isort",
		"black",
		"pylint",
		"eslint_d",
	},
})
enable_servers()

-- File renames in the Snacks explorer use Snacks.rename for LSP import updates.
