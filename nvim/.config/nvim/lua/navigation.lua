local policy = require("buffer_policy")
local shared = require("state")

-- =========================================
-- ====== FILE TREE: TOGGLE / REVEAL =====
-- =========================================
-- Space e: 현재 파일의 디렉터리를 편집 가능한 사이드바로 엽니다.
-- 프로젝트 탐색 함수는 PROJECT ROOT에서 정의되며 키 실행 시 호출됩니다.

local explorer = require("explorer")
vim.keymap.set("n", "<leader>e", function()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if explorer.is_buffer(buf) then
			vim.api.nvim_win_call(win, function()
				vim.fn.maparg("<C-c>", "n", false, true).callback()
			end)
			return
		end
	end
	local file = policy.is_source(0) and vim.api.nvim_buf_get_name(0) or ""
	local root = file ~= "" and vim.fs.dirname(file) or shared.project_root()
	explorer.open(root, true)
end, { silent = true, nowait = true, desc = "Toggle editable file explorer" })

-- =========================================
-- ========= EDITOR WINDOW TARGET ========
-- =========================================
-- 트리에서 파일/버퍼를 선택할 때 결과를 표시할 편집 창을 확보합니다.
shared.focus_editor = function()
	if policy.is_editor(0) then
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if policy.is_editor(win) then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.cmd("botright vnew")
end

function shared.select_buffer(buf)
	shared.focus_editor()
	vim.api.nvim_set_current_buf(buf)
end
