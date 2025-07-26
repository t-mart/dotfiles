local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

config = wezterm.config_builder()

config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

config.default_prog = { 'nu' }

config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")

config.default_cursor_style = 'SteadyBlock'

config.hide_tab_bar_if_only_one_tab = true

config.colors = {
  foreground = '#ebdbb2',
  background = '#282828',

  cursor_bg = '#ebdbb2',
  cursor_fg = '#282828',
  cursor_border = '#ebdbb2',

  selection_fg = 'none',
  selection_bg = '#504945',

  copy_mode_active_highlight_bg = { Color = '#fe8019' },
  copy_mode_active_highlight_fg = { Color = '#282828' },
  copy_mode_inactive_highlight_bg = { Color = '#a89984' },
  copy_mode_inactive_highlight_fg = { Color = '#282828' },

  quick_select_label_bg = { Color = '#fabd2f' },
  quick_select_label_fg = { Color = '#282828' },

  -- neutral gruvbox colors
  ansi = {
    '#282828', -- black
    '#cc241d', -- red
    '#98971a', -- green
    '#d79921', -- yellow
    '#458588', -- blue
    '#b16286', -- magenta
    '#689d6a', -- cyan
    '#a89984', -- white
  },

  -- bright gruvbox colors
  brights = {
    '#928374', -- black
    '#fb4934', -- red
    '#b8bb26', -- green
    '#fabd2f', -- yellow
    '#83a598', -- blue
    '#d3869b', -- magenta
    '#8ec07c', -- cyan
    '#fbf1c7', -- white
  },

  indexed = {
    [16] = '#d65d0e', -- faded orange
    [17] = '#fe8019', -- neutral orange
  },
}

--====================================================================--

-- Finally, return the configuration to wezterm
return config