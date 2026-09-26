-- =========================================
-- =========== POST-PLUGIN COMMANDS ========
-- =========================================

local cmd = vim.cmd
-- trailing spaces cleanup (disabled)
-- cmd([[autocmd BufWritePre * %s/\s\+$//e]])
cmd([[filetype indent on]])
cmd([[set whichwrap+=<,>,[,],h,l]])
cmd([[set iskeyword+=-]])
-- cmd([[set langmap=ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz]])

-- =========================================
-- ============== COLORSCHEME ==============
-- =========================================
-- GitHub themes hide inactive statuslines by default; configure only when selected.
vim.api.nvim_create_autocmd("ColorSchemePre", {
	pattern = "github_*",
	once = true,
	callback = function()
		require("github-theme").setup({ options = { hide_nc_statusline = false } })
	end,
})

vim.cmd([[colorscheme github_dark_default]])

-- =========================================
-- ============== OPTIONAL THEME ===========
-- =========================================
local display = {
	transparent_window = false,
}

if display.transparent_window then
	cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
	cmd("au ColorScheme * hi SignColumn ctermbg=none guibg=none")
	cmd("au ColorScheme * hi NormalNC ctermbg=none guibg=none")
	cmd("au ColorScheme * hi MsgArea ctermbg=none guibg=none")
	cmd("au ColorScheme * hi SnacksPickerBorder ctermbg=none guibg=none")
	cmd("au ColorScheme * hi SnacksPickerList ctermbg=none guibg=none")
	cmd("let &fcs='eob: '")
end
