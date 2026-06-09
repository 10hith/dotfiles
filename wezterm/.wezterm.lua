local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- General appearance
config.font = wezterm.font("BlexMono Nerd Font Mono")
config.font_size = 17

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

-- coolnight colorscheme
config.colors = {
    foreground = "#CBE0F0",
    background = "#011423",
    cursor_bg = "#47FF9C",
    cursor_border = "#47FF9C",
    cursor_fg = "#011423",
    selection_bg = "#033259",
    selection_fg = "#CBE0F0",
    ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
    brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- Launch zellij on startup (macOS)
config.default_prog = { "/bin/zsh", "-l", "-c", "zellij" }

-- macOS: use Option as Meta key, leave native option-key combos alone
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Disable the yes/no close confirmation
config.window_close_confirmation = "NeverPrompt"

-- Extra convenience keys
config.keys = {
  -- Reload wezterm config
  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ReloadConfiguration,
  },
  -- Launch a new zellij session manually if needed
  {
    key = "Z",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("zellij\n"),
  },
}

-- dictation on wezterm
config.use_ime = true

return config

