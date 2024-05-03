-- Setup todo-comments.
local status_ok, todo = pcall(require, "todo-comments")
if not status_ok then
  return
end

todo.setup({})
