-- Setup orgmode
local status_ok, orgmode = pcall(require, "orgmode")
if not status_ok then
  return
end

orgmode.setup({
  org_agenda_files = { "~/org/*" },
  org_default_notes_file = "~/org/refile.org",
})
