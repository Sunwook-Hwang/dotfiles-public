local utils = require("sunwook.utils")

vim.g.mapleader = " "

-- I hate escape
utils.inoremap("jk", "<esc>")

-- nohl
utils.nnoremap("<ESC>", ":nohl<CR>")

-- Increment/decrement
utils.nnoremap("+", "<C-a>")
utils.nnoremap("-", "<C-x>")

-- Add undo break-points
utils.inoremap(",", ",<c-g>u")
utils.inoremap(".", ".<c-g>u")
utils.inoremap(";", ";<c-g>u")
utils.inoremap("(", "(<C-g>u")
utils.inoremap("<", "<<C-g>u")
utils.inoremap("{", "{<C-g>u")
utils.inoremap("[", "[<c-g>u")

-- navigation
utils.inoremap("<A-Up>", "<C-\\><C-N><C-w>h")
utils.inoremap("<A-Down>", "<C-\\><C-N><C-w>j")
utils.inoremap("<A-Left>", "<C-\\><C-N><C-w>k")
utils.inoremap("<A-Right>", "<C-\\><C-N><C-w>l")

-- Move current line / block with Alt-j/k ala vscode.
utils.inoremap("<A-j>", "<ESC>:m .+1<CR>==gi")
utils.inoremap("<A-k>", "<ESC>:m .-2<CR>==gi")
utils.nnoremap("<A-j>", ":m .+1<CR>==")
utils.nnoremap("<A-k>", ":m .-2<CR>==")
utils.vnoremap("<A-j>", ":m '>+1<CR>gv-gv")
utils.vnoremap("<A-k>", ":m '<-2<CR>gv-gv")

-- save file
utils.inoremap("<C-s>", "<ESC><cmd>w<cr>")
utils.nnoremap("<C-s>", ":w<cr>")

-- Better window movement
utils.nnoremap("<C-h>", "<C-w>h")
utils.nnoremap("<C-j>", "<C-w>j")
utils.nnoremap("<C-k>", "<C-w>k")
utils.nnoremap("<C-l>", "<C-w>l")

-- Resize with arrows
utils.nnoremap("<S-Up>", ":resize -5<CR>")
utils.nnoremap("<S-Down>", ":resize +5<CR>")
utils.nnoremap("<S-Left>", ":vertical resize -5<CR>")
utils.nnoremap("<S-Right>", ":vertical resize +5<CR>")

utils.nnoremap("<leader><cr>", ":luafile ~/.config/nvim/init.lua<CR>")
-- utils.nnoremap("<leader>f;", [[:e ~/.config/nvim/init.lua<CR>]])

