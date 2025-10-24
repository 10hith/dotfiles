local wezterm = require("wezterm")

local config = {}

-- General appearance
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Fira Code",
  "Noto Color Emoji"
})
config.font_size = 11.5
config.color_scheme = "Catppuccin Mocha" -- You can change to another scheme
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.window_background_opacity = 0.95
config.default_prog = { "wsl.exe", "~", "-e", "zellij" }

-- Disable the yes/no close confirrmation
config.window_close_confirmation = "NeverPrompt"

-- Extra convenience keys
config.keys = {
  -- Reload wezterm config
  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ReloadConfiguration,
  },
  -- Launch zellij manually if needed
  {
    key = "Z",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("zellij\n"),
  },
}

return config

