-- nvim_cmp formatting
local lspkind = require("lspkind")

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

-- Setup nvim-cmp.
local cmp = require("cmp")
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-space>"] = cmp.mapping({
      i = cmp.mapping.complete(),
      c = function(
    _ --[[fallback]]
      )
        if cmp.visible() then
          if not cmp.confirm({ select = true }) then
            return
          end
        else
          cmp.complete()
        end
      end,
    }),
    ["<CR>"] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),
    }),
    -- --
    -- ["<tab>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_next_item()
    -- 	elseif luasnip.expand_or_jumpable() then
    -- 		luasnip.expand_or_jump()
    -- 		-- elseif has_words_before() then
    -- 		-- 	cmp.complete()
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, { "i", "s" }),
    -- --
    -- ["<s-tab>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_prev_item()
    -- 	elseif luasnip.jumpable(-1) then
    -- 		luasnip.jump(-1)
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, { "i", "s" }),

    --
    ["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        -- elseif has_words_before() then
        -- 	cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    --
    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-k>"] = cmp.mapping(function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { "i", "s" }),

    ["<C-j>"] = cmp.mapping(function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { "i", "s" }),

    -- ["<C-l>"] = cmp.mapping(function()
    -- 	if luasnip.choice_active() then
    -- 		luasnip.change_choice(1)
    -- 	end
    -- end, { "i" }),
  },
  sorting = {
    -- TODO: Would be cool to add stuff like "See variable names before method names" in rust, or something like that.
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,

      -- copied from cmp-under, but I don't think I need the plugin for this.
      -- I might add some more of my own.
      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  sources = cmp.config.sources({
    -- { name = "neorg" },
    -- { name = "orgmode" },
    { name = "luasnip" }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    {
      name = "buffer",
      keyword_length = 5,
      option = {
        get_bufnrs = function()
          return { vim.api.nvim_get_current_buf() }
        end,
      },
    },
    { name = "path" },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    -- Youtube: How to set up nice formatting for your sources.
    format = lspkind.cmp_format({
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
        gh_issues = "[issues]",
        tn = "[TabNine]",
      },
      symbols = {
        Class = " ",
        Color = " ",
        Constant = "ﲀ ",
        Constructor = " ",
        Enum = "練",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = "",
        Folder = " ",
        Function = " ",
        Interface = "ﰮ ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Operator = "",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = "塞",
        Value = " ",
        Variable = " ",
      },
    }),
  },
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  completion = {
    autocomplete = false,
  },
  sources = cmp.config.sources({
    {
      name = "path",
    },
  }, {
    {
      name = "cmdline",
      max_item_count = 20,
      keyword_length = 4,
    },
  }),
})
