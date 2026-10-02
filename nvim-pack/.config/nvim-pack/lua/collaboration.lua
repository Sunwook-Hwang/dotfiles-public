-- Register discovery before files are read; transport loads only when sharing is used.
require("live-share").setup({ keymaps = true })
