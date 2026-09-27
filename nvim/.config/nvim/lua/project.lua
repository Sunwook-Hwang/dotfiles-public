-- One project boundary and cache for browsing and Python workspace selection.
local M = {}
local markers = {
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
}

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
		return git_root, true
	end
	if library_root then
		return library_root, true
	end
	local marker = vim.fs.find(markers, { path = dir, upward = true, type = "file", limit = 1 })[1]
	return marker and vim.fs.dirname(marker) or dir, marker ~= nil
end

local roots = {}
function M.for_dir(dir)
	if not roots[dir] then
		local root, recognized = find_project(dir)
		roots[dir] = { root = root, recognized = recognized }
	end
	return roots[dir]
end

local group = vim.api.nvim_create_augroup("pack-project-cache", { clear = true })
local function invalidate_roots()
	roots = {}
end
vim.api.nvim_create_autocmd({ "BufFilePost", "FocusGained", "ShellCmdPost", "TermClose" }, {
	group = group,
	callback = invalidate_roots,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = vim.list_extend(vim.deepcopy(markers), { ".git", "os.py", "__init__.py" }),
	callback = invalidate_roots,
})
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "PackRefresh",
	callback = invalidate_roots,
})

return M
