# Ghostty Config

Ghostty terminal config with coolnight palette, BlexMono Nerd Font, zellij auto-launch, and an optional cursor-trail shader.

## Deploy (Mac)

The active config is a symlink, so edits to `ghostty/config` apply immediately — no sync step.

Ghostty searches `~/.config/ghostty/config` before `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`, so we use the XDG path for consistency with the rest of `~/.config/` (nvim, zellij, kanata, karabiner).

```zsh
mkdir -p ~/.config/ghostty
ln -sf "$PWD/ghostty/config" ~/.config/ghostty/config
```

> **Note**: don't use Ghostty's in-app Settings GUI — it writes to `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` and Ghostty would silently start preferring that file. Edit `ghostty/config` directly.

Reload in-app with `⌘⇧R` (`super+shift+r=reload_config`).

## Cursor shaders

Two shaders are chained — Ghostty composites them in order:

1. `cursor_blaze.glsl` — comet-style trail, from [hackr-sh/ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders).
2. `sonic_boom_cursor.glsl` — expanding ring on cursor-shape change (e.g. vim block ↔ line), from [sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders).

```zsh
# 1. Clone the upstream repos somewhere (one-time)
git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders ~/ghRepos/ghostty-shaders
git clone --depth 1 https://github.com/sahaj-b/ghostty-cursor-shaders ~/ghRepos/ghostty-cursor-shaders

# 2. Copy the chosen shaders into ghostty's config dir
mkdir -p ~/.config/ghostty/shaders
cp ~/ghRepos/ghostty-shaders/cursor_blaze.glsl              ~/.config/ghostty/shaders/
cp ~/ghRepos/ghostty-cursor-shaders/sonic_boom_cursor.glsl  ~/.config/ghostty/shaders/
```

The config references both, plus `custom-shader-animation = always` so the boom doesn't freeze when the window loses focus (the cursor goes hollow):

```ini
custom-shader = ~/.config/ghostty/shaders/cursor_blaze.glsl
custom-shader = ~/.config/ghostty/shaders/sonic_boom_cursor.glsl
custom-shader-animation = always
```

To swap effects, drop a different `.glsl` into `~/.config/ghostty/shaders/` and point the directive at it. Alternatives:

- Trails: `smear_cursor_blocks.glsl`, `cursor_warp.glsl`, `cursor_sweep.glsl`, `cursor_tail.glsl`.
- Booms: `rectangle_boom_cursor.glsl` (cursor-shaped instead of circular), `ripple_cursor.glsl` (hollow ring), `ripple_rectangle_cursor.glsl`.

Tweak duration, color, radius etc. by editing the `CONFIGURATION` block at the top of each shader. Then `⌘⇧R` to reload.

Shaders live outside this repo (in `~/.config/ghostty/shaders/`) because they're upstream files, not personal config.
