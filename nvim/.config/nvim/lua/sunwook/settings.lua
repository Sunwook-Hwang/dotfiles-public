HOME_PATH = vim.loop.os_homedir()

local default_options = {
  backup = false, -- creates a backup file
  clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  lazyredraw = true,
  cmdheight = 1, -- more space in the neovim command line for displaying messages
  -- colorcolumn = "90", -- fixes indentline for now
  completeopt = { "menuone", "noselect" },
  conceallevel = 0, -- so that `` is visible in markdown files
  fileencoding = "utf-8", -- the encoding written to a file
  foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
  foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
  guifont = "monospace:h17", -- the font used in graphical neovim applications
  hidden = true, -- required to keep multiple buffers and open multiple buffers
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = "a", -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = true, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  termguicolors = true, -- set term gui colors (most terminals support this)
  title = true, -- set the title of window to the value of the titlestring
  -- -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
  undodir = HOME_PATH .. "/.config/undo", -- set an undo directory
  undofile = true, -- enable persistent undo
  updatetime = 10, -- faster completion
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 4, -- the number of spaces inserted for each indentation
  tabstop = 4, -- insert 2 spaces for a tab
  cursorline = false, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = false, -- set relative numbered lines
  numberwidth = 2, -- set number column width to 2 {default 4}
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  wrap = true, -- display lines as one long line
  spell = false,
  spelllang = "en",
  background = "dark",
  scrolloff = 5, -- is one of my fav
  sidescrolloff = 8,
  ttyfast = true,
  sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
} ---  VIM ONLY COMMANDS  ---cmd "filetype plugin on"cmd('let &titleold="' .. TERMINAL .. '"')cmd "set inccommand=split"cmd "set iskeyword+=-"

---  SETTINGS  ---

vim.opt.shortmess:append("c")

for k, v in pairs(default_options) do
  vim.opt[k] = v
end

local display = {
  transparent_window = true,
}

local cmd = vim.cmd

if display.transparent_window then
  cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
  cmd("au ColorScheme * hi SignColumn ctermbg=none guibg=none")
  cmd("au ColorScheme * hi NormalNC ctermbg=none guibg=none")
  cmd("au ColorScheme * hi MsgArea ctermbg=none guibg=none")
  cmd("au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none")
  cmd("au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none")
  cmd("let &fcs='eob: '")
end

cmd([[autocmd BufWritePre * %s/\s\+$//e]])
cmd([[au ColorScheme * hi SignColumn ctermbg=none guibg=none]])
cmd([[filetype indent on]])
cmd([[set whichwrap+=<,>,[,],h,l]])
cmd([[set iskeyword+=-]])
-- cmd([[set langmap=ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz]])
