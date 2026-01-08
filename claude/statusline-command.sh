#!/bin/bash
# Claude Code Status Line Script
input=$(cat)
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
output_style=$(echo "$input" | jq -r '.output_style.name')

git_branch=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null || echo "")
    [ -n "$git_branch" ] && git_branch=" on $(printf '\033[35m')$git_branch$(printf '\033[0m')"
fi

context_info=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))
    context_info=" [$(printf '\033[33m')${pct}%%$(printf '\033[0m') ctx]"
fi

printf "$(printf '\033[32m')%s$(printf '\033[0m') in $(printf '\033[34m')%s$(printf '\033[0m')%s [%s]%s" \
    "$model_name" "$(basename "$current_dir")" "$git_branch" "$output_style" "$context_info"
