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
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$used_pct" ] && [ -n "$remaining_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    remaining_int=$(printf '%.0f' "$remaining_pct")
    context_info=" [$(printf '\033[33m')${used_int}%% used$(printf '\033[0m') / $(printf '\033[32m')${remaining_int}%% left$(printf '\033[0m')]"
fi

reset_info=""
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
five_hour_used_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -z "$five_hour_used_pct" ]; then
    five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used // empty')
    five_hour_limit=$(echo "$input" | jq -r '.rate_limits.five_hour.limit // empty')
    if [ -n "$five_hour_used" ] && [ -n "$five_hour_limit" ] && [ "$five_hour_limit" != "0" ]; then
        five_hour_used_pct=$(awk "BEGIN { printf \"%.1f\", ($five_hour_used / $five_hour_limit) * 100 }")
    fi
fi
if [ -n "$five_hour_resets_at" ]; then
    five_hour_reset_time=$(date -d "@${five_hour_resets_at}" +"%H:%M" 2>/dev/null || date -r "$five_hour_resets_at" +"%H:%M" 2>/dev/null)
    if [ -n "$five_hour_used_pct" ]; then
        five_hour_used_int=$(printf '%.0f' "$five_hour_used_pct")
        reset_info="${reset_info} [5h: $(printf '\033[33m')${five_hour_used_int}%%$(printf '\033[0m') | reset $(printf '\033[36m')${five_hour_reset_time}$(printf '\033[0m')]"
    else
        reset_info="${reset_info} [$(printf '\033[36m')5h reset: ${five_hour_reset_time}$(printf '\033[0m')]"
    fi
fi

seven_day_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
seven_day_used_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -z "$seven_day_used_pct" ]; then
    seven_day_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used // empty')
    seven_day_limit=$(echo "$input" | jq -r '.rate_limits.seven_day.limit // empty')
    if [ -n "$seven_day_used" ] && [ -n "$seven_day_limit" ] && [ "$seven_day_limit" != "0" ]; then
        seven_day_used_pct=$(awk "BEGIN { printf \"%.1f\", ($seven_day_used / $seven_day_limit) * 100 }")
    fi
fi
if [ -n "$seven_day_resets_at" ]; then
    seven_day_reset_time=$(date -d "@${seven_day_resets_at}" +"%a %H:%M" 2>/dev/null || date -r "$seven_day_resets_at" +"%a %H:%M" 2>/dev/null)
    if [ -n "$seven_day_used_pct" ]; then
        seven_day_used_int=$(printf '%.0f' "$seven_day_used_pct")
        reset_info="${reset_info} [7d: $(printf '\033[33m')${seven_day_used_int}%%$(printf '\033[0m') | reset $(printf '\033[36m')${seven_day_reset_time}$(printf '\033[0m')]"
    else
        reset_info="${reset_info} [$(printf '\033[36m')7d reset: ${seven_day_reset_time}$(printf '\033[0m')]"
    fi
fi

printf "$(printf '\033[32m')%s$(printf '\033[0m') in $(printf '\033[34m')%s$(printf '\033[0m')%s [%s]%s%s" \
    "$model_name" "$(basename "$current_dir")" "$git_branch" "$output_style" "$context_info" "$reset_info"
