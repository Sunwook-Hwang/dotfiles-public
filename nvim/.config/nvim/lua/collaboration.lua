-- Collaboration is opt-in; do not load its transport or algorithms during startup.
local policy = require("buffer_policy")

local function transport()
	local share = require("collab")
	share.config.max_peers = math.max(2, math.min(tonumber(vim.g.flash_share_max_peers) or 8, 64))
	return require("collab.core")
end

for command, action in pairs({
	LiveShare = "start",
	LiveShareJoin = "join",
	LiveShareStop = "stop",
	LiveShareStatus = "status",
	FlashShare = "start",
	FlashJoin = "join",
	FlashShareStop = "stop",
	FlashShareStatus = "status",
}) do
	vim.api.nvim_create_user_command(command, function(args)
		local ok, err = pcall(function()
			if action == "start" then
				assert(policy.allows(0) and vim.bo.modifiable, "Share a normal, editable source buffer")
			end
			transport()[action](args.fargs)
		end)
		if not ok then
			vim.notify(tostring(err), vim.log.levels.ERROR)
		end
	end, { nargs = "*", desc = "Native single-buffer collaboration: " .. action })
end

-- Same leader shortcuts as the standalone collab.nvim package.
for _, shortcut in ipairs({
	{ "<leader>Cs", "FlashShare", "Live share: start sharing" },
	{ "<leader>Cj", "FlashJoin", "Live share: join current file" },
	{ "<leader>Cq", "FlashShareStop", "Live share: disconnect" },
	{ "<leader>Ci", "FlashShareStatus", "Live share: session information" },
}) do
	if vim.fn.maparg(shortcut[1], "n") == "" then
		vim.keymap.set("n", shortcut[1], "<Cmd>" .. shortcut[2] .. "<CR>", { silent = true, desc = shortcut[3] })
	end
end

-- Offer to join when an opened file has a collab sidecar (see lua/collab/core.lua).
-- One stat per file read; the module loads only when a sidecar exists.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("flash-share-discovery", { clear = true }),
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		if vim.g.flash_share_discovery == false or vim.bo[args.buf].buftype ~= "" or path == "" then
			return
		end
		if
			not vim.uv.fs_lstat(vim.fs.joinpath(vim.fs.dirname(path), "." .. vim.fs.basename(path) .. ".flash-share"))
		then
			return
		end
		vim.schedule(function()
			if vim.api.nvim_get_current_buf() ~= args.buf or not policy.is_editor(0) then
				return
			end
			local ok, err = pcall(function()
				transport().discover(args.buf, true)
			end)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
			end
		end)
	end,
})
