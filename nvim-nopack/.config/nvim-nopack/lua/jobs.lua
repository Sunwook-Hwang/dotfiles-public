local shared = require("state")

-- =========================================
-- ========= ASYNC COMMAND RUNNER ========
-- =========================================
-- 검색·Git·외부 포맷터 공통 실행부. 같은 key의 새 요청은 이전 작업을 취소합니다.
-- 기본 제한: 5초 / stdout 2 MiB. 검색은 부분 결과 허용, 포맷팅·diff는 완성된 결과만 적용.
-- :NopackCancel: 실행 중인 명령과 picker 취소.
shared.running = {}
shared.format_versions = {}
shared.tag_projects = {}
shared.definition_requests = {}
shared.outline, shared.cancel_outline = nil, nil
local function stop_command_timer(task)
	if task.timer then
		task.timer:stop()
		if not task.timer:is_closing() then
			task.timer:close()
		end
		task.timer = nil
	end
end
function shared.cancel_command(key)
	local task = shared.running[key]
	if task then
		task.cancelled = true
		stop_command_timer(task)
		task.chunks = nil
		if task.process then
			task.process:kill(9)
		end
		shared.running[key] = nil
	end
end
function shared.finish_tag_waiters(waiters, succeeded, output)
	for _, waiter in ipairs(waiters) do
		local callback = waiter.failed
		if succeeded then
			callback = waiter.after
		end
		if callback then
			local ok, err = pcall(callback, output)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.WARN)
			end
		end
	end
end
function shared.cancel_tag_build(root, project)
	project.generation = project.generation + 1
	shared.cancel_command("ctags:" .. root)
	local waiters = project.waiters
	if project.active then
		vim.list_extend(waiters, project.active.waiters)
		for file in pairs(project.active.files) do
			project.pending[file] = true
		end
	end
	project.active, project.save_version = nil, nil
	project.waiters, project.full, project.quiet = {}, false, true
	shared.finish_tag_waiters(waiters, false)
end
local function cancel_commands()
	shared.format_versions = {}
	if shared.outline and shared.cancel_outline then
		shared.cancel_outline(shared.outline)
	end
	for root, project in pairs(shared.tag_projects) do
		shared.cancel_tag_build(root, project)
	end
	for buf, cancel in pairs(shared.definition_requests) do
		shared.definition_requests[buf] = nil
		cancel()
	end
	for key in pairs(shared.running) do
		shared.cancel_command(key)
	end
end
vim.api.nvim_create_user_command("NopackCancel", function()
	cancel_commands()
	if shared.active_picker then
		shared.active_picker.close()
	end
end, {})
vim.api.nvim_create_autocmd("VimLeavePre", { callback = cancel_commands })
function shared.run_command(key, argv, opts, callback)
	shared.cancel_command(key)
	local task = { chunks = {}, bytes = 0, errors = "", limited = false }
	shared.running[key] = task
	local limit = opts.max_bytes or 2 * 1024 * 1024
	local ok, process = pcall(vim.system, argv, {
		cwd = opts.cwd,
		stdin = opts.stdin,
		stdout = function(err, data)
			if err then
				task.errors = tostring(err)
			end
			if not data or task.cancelled or task.limited then
				return
			end
			local remaining = limit - task.bytes
			task.chunks[#task.chunks + 1] = data:sub(1, remaining)
			task.bytes = task.bytes + math.min(#data, remaining)
			if #data > remaining then
				task.limited = true
				if task.process then
					task.process:kill(9)
				end
			end
		end,
		stderr = function(err, data)
			local message = data or (err and tostring(err)) or ""
			task.errors = (task.errors .. message):sub(1, 8192)
		end,
	}, function(result)
		vim.schedule(function()
			stop_command_timer(task)
			if task.cancelled then
				return
			end
			shared.running[key] = nil
			if task.limited and not opts.partial then
				task.chunks = nil
				if not opts.quiet then
					vim.notify(key .. ": time/output limit exceeded; result discarded", vim.log.levels.WARN)
				end
				if opts.failed then
					opts.failed()
				end
				return
			end
			if not task.limited and result.code ~= 0 and not (opts.no_match and result.code == 1) then
				task.chunks = nil
				if not opts.quiet then
					vim.notify(
						key .. ": " .. (task.errors ~= "" and task.errors or "command failed (" .. result.code .. ")"),
						vim.log.levels.WARN
					)
				end
				if opts.failed then
					opts.failed()
				end
				return
			end
			if task.limited then
				vim.notify(key .. ": limit reached; partial results", vim.log.levels.WARN)
			end
			local output = table.concat(task.chunks)
			task.chunks = nil
			callback(output, task.limited)
		end)
	end)
	if not ok then
		shared.running[key] = nil
		if not opts.quiet then
			vim.notify(key .. ": " .. tostring(process), vim.log.levels.WARN)
		end
		if opts.failed then
			opts.failed()
		end
		return
	end
	task.process = process
	task.timer = vim.defer_fn(function()
		task.timer = nil
		if shared.running[key] == task and not task.cancelled then
			task.limited = true
			process:kill(9)
		end
	end, opts.timeout or 5000)
end
