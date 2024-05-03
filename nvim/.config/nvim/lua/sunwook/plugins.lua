local fn = vim.fn
-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local util = require("packer.util")
packer.init({
  git = { clone_timeout = 300 },
  display = {
    open_fn = function()
      return util.float({ border = "rounded" })
    end,
  },
  -- compile_path = util.join_paths("~/.config", "packer_compiled.lua"),
})

return packer.startup(function(use)
  local use = use

  -- Packer can manage itself
  use({ "wbthomason/packer.nvim" })

  -- use {'ryanoasis/vim-devicons'}
  use({ "kyazdani42/nvim-web-devicons" })
  use({ "kyazdani42/nvim-tree.lua" })

  use({ "tpope/vim-repeat" })
  use({ "tpope/vim-surround" })
  -- use {'tpope/vim-commentary'}
  use({ "numToStr/Comment.nvim" })

  use({ "tpope/vim-fugitive" }) -- Commands -> :Gdiff
  use({ "lewis6991/gitsigns.nvim" }) -- Indicating the lines which are tracked by git + - ~
  use({ "kdheepak/lazygit.nvim" })

  use({
    "nvim-telescope/telescope.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
    },
  })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  -- use({"fhill2/telescope-ultisnips.nvim"})
  -- use {'nvim-telescope/telescope-media-files.nvim'}
  -- use {'nvim-telescope/telescope-project.nvim'}
  use({ "ahmedkhalf/project.nvim" })

  -- Plugins for lsp
  use({
    -- "folke/lsp-colors.nvim",
    "nvim-lua/plenary.nvim",
    "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
    "RRethy/vim-illuminate",
  })
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
 'tamago324/nlsp-settings.nvim',
}
  -- Completion
  use({
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    {
      "hrsh7th/nvim-cmp",
      -- commit = "4f1358e659d51c69055ac935e618b684cf4f1429",
    },
    "hrsh7th/cmp-nvim-lsp-document-symbol",
    "onsails/lspkind.nvim",
    -- luasnip
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- vsnip
    -- "hrsh7th/cmp-vsnip",
    -- "hrsh7th/vim-vsnip",

    -- ultisnip
    -- "SirVer/ultisnips",
    -- "quangnguyen30192/cmp-nvim-ultisnips",

    -- preconfiguration snippets
    "rafamadriz/friendly-snippets",
    -- "honza/vim-snippets",
  })
  use({ "simrat39/symbols-outline.nvim" })
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }) -- We recommend updating the parsers on update
  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
    -- "p00f/nvim-ts-rainbow",
    "andymass/vim-matchup",
  })

  -- Buffers
  use({ "romgrk/barbar.nvim" })
  use({ "moll/vim-bbye" })

  -- Plugins for color themes
  use 'Mofiqul/vscode.nvim'
  use({ "lunarvim/colorschemes" })
  use({ "rafi/awesome-vim-colorschemes" })
  use({ "romgrk/doom-one.vim" })
  use({ "dracula/vim", as = "dracula" })
  use({ "mhinz/vim-janah" })
  use({ "nanotech/jellybeans.vim" })
  -- use({ "wojciechkepka/vim-github-dark" })
  use({ "sainnhe/sonokai" })
  use({ "folke/tokyonight.nvim" })
  use({ "EdenEast/nightfox.nvim" })
  use({ "savq/melange" })
  use({ "rebelot/kanagawa.nvim" })
  use({ "bluz71/vim-moonfly-colors" })
  use({ "vv9k/vim-github-dark" })
  use({ "nocksock/bloop-vim" })
  use({ "sainnhe/everforest" })

  -- UI
  use({ "windwp/nvim-autopairs" })
  use({ "lukas-reineke/indent-blankline.nvim" })
  -- use({ "blueyed/vim-diminactive" })
  use("MattesGroeger/vim-bookmarks")
  use({ "mbbill/undotree" })

  use({ "xolox/vim-session" })
  use({ "xolox/vim-misc" })

  -- use({ "junegunn/goyo.vim" })
  -- use({ "junegunn/limelight.vim" })
  use({ "Pocco81/TrueZen.nvim" })

  use({ "akinsho/nvim-toggleterm.lua" })

  -- use({ "glepnir/dashboard-nvim" })
  use({ "goolord/alpha-nvim" })
  use({ "hoob3rt/lualine.nvim", "SmiteshP/nvim-gps" })

  use({ "dstein64/vim-startuptime" })

  use({ "ojroques/vim-oscyank" })

  -- use({ "folke/trouble.nvim" })
  -- use({ "folke/todo-comments.nvim" })

  -- use{'junegunn/rainbow_parentheses.vim'}
  -- File explorer
  -- use({ "preservim/nerdtree" })
  -- use {'psf/black'}
  -- use {'ambv/black'}
  use({ "ThePrimeagen/refactoring.nvim" })
  -- use({
  -- 	"ThePrimeagen/refactoring.nvim",
  -- 	requires = {
  -- 		{ "nvim-lua/plenary.nvim" },
  -- 		{ "nvim-treesitter/nvim-treesitter" },
  -- 	},
  -- })
  use({ "lewis6991/impatient.nvim" })
  use({ "airblade/vim-rooter" })

  -- Latex
  use({ "lervag/vimtex" })
  -- use({ "nvim-neorg/neorg" })
  -- use({ "nvim-orgmode/orgmode" })
  -- use({ "vuciv/vim-bujo" })

  use({ "antoinemadec/FixCursorHold.nvim" })
  use({ "github/copilot.vim" })

  use({
    "sychen52/smart-term-esc.nvim",
    config = function()
      require("smart-term-esc").setup({
        key = "<Esc>",
        except = { "nvim", "fzf" },
      })
    end,
  })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
