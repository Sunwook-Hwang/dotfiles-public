# LSP and formatter launchers

Place executable LSP and formatter binaries, symlinks, or wrappers in this directory.
`init.offline.lua` searches it before `PATH`. Keep dependency/runtime directories elsewhere
when a tool cannot run as a standalone executable, and place only its launcher here.
