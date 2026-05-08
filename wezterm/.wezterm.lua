local wezterm = require("wezterm")

local config = {}

-- General appearance
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Fira Code",
  "Noto Color Emoji"
})
config.font_size = 15
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.window_background_opacity = 0.95

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