utils.nnoremap("<leader>d", [["_d]])
utils.vnoremap("<leader>d", [["_d]])
utils.nnoremap("x", [["_x]])
utils.vnoremap("p", [["_dP]])
utils.vnoremap("P", [["_dP]])
-- utils.nnoremap('Y', "y$") -- defaults settings in neovim >= 0.6

-- Allow a current file to be executable
utils.nnoremap("<leader>X", [[:silent !chmod +x %<CR>]])

utils.nnoremap("<leader>h", "<cmd>sv<cr>")
utils.nnoremap("<leader>v", "<cmd>vs<cr>")

utils.nnoremap("<leader>w", ":windo diffthis<CR>")
utils.nnoremap("<leader>a", "gg<S-v>G")

utils.nnoremap("<leader>o", "o<esc>")
utils.nnoremap("<leader>O", "O<esc>")

utils.nnoremap("n", "nzzzv")
utils.nnoremap("N", "Nzzzv")

utils.tnoremap("<C-h>", "<C-\\><C-N><C-w>h")
utils.tnoremap("<C-j>", "<C-\\><C-N><C-w>j")
utils.tnoremap("<C-k>", "<C-\\><C-N><C-w>k")
utils.tnoremap("<C-l>", "<C-\\><C-N><C-w>l")

utils.nnoremap("<leader>q", ":q<CR>")
-- TODO
-- navigate tab completion with <c-j> and <c-k>
-- runs conditionally
vim.cmd('inoremap <expr> <C-j> pumvisible() ? "\\<C-n>" : "\\<C-j>"')
vim.cmd('inoremap <expr> <C-k> pumvisible() ? "\\<C-p>" : "\\<C-k>"')

-- Stay in indent mode
utils.vnoremap("<", "<gv")
utils.vnoremap(">", ">gv")

-- Git
utils.nnoremap("<leader>gs", [[:Git<CR>gg<c-n>]])
utils.nnoremap("<leader>gd", [[:Gdiff<CR>]])
utils.nnoremap("<leader>gg", [[:LazyGit<CR>]])

-- Telescope
utils.nnoremap("<leader><leader>", [[<cmd>lua require('telescope.builtin').git_files()<CR>]])
-- utils.nnoremap("<leader><cr>", [[<cmd>lua require('telescope.builtin').git_files()<CR>]])
utils.nnoremap("<leader>t", [[<cmd>lua require('telescope.builtin').grep_string()<CR>]])
utils.nnoremap("<leader>sB", [[<cmd>lua require('telescope.builtin').git_branches()<CR>]])
utils.nnoremap("<leader>sC", [[<cmd>lua require('telescope.builtin').commands()<CR>]])
utils.nnoremap("<leader>sb", [[<cmd>lua require('telescope.builtin').buffers()<CR>]])
utils.nnoremap("<leader>sc", [[<cmd>lua require('telescope.builtin').git_commits()<CR>]])
utils.nnoremap(
  "<leader>f",
  [[<cmd>lua require('telescope.builtin').find_files({no_ignore = true, hidden = true,})<CR>]]
)
utils.nnoremap("<leader>sh", [[<cmd>lua require('telescope.builtin').help_tags()<CR>]])
utils.nnoremap("<leader>sk", [[<cmd>lua require('telescope.builtin').keymaps()<CR>]])
utils.nnoremap("<leader>sr", [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]])
utils.nnoremap("<leader>st", [[<cmd>lua require('telescope.builtin').live_grep()<CR>]])
utils.nnoremap("<leader>se", [[<cmd>lua require('telescope.builtin').file_browser()<CR>]])
utils.nnoremap("<leader>ss", [[<cmd>lua require('telescope.builtin').treesitter()<CR>]])
utils.nnoremap("<leader>sd", [[<cmd>lua require('telescope.builtin').file_browser()<CR>]])
utils.nnoremap("<leader>sp", [[<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>]])
-- utils.nnoremap("<leader>fu", [[<cmd>Telescope ultisnips<CR>]])
-- utils.nnoremap("<leader>fp", [[<cmd>lua require('telescope').extensions.projects.projects()<CR>]])

-- BARBAR
-- Re-order to previous/next
utils.nnoremap("<tab>", [[:BufferNext<CR>]])
utils.nnoremap("<S-tab>", [[:BufferPrevious<CR>]])
-- utils.nnoremap("<leader>j", [[:BufferPrevious<CR>]])
-- utils.nnoremap("<leader>k", [[:BufferNext<CR>]])

utils.nnoremap("<leader>bj", [[:BufferMovePrevious<CR>]])
utils.nnoremap("<leader>bk", [[:BufferMoveNext<CR>]])

-- Goto buffer in position...
utils.nnoremap("<A-1>", [[:BufferGoto 1<CR>]])
utils.nnoremap("<A-2>", [[:BufferGoto 2<CR>]])
utils.nnoremap("<A-3>", [[:BufferGoto 3<CR>]])
utils.nnoremap("<A-4>", [[:BufferGoto 4<CR>]])
utils.nnoremap("<A-5>", [[:BufferGoto 5<CR>]])
utils.nnoremap("<A-6>", [[:BufferGoto 6<CR>]])
utils.nnoremap("<A-7>", [[:BufferGoto 7<CR>]])
utils.nnoremap("<A-8>", [[:BufferGoto 8<CR>]])
utils.nnoremap("<A-9>", [[:BufferLast<CR>]])

-- Close commands
utils.nnoremap("<leader>c", [[:bw!<CR>]])
-- utils.nnoremap('<leader>c', [[:Bdelete!<CR>]])
-- utils.nnoremap('<leader>c', [[:Bwipeout!<CR>]])
utils.nnoremap("<leader>be", [[:BufferCloseAllButCurrent<CR>]])
utils.nnoremap("<leader>bw", [[:BufferWipeout<CR>]])
utils.nnoremap("<leader>bh", [[:BufferCloseBuffersLeft<CR>]])
utils.nnoremap("<leader>bl", [[:BufferCloseBuffersRight<CR>]])
utils.nnoremap("<leader>bm", [[:BufferCloseBuffersRight<CR>|:BufferCloseBuffersLeft<CR>]])

-- Magic buffer-picking mode
utils.nnoremap("<leader>bp", [[:BufferPick<CR>]])

-- Sort automatically by...
utils.nnoremap("<leader>bD", [[:BufferOrderByDirectory<CR>]])
utils.nnoremap("<leader>bL", [[:BufferOrderByLanguage<CR>]])

-- Session
utils.nnoremap("<C-p>", [[:OpenSession!<CR>]])
utils.nnoremap("<leader>fp", [[:OpenSession!<CR>]])

-- utils.nnoremap("<leader>fp", [[<cmd>lua require('sunwook.core.session').list_session()<cr>]])
-- utils.nnoremap("<leader>pp", [[<cmd>lua require('sunwook.core.session').list_session()<cr>]])
-- utils.nnoremap("<leader>ps", [[<cmd>lua require('sunwook.core.session').save_session()<cr>]])
-- utils.nnoremap("<leader>pt", [[<cmd>lua require('sunwook.core.session').toggle_session()<cr>]])
-- utils.nnoremap("<leader>pd", [[<cmd>lua require('sunwook.core.session').delete_session()<cr>]])

-- utils.nnoremap("<leader>pd", [[:OpenSession!<CR>]])

-- W = { "<cmd>lua require('utils.session').toggle_session()<cr>", "Toggle Workspace Saving" },

-- Undotree
utils.nnoremap("<leader>u", [[<cmd>UndotreeToggle<CR>]])

-- Dashboard
utils.nnoremap("<leader>;", [[<cmd>Alpha<CR>]])

-- Linenumber toggle
utils.nnoremap("<leader>L", [[:set nu! <bar> set rnu!<CR>]])

-- NvimTreeFindFiles
utils.nnoremap("<leader>e", [[:NvimTreeFindFileToggle<CR>]])

-- NERDTreeToggleFind
-- utils.nnoremap("<leader>e", [[:call NERDTreeToggleFind()<CR>]])

-- SymbolsOutline
utils.nnoremap("<leader>r", [[:SymbolsOutline<CR>]])

-- Zen
-- utils.nnoremap("<leader>zz", [[:Goyo <bar> set rnu <bar> set nu<CR>]])
-- utils.nnoremap("<leader>zl", [[:Limelight!!<CR>]])
utils.nnoremap("<leader>zf", [[:TZFocus<CR>]])
utils.nnoremap("<leader>zm", [[:TZMinimalist<CR>]])
utils.nnoremap("<leader>zz", [[:TZAtaraxis<CR>]])

-- Packer
utils.nnoremap("<leader>Ps", [[<cmd>PackerSync<CR>]])
utils.nnoremap("<leader>Pi", [[<cmd>PackerInstall<CR>]])
utils.nnoremap("<leader>Pc", [[<cmd>PackerClean<CR>]])

-- Start the find and replace command across the entire file
utils.vnoremap("<leader>sa", [[<ESC>:%s/<c-r>=GetVisual()<CR>/]])
utils.nnoremap("<leader>sa", [[:%s/\<<C-r><C-w>\>/]])

-- Start the find and replace command from the current line to the end line
utils.vnoremap("<leader>sf", [[<ESC>:.,$s/<c-r>=GetVisual()<CR>/]])
utils.nnoremap("<leader>sf", [[:.,$s/\<<C-r><C-w>\>/]])

-- HighlightToggle
utils.nnoremap("z/", [[:if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>]])
utils.nnoremap("<A-n>", '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>')
utils.nnoremap("<A-N>", '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
utils.nnoremap("zn", '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>')
utils.nnoremap("zN", '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')

-- Copy local clipboard
utils.vnoremap("<C-c>", [[:OSCYank<CR>]])

-- IndentBlanklineToggle
utils.nnoremap("<leader>i", [[<cmd>IndentBlanklineToggle<CR>]])

-- Directory set
utils.nnoremap("<leader>CD", [[<cmd>cd %:h<CR>]])
utils.nnoremap("<leader>RD", [[<cmd>Rooter<CR>]])

----------------------------------------------------------------------------
-- <leader>I/A | Prepend/Append to all adjacent lines with same indentation
----------------------------------------------------------------------------
utils.nmap("<leader>I", [[^vio<C-V>I]])
utils.nmap("<leader>A", [[^vio<C-V>$A]])

----------------------------------------------------------------------------
-- refactoring
----------------------------------------------------------------------------
utils.vnoremap("<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]])
utils.vnoremap("<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]])
utils.vnoremap("<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]])
utils.vnoremap("<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]])
-- Extract block doesn't need visual mode
utils.nnoremap("<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]])
utils.nnoremap("<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]])
-- Inline variable can also pick up the identifier currently under the cursor without visual mode
utils.nnoremap("<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]])
-- prompt for a refactor to apply when the remap is triggered
utils.vnoremap("<leader>rr", [[ <Cmd>lua require('refactoring').select_refactor()<CR>]])

-- bujo
-- utils.nnoremap("[a", [[<cmd>Todo<CR>]])
-- utils.nnoremap("[A", [[<cmd>Todo g<CR>]])
-- utils.nmap("<C-]>", [[<Plug>BujoAddnormal]])
-- utils.imap("<C-]>", [[<Plug>BujoAddinsert]])
-- utils.nmap("<C-q>", [[<Plug>BujoChecknormal]])
-- utils.imap("<C-q>", [[<Plug>BujoCheckinsert]])

-- -- todo-comments
-- utils.nnoremap("<leader>xt", [[:TodoTelescope<CR>]])

-- trouble
-- vim.cmd[[
-- nnoremap <leader>xx <cmd>TroubleToggle<cr>
-- nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
-- nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
-- nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
-- nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
-- nnoremap gR <cmd>TroubleToggle lsp_references<cr>
-- ]]
-- utils.nnoremap("<leader>xx", [[":TroubleToggle<CR>"]])
-- utils.nnoremap("<leader>xw", [["<cmd>Trouble workspace_diagnostics<cr>"]])
-- utils.nnoremap("<leader>xd", [["<cmd>Trouble document_diagnostics<cr>"]])
-- utils.nnoremap("<leader>xl", [["<cmd>Trouble loclist<cr>"]])
-- utils.nnoremap("<leader>xq", [["<cmd>Trouble quickfix<cr>"]])
-- utils.nnoremap("gR", [["<cmd>Trouble lsp_references<cr>"]])
