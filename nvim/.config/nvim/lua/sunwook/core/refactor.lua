local status_ok, refactor = pcall(require, "refactoring")
if not status_ok then
  return
end

refactor.setup({})
