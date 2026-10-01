-- ============================================================================
--                   ________    ___   _____ __  __
--                  / ____/ /   /   | / ___// / / /
--                 / /_  / /   / /| | \__ \/ /_/ /
--                / __/ / /___/ ___ |___/ / __  /
--               /_/   /_____/_/  |_/____/_/ /_/
--
--                NO-PACK / SPEED MODE
--                Native Neovim. Zero third-party neovim plugins.
--                Dotfiles by Sunwook Hwang
-- ============================================================================
-- Neovim 0.12+; language servers and formatters are optional external tools.
-- Keep this file and the adjacent lua/ directory together when copying the profile.
if vim.fn.has("nvim-0.12") == 0 then
	error("This nopack config requires Neovim 0.12 or newer")
end

-- Resolve symlinks so direct -u launches find this profile's modules too.
local config_file = vim.uv.fs_realpath(debug.getinfo(1, "S").source:sub(2))
local config_root = vim.fs.dirname(config_file)
vim.opt.runtimepath:prepend(config_root)
require("state").config_root = config_root

-- Preserve initialization order; shared functions are defined before events run.
require("options")
require("bigfile")
require("keymaps")
require("theme")
require("statusline")
require("indent")
require("explorer")
require("completion")
require("navigation")
require("buffers")
require("project")
require("jobs")
require("pickers")
require("search")
require("editing")
require("terminal")
require("session")
require("dashboard")
require("git")
require("format")
require("tags")
require("lsp")
require("outline")
require("diagnostics")
require("syntax")
require("context")
require("breadcrumbs")
require("whichkey")

-- Collaboration is opt-in; do not load its transport or algorithms during startup.
for command, action in pairs({
	FlashShare = "start",
	FlashJoin = "join",
	FlashShareStop = "stop",
	FlashShareStatus = "status",
}) do
	vim.api.nvim_create_user_command(command, function(args)
		local ok, err = pcall(function()
			require("sharing")[action](args.fargs)
		end)
		if not ok then
			vim.notify(tostring(err), vim.log.levels.ERROR)
		end
	end, { nargs = "*", desc = "Native single-buffer collaboration: " .. action })
end

-- Offer to join when an opened file has a live-share sidecar (see lua/sharing.lua).
-- One stat per file read; the module loads only when a sidecar exists.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("flash-share-discovery", { clear = true }),
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		if vim.g.flash_share_discovery == false or vim.bo[args.buf].buftype ~= "" or path == "" then
			return
		end
		if not vim.uv.fs_lstat(vim.fs.joinpath(vim.fs.dirname(path), "." .. vim.fs.basename(path) .. ".flash-share")) then
			return
		end
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(args.buf) then
				return
			end
			local ok, err = pcall(function()
				require("sharing").discover(args.buf, true)
			end)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
			end
		end)
	end,
})
