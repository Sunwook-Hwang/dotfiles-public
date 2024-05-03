local wezterm = require("wezterm")

return {
  -- color_scheme = "Gruvbox Dark",
  window_background_opacity = 0.6,
  hide_tab_bar_if_only_one_tab = true,

  use_fancy_tab_bar = false,
  window_padding = {
    left = 1,
    right = 1,
    top = 0,
    bottom = 0,
  },

  font_size = 19.0,
  font = wezterm.font(
  -- "FiraCode Nerd Font Mono",
  -- "MesloLGM Nerd Font Mono",
  -- "RobotoMono Nerd Font",
    "JetBrainsMono Nerd Font Mono",
    -- "JetBrains Mono",
    -- "Inconsolata Nerd Font Mono",
    -- "UbuntuMono Nerd Font Mono",
    { bold = false, weight = "Regular", stretch = "Normal", italic = false }
  ),

  window_background_image = "/Users/sunwook/Google Drive/My Drive/99_ETC(utils)/windows terminal settings/ggb3.jpg",
  window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.4,

    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,

    -- You can adjust the saturation also.
    saturation = 1.0,
  },

  -- line_height = 1.3,
  -- How many lines of scrollback you want to retain per tab
  scrollback_lines = 10000,

  -- keysettings
  native_macos_fullscreen_mode = true,
  keys = {
    { key = "n", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
  },

  -- Color settings
  -- colors = {
  -- 	-- -- The default text color
  -- 	-- foreground = "silver",
  -- 	-- -- The default background color
  -- 	-- background = "black",
  --
  -- 	-- Overrides the cell background color when the current cell is occupied by the
  -- 	-- cursor and the cursor style is set to Block
  -- 	cursor_bg = "#52ad70",
  -- 	-- Overrides the text color when the current cell is occupied by the cursor
  -- 	cursor_fg = "black",
  -- 	-- Specifies the border color of the cursor when the cursor style is set to Block,
  -- 	-- of the color of the vertical or horizontal bar when the cursor style is set to
  -- 	-- Bar or Underline.
  -- 	cursor_border = "#52ad70",
  --
  -- 	-- -- the foreground color of selected text
  -- 	-- selection_fg = "black",
  -- 	-- -- the background color of selected text
  -- 	-- selection_bg = "#fffacd",
  --
  -- 	-- -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  -- 	-- scrollbar_thumb = "#222222",
  --
  -- 	-- -- The color of the split lines between panes
  -- 	-- split = "#444444",
  --
  -- 	-- ansi = {"black", "maroon", "green", "olive", "navy", "purple", "teal", "silver"},
  -- 	-- brights = {"grey", "red", "lime", "yellow", "blue", "fuchsia", "aqua", "white"},
  -- 	-- -- Arbitrary colors of the palette in the range from 16 to 255
  -- 	-- indexed = {[136] = "#af8700"},
  -- },
}
