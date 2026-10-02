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
