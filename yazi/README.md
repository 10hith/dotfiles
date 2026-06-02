# Yazi Config

Terminal file manager with image/PDF/video previews, git status, and catppuccin-mocha theme.

## Deploy (Mac & Ubuntu — same paths)

```zsh
mkdir -p ~/.config/yazi
cp yazi/yazi.toml    ~/.config/yazi/yazi.toml
cp yazi/keymap.toml  ~/.config/yazi/keymap.toml
cp yazi/init.lua     ~/.config/yazi/init.lua
```

## Install plugins and flavor (one-time, after yazi is installed)

```zsh
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:max-preview
ya pkg add yazi-rs/plugins:hide-preview
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:jump-to-char
ya pkg add "yazi-rs/flavors:catppuccin-mocha"
```

Plugins land in `~/.config/yazi/plugins/` and `~/.config/yazi/flavors/` — not tracked in this repo.

## Install yazi itself

**Mac:**
```zsh
brew install yazi ffmpegthumbnailer poppler imagemagick sevenzip
```

**Ubuntu/WSL:**
```zsh
cargo install --locked yazi-fm yazi-cli
sudo apt install -y ffmpegthumbnailer poppler-utils imagemagick p7zip-full
```

## Usage

| Command | What it does |
|---------|-------------|
| `yy`    | Open yazi; cd to wherever you quit (primary entry point) |
| `y`     | Open yazi without cd-on-quit |
