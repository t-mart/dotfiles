local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

config.initial_cols = 120
config.initial_rows = 32

config.default_prog = { 'nu' }

-- i'm not sure how this all really works, but the 1Password SSH agent won't
-- work if wezterm is using its own agent. see
-- https://wezterm.org/config/lua/config/default_ssh_auth_sock.html and
-- https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent
--
-- recommended way to interrogate the platform is to use
-- `wezterm.target_triple`. see
-- https://wezterm.org/config/lua/wezterm/target_triple.html
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_ssh_auth_sock = "\\\\.\\pipe\\openssh-ssh-agent"
end

config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")

config.default_cursor_style = 'SteadyBlock'

config.hide_tab_bar_if_only_one_tab = true

-- https://github.com/wezterm/wezterm/discussions/3541#discussioncomment-5633570
-- right-click to copy selection or paste if no selection
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
      end
    end),
  },
}

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

return config
