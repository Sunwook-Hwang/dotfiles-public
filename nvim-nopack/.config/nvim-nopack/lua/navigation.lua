local policy = require("buffer_policy")
local shared = require("state")

-- =========================================
-- ====== FILE TREE: TOGGLE / REVEAL =====
-- =========================================
-- Space e: 프로젝트 루트의 트리를 열고 현재 파일까지 펼칩니다.
-- 프로젝트 탐색 함수는 PROJECT ROOT에서 정의되며 키 실행 시 호출됩니다.

vim.keymap.set("n", "<leader>e", function()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
			if #vim.api.nvim_tabpage_list_wins(0) > 1 then
				vim.api.nvim_win_close(win, false)
			else
				-- Starting with `nvim .` leaves only netrw: make it a sidebar.
				vim.cmd("botright vnew")
				shared.set_window_width(win, shared.sidebar_width())
				shared.fix_sidebar_width(win)
				vim.g.netrw_chgwin = vim.fn.winnr()
			end
			return
		end
	end
	local file = policy.is_source(0) and vim.api.nvim_buf_get_name(0) or ""
	local root = shared.project_root():gsub("/+$", "")
	local existing_buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		existing_buffers[buf] = true
	end
	-- Negative winsize is an absolute column count: open at the final width.
	vim.g.netrw_winsize = -shared.sidebar_width()
	shared.netrw_command("Lexplore " .. vim.fn.fnameescape(root == "" and "/" or root))
	if file ~= "" then
		shared.reveal_tree_file(file:sub(#root + 2))
	end
	-- netrw's tree setup can abandon an intermediate unnamed buffer.
	-- Remove only empty, hidden buffers created by this particular opening.
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			not existing_buffers[buf]
			and vim.api.nvim_buf_get_name(buf) == ""
			and policy.is_source(buf)
			and not vim.bo[buf].modified
			and #vim.fn.win_findbuf(buf) == 0
			and vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { "" })
		then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, { silent = true, nowait = true, desc = "Toggle file explorer" })

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
