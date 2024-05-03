lvim.builtin.telescope.active = true
-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
lvim.builtin.telescope.defaults.file_ignore_patterns = {
  "%.7z",
  "%.burp",
  "%.pth",
  "%.pkl",
  "%.bz2",
  "%.cache",
  "%.class",
  "%.dll",
  "%.docx",
  "%.dylib",
  "%.epub",
  "%.exe",
  "%.flac",
  "%.ico",
  "%.ipynb",
  "%.jar",
  "%.lock",
  "%.met",
  "%.mkv",
  "%.mp4",
  "%.otf",
  "%.pdb",
  "%.pdf",
  "%.rar",
  "%.sqlite3",
  "%.svg",
  "%.tar",
  "%.tar.gz",
  "%.ttf",
  "%.webp",
  "%.zip",
  ".DS_Store",
  ".dart_tool/",
  ".git/",
  ".github/",
  ".gradle/",
  ".idea/",
  ".settings/",
  ".vale/",
  ".vscode/",
  "__pycache__/",
  "__pycache__/*",
  "build/",
  "docs/",
  "env/",
  "gradle/",
  "node_modules/",
  "node_modules/*",
  "smalljre_*/*",
  "target/",
  "vendor/*",
  -- "%.jpeg",
  -- "%.jpg",
  -- "%.png",
}

local _, actions = pcall(require, "telescope.actions")
local _, pickers = pcall(require, "telescope.pickers")

pickers.lsp_document_symbols = {
  theme = "dropdown",
  initial_mode = "normal",
}
pickers.lsp_dynamic_workspace_symbols = {
  theme = "dropdown",
  initial_mode = "normal",
}
pickers.find_files = {
  theme = "dropdown",
  hidden = true,
  -- previewer = false,
}

pickers.git_files = {
  theme = "dropdown",
  hidden = true,
  -- previewer = false,
  show_untracked = true,
}

pickers.live_grep = {
  --@usage don't include the filename in the search results
  only_sort_text = true,
  theme = "dropdown",
}

pickers.grep_string = {
  only_sort_text = true,
  theme = "dropdown",
}

pickers.buffers = {
  theme = "dropdown",
  previewer = false,
  -- initial_mode = "normal",
  mappings = {
    i = {
      ["<C-d>"] = actions.delete_buffer,
    },
    n = {
      ["dd"] = actions.delete_buffer,
    },
  },
}

pickers.planets = {
  show_pluto = true,
  show_moon = true,
}

pickers.lsp_references = {
  theme = "dropdown",
  initial_mode = "normal",
}

pickers.lsp_definitions = {
  theme = "dropdown",
  initial_mode = "normal",
}

pickers.lsp_declarations = {
  theme = "dropdown",
  initial_mode = "normal",
}

pickers.lsp_implementations = {
  theme = "dropdown",
  initial_mode = "normal",
}

lvim.builtin.telescope.pickers = pickers
lvim.builtin.telescope.defaults.pickers = pickers

lvim.builtin.telescope.defaults.mappings = {
  i = {
    ["<C-n>"] = actions.move_selection_next,
    ["<C-p>"] = actions.move_selection_previous,
    ["<C-c>"] = actions.close,
    ["<C-j>"] = actions.cycle_history_next,
    ["<C-k>"] = actions.cycle_history_prev,
    ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    ["<CR>"] = actions.select_default + actions.center,
    -- ["<C-d>"] = require("telescope.actions").delete_buffer,
  },
  n = {
    ["<C-n>"] = actions.move_selection_next,
    ["<C-c>"] = actions.close,
    ["<C-p>"] = actions.move_selection_previous,
    ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    ["dd"] = require("telescope.actions").delete_buffer, -- TODO: delete_buffer error
  },
}
