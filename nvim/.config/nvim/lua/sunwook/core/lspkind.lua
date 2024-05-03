-- nvim_cmp formatting

local status_ok, lspkind = pcall(require, "lspkind")
if not status_ok then
  return
end

lspkind.setup({
  -- Defines how annotations are shown,
  -- can be 'text', 'text_symbol', 'symbol' or 'symbol_text'
  -- default: symbol_text
  mode = "symbol_text",

  -- Symbols list can be a preset or a table with custom icons
  -- 'default' and 'mdi' (requires nerd-fonts font) or
  -- 'codicons' (requires vscode-codicons font)
  -- No need to worry about the order as this is managed by the plugin
  -- default: 'default'
  symbols = "default",
  -- or override preset symbols
  symbols = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = "",
    Namespace = "",
    Package = "",
    String = "",
    Number = "",
    Boolean = "",
    Array = "",
    Object = "",
    Key = "",
    Null = "ﳠ",
  },
})
