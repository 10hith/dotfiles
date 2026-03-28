#!/usr/bin/env bash
# clean_dev_caches.sh — Clears Python and Node package manager caches.
# Safe to run automatically; caches are rebuilt on demand.
# Logs to ~/.cache/clean_dev_caches.log

set -euo pipefail

LOG="$HOME/.cache/clean_dev_caches.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() { echo "[$TIMESTAMP] $*" | tee -a "$LOG"; }

log "=== Dev cache cleanup started ==="

freed=0

# pip
if command -v pip &>/dev/null; then
    before=$(du -sb "$HOME/.cache/pip" 2>/dev/null | awk '{print $1}' || echo 0)
    pip cache purge -q
    after=$(du -sb "$HOME/.cache/pip" 2>/dev/null | awk '{print $1}' || echo 0)
    freed=$(( freed + before - after ))
    log "pip cache cleared ($(( (before - after) / 1024 / 1024 )) MB)"
fi

# uv
if command -v uv &>/dev/null; then
    before=$(du -sb "$HOME/.cache/uv" 2>/dev/null | awk '{print $1}' || echo 0)
    uv cache clean -q
    after=$(du -sb "$HOME/.cache/uv" 2>/dev/null | awk '{print $1}' || echo 0)
    freed=$(( freed + before - after ))
    log "uv cache cleared ($(( (before - after) / 1024 / 1024 )) MB)"
fi

# npm
if command -v npm &>/dev/null; then
    before=$(du -sb "$HOME/.npm" 2>/dev/null | awk '{print $1}' || echo 0)
    npm cache clean --force -q 2>/dev/null
    after=$(du -sb "$HOME/.npm" 2>/dev/null | awk '{print $1}' || echo 0)
    freed=$(( freed + before - after ))
    log "npm cache cleared ($(( (before - after) / 1024 / 1024 )) MB)"
fi

# TypeScript language server cache
if [ -d "$HOME/.cache/typescript" ]; then
    before=$(du -sb "$HOME/.cache/typescript" 2>/dev/null | awk '{print $1}' || echo 0)
    rm -rf "$HOME/.cache/typescript"
    freed=$(( freed + before ))
    log "TypeScript cache cleared ($(( before / 1024 / 1024 )) MB)"
fi

log "=== Done. Total freed: $(( freed / 1024 / 1024 )) MB ==="
