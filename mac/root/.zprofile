# ~/.zprofile — login shell (runs once when terminal opens)

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Cargo / Rust
export PATH="$HOME/.cargo/bin:$PATH"
