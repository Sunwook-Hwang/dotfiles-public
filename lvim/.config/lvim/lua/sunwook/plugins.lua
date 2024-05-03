lvim.plugins = {
  -- { "xolox/vim-session" },
  -- { "xolox/vim-misc" },
  -- { "easymotion/vim-easymotion" },
  "ofirgall/ofirkai.nvim",
  "rebelot/kanagawa.nvim",
  "lunarvim/synthwave84.nvim",
  {
    "projekt0n/github-nvim-theme",
    version = "v0.0.7",
  },
  "tpope/vim-repeat",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "kylechui/nvim-surround",
  "rafi/awesome-vim-colorschemes",
  "lunarvim/colorschemes",
  "morhetz/gruvbox",
  "windwp/nvim-spectre",
  "mbbill/undotree",
  "karb94/neoscroll.nvim",
  "lervag/vimtex",
  "airblade/vim-rooter",
  "Pocco81/TrueZen.nvim",
  "ghillb/cybu.nvim",
  "kazhala/close-buffers.nvim",
  "AckslD/swenv.nvim",
  "simrat39/rust-tools.nvim",
  "mfussenegger/nvim-dap-python",
  "simrat39/symbols-outline.nvim",
  "p00f/clangd_extensions.nvim",
  "catppuccin/nvim",
  {
    "kartikp10/noctis.nvim",
    dependencies = { "rktjmp/lush.nvim" },
  },
  {
    -- You can generate docstrings automatically.
    "danymat/neogen",
    config = function()
      require("neogen").setup {
        enabled = true,
        languages = {
          python = {
            template = {
              annotation_convention = "numpydoc",
            },
          },
        },
      }
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    -- module = "persistence",
    config = function()
      require("persistence").setup {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"), -- directory where session files are saved
        options = { "buffers", "curdir", "tabpages", "winsize" },
      }
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = { "VimEnter" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup {
          -- LunarVim users need to specify path to the plugin manager
          plugin_manager_path = os.getenv "LUNARVIM_RUNTIME_DIR" .. "/site/pack/packer",
        }
      end, 100)
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup {
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
        popup = {
          border = "rounded",
        },
      }
    end,
  },
  -- You can run blocks of code like jupyter notebook.
  {
    "dccsillag/magma-nvim",
    build = ":UpdateRemotePlugins",
  },
  -- {
  --   "j-hui/fidget.nvim",
  --   config = function()
  --     require("fidget").setup {
  --     }
  --   end,
  -- },
  -- {
  --   "folke/noice.nvim",
  --   event = "VimEnter",
  --   config = function()
  --     require("noice").setup()
  --   end,
  --   requires = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --   },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
