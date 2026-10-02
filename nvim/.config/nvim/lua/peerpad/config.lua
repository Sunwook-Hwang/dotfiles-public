-- Common commands, shortcuts and discovery belong to peerpad.nvim.
local policy = require("buffer_policy")
local share = require("peerpad")
local start = share.start
share.start = function(args)
	assert(policy.allows(0) and vim.bo.modifiable, "Share a normal, editable source buffer")
	share.config.max_peers = math.max(2, math.min(tonumber(vim.g.flash_share_max_peers) or 8, 64))
	return start(args)
end
share.setup({ keymaps = true, discovery = vim.g.flash_share_discovery ~= false })

-- Preserve FLASH command names; all actions use the same public API.
for command, action in pairs({
	FlashShare = "start",
	FlashJoin = "join",
	FlashShareStop = "stop",
	FlashShareStatus = "status",
}) do
	vim.api.nvim_create_user_command(command, function(args)
		local ok, err = pcall(share[action], args.fargs)
		if not ok then
			vim.notify(tostring(err), vim.log.levels.ERROR)
		end
	end, { nargs = "*", desc = "Native single-buffer collaboration: " .. action })
end
