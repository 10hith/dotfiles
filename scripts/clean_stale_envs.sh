#!/usr/bin/env bash
# clean_stale_envs.sh — Finds and removes stale Python venvs and node_modules.
# "Stale" = not modified in DAYS_THRESHOLD days (default: 30).
# Run interactively to review before deleting; pass --force to skip confirmation.
#
# Usage:
#   ./clean_stale_envs.sh              # interactive, 30-day threshold
#   ./clean_stale_envs.sh --days 60    # 60-day threshold
#   ./clean_stale_envs.sh --force      # no confirmation prompt
#   ./clean_stale_envs.sh --dry-run    # show what would be deleted, do nothing

set -euo pipefail

DAYS_THRESHOLD=30
FORCE=false
DRY_RUN=false

# --- Dirs that must never be deleted ---
SKIP_PATTERNS=(
    "$HOME/.nvm"
    "$HOME/.windsurf-server"
    "$HOME/.windsurf-server-next"
    "$HOME/.vscode-server"
    "$HOME/.vscode-server-server"
    "$HOME/.antigravity-server"
    "$HOME/.void-server"
    "$HOME/.local/share"
    "$HOME/.config"
    "$HOME/.cache"
    "$HOME/miniconda3"
    "$HOME/.conda"
    "$HOME/bloop/OrdeloAgent"   # active project
)

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)   DAYS_THRESHOLD="$2"; shift 2 ;;
        --force)  FORCE=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

is_skipped() {
    local path="$1"
    for pattern in "${SKIP_PATTERNS[@]}"; do
        if [[ "$path" == "$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

hr() { printf '%0.s-' {1..60}; echo; }

echo "Scanning for stale envs (not modified in ${DAYS_THRESHOLD}+ days)..."
hr

STALE_VENVS=()
STALE_NODE_MODULES=()
TOTAL_SIZE=0

# Find stale Python venvs (.venv / venv / env)
while IFS= read -r dir; do
    is_skipped "$dir" && continue
    size=$(du -sb "$dir" 2>/dev/null | awk '{print $1}' || echo 0)
    STALE_VENVS+=("$dir|$size")
    TOTAL_SIZE=$(( TOTAL_SIZE + size ))
done < <(find "$HOME" -maxdepth 6 \
    \( -name ".venv" -o -name "venv" -o -name "env" \) \
    -type d \
    -not -path "*/\.*server*" \
    -not -path "*/miniconda*" \
    -not -path "*/.nvm/*" \
    -mtime +"$DAYS_THRESHOLD" \
    2>/dev/null | sort)

# Find stale node_modules (top-level only)
while IFS= read -r dir; do
    is_skipped "$dir" && continue
    size=$(du -sb "$dir" 2>/dev/null | awk '{print $1}' || echo 0)
    STALE_NODE_MODULES+=("$dir|$size")
    TOTAL_SIZE=$(( TOTAL_SIZE + size ))
done < <(find "$HOME" -maxdepth 6 \
    -name "node_modules" \
    -type d \
    -not -path "*/node_modules/*/node_modules" \
    -not -path "*/\.*server*" \
    -not -path "*/.nvm/*" \
    -not -path "*/.local/share/*" \
    -not -path "*/.config/*" \
    -not -path "*/.cache/*" \
    -mtime +"$DAYS_THRESHOLD" \
    2>/dev/null | sort)

# Display findings
if [[ ${#STALE_VENVS[@]} -eq 0 && ${#STALE_NODE_MODULES[@]} -eq 0 ]]; then
    echo "Nothing stale found."
    exit 0
fi

if [[ ${#STALE_VENVS[@]} -gt 0 ]]; then
    echo "Python venvs:"
    for entry in "${STALE_VENVS[@]}"; do
        path="${entry%|*}"
        size="${entry##*|}"
        printf "  %-70s %s\n" "$path" "$(( size / 1024 / 1024 )) MB"
    done
    hr
fi

if [[ ${#STALE_NODE_MODULES[@]} -gt 0 ]]; then
    echo "node_modules:"
    for entry in "${STALE_NODE_MODULES[@]}"; do
        path="${entry%|*}"
        size="${entry##*|}"
        printf "  %-70s %s\n" "$path" "$(( size / 1024 / 1024 )) MB"
    done
    hr
fi

echo "Total to free: $(( TOTAL_SIZE / 1024 / 1024 )) MB"

if $DRY_RUN; then
    echo "[dry-run] Nothing deleted."
    exit 0
fi

if ! $FORCE; then
    read -rp "Delete all of the above? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

echo "Deleting..."
for entry in "${STALE_VENVS[@]}" "${STALE_NODE_MODULES[@]}"; do
    path="${entry%|*}"
    echo "  rm -rf $path"
    rm -rf "$path"
done

echo "Done. Freed ~$(( TOTAL_SIZE / 1024 / 1024 )) MB."
