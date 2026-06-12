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

## Cursor trail shader

Uses `cursor_blaze.glsl` from [0xhckr/ghostty-shaders](https://github.com/0xhckr/ghostty-shaders).

```zsh
# 1. Clone the shaders repo somewhere (one-time)
git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders ~/ghRepos/ghostty-shaders

# 2. Copy the chosen shader into ghostty's config dir
mkdir -p ~/.config/ghostty/shaders
cp ~/ghRepos/ghostty-shaders/cursor_blaze.glsl ~/.config/ghostty/shaders/shader.glsl
```

The config already references it:

```ini
custom-shader = ~/.config/ghostty/shaders/shader.glsl
```

To try a different effect, copy a different `.glsl` over `shader.glsl` — e.g. `smear_cursor_blocks.glsl` for a chunkier trail, or any of the background shaders (`cineShader-Lava.glsl`, `inside-the-matrix.glsl`, etc.). Then `⌘⇧R` to reload.

Shaders live outside this repo (in `~/.config/ghostty/shaders/`) because they're upstream files, not personal config.
