#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    printf 'Usage: copy-pane.sh SESSION_ID BLOCK_ID\n' >&2
    exit 1
fi

copy_file=$(/usr/bin/mktemp -t rex-copy)
trap 'rm -f "$copy_file"' EXIT
trap 'exit 130' INT
trap 'exit 143' HUP TERM

'/Users/basavaraj/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex' \
    -S 'unix:///Users/basavaraj/Library/Application%20Support/rex/server.sock' \
    capture -s "$1" -b "$2" --format=text --trim --unwrap > "$copy_file"

# Load the normal Neovim/LazyVim configuration, then customize this snapshot.
REX_COPY_BUFFER="$copy_file" REX_COPY_SOURCE_SESSION="$1" REX_COPY_SOURCE_BLOCK="$2" /opt/homebrew/bin/nvim \
    --cmd 'lua vim.api.nvim_create_autocmd("BufReadPre", { pattern = vim.env.REX_COPY_BUFFER, callback = function() vim.bo.modeline = false end })' \
    -i NONE -n \
    -c 'lua dofile("/Users/basavaraj/.config/rex/copy-mode.lua")' \
    -- "$copy_file"
