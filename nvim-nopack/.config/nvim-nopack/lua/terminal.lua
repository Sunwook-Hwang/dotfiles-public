local shared = require("state")

-- =========================================
-- ============ SPLIT TERMINAL ===========
-- =========================================
-- Ctrl-t: Space gg와 같은 크기의 하단 split에 같은 셸 작업을 다시 엽니다.
-- 터미널 버퍼는 일반 버퍼 순환에서 제외하고, 종료된 셸만 정리합니다.
local terminal
local function terminal_running(buf)
	local job = vim.bo[buf].channel
	if type(job) ~= "number" or job <= 0 then
		return false
	end
	local ok, status = pcall(vim.fn.jobwait, { job }, 0)
	return ok and status[1] == -1
end
local function toggle_terminal()
	if
		terminal
		and vim.api.nvim_buf_is_valid(terminal)
		and vim.bo[terminal].buftype == "terminal"
		and not terminal_running(terminal)
	then
		vim.api.nvim_buf_delete(terminal, { force = true })
		terminal = nil
	end
	if terminal and vim.api.nvim_buf_is_valid(terminal) then
		local win = vim.fn.bufwinid(terminal)
		if win ~= -1 then
			vim.cmd("stopinsert")
			vim.api.nvim_win_close(win, true)
			return
		end
	end
	if terminal and vim.api.nvim_buf_is_valid(terminal) then
		vim.cmd("botright sbuffer " .. terminal)
	else
		vim.cmd("botright new")
		terminal = vim.api.nvim_get_current_buf()
		vim.bo.bufhidden = "hide"
		vim.bo.buflisted = false
		vim.fn.jobstart(vim.o.shell, { term = true })
	end
	vim.cmd("startinsert")
end
shared.map({ "n", "t" }, "<C-t>", toggle_terminal, "Toggle bottom terminal")
