#!/usr/bin/env bash
set -euo pipefail

# Copies the files listed in files_to_be_copied_mac.md into this repository.
# Mac-specific variant of sync_files.sh — app configs land in mac/ subdirectory
# so they stay isolated from Windows/WSL configs in Code/, Windsurf/, Zed/.
# The list supports optional inline destinations or block destinations defined
# by lines that start with "Copy below to".

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
list_file="$repo_root/files_to_be_copied_mac.md"

if [[ ! -f "$list_file" ]]; then
  echo "List file not found: $list_file" >&2
  exit 1
fi

expand_pattern() {
  local pattern="$1"
  GLOB_PATTERN="$pattern" bash -c 'shopt -s nullglob dotglob; for path in $GLOB_PATTERN; do printf "%s\0" "$path"; done'
}

trim() {
  local var="$1"
  var="${var##+([[:space:]])}"
  var="${var%%+([[:space:]])}"
  printf '%s' "$var"
}

current_target_dir=""
shopt -s extglob

while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  line=$(trim "$raw_line")

  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^# ]] && continue

  if [[ "$line" =~ ^Copy[[:space:]]+below[[:space:]]+to[[:space:]]+(.+)$ ]]; then
    current_target_dir="${BASH_REMATCH[1]}"
    continue
  fi

  # Split on last space so paths like "~/Library/Application Support/..." work.
  # If the line has a space, last word is the dest hint and everything before is src.
  src=""
  dest_hint=""
  if [[ "$line" == *" "* ]]; then
    dest_hint="${line##* }"
    src="${line% *}"
  else
    src="$line"
  fi

  if [[ -z "$src" ]]; then
    continue
  fi

  [[ "$src" == \~* ]] && src="${src/#\~/$HOME}"

  has_glob=0
  if [[ "$src" == *[\*\?\[]* ]]; then
    has_glob=1
  fi

  expanded=()
  if (( has_glob )); then
    while IFS= read -r -d '' item; do
      expanded+=("$item")
    done < <(expand_pattern "$src")
  else
    # Non-glob path — use directly to preserve spaces in paths like ~/Library/Application Support/...
    expanded=("$src")
  fi

  if ((${#expanded[@]} == 0)); then
    echo "Warning: skipping missing source: $src" >&2
    continue
  fi

  for source_path in "${expanded[@]}"; do
    if [[ ! -e "$source_path" ]]; then
      echo "Warning: skipping missing source: $source_path" >&2
      continue
    fi

    if [[ "$source_path" == */cloudflared/run*.sh ]]; then
      continue
    fi

    dest="$dest_hint"

    if [[ -z "$dest" ]]; then
      if [[ -n "$current_target_dir" ]]; then
        dest="$current_target_dir/$(basename "$source_path")"
      elif [[ "$source_path" == */Zed/* ]]; then
        dest="Zed/${source_path#*/Zed/}"
      elif [[ "$source_path" == */Windsurf/* ]]; then
        dest="Windsurf/${source_path#*/Windsurf/}"
      elif [[ "$source_path" == */Code/User/* ]]; then
        dest="Code/${source_path##*/}"
      else
        echo "Unable to infer destination for $source_path" >&2
        exit 1
      fi
    else
      if [[ -d "$repo_root/$dest" ]]; then
        dest="$dest/$(basename "$source_path")"
      fi
    fi

    abs_dest="$repo_root/$dest"
    mkdir -p "$(dirname "$abs_dest")"

    if [[ "$dest" == "root/.bashrc" ]]; then
      awk 'tolower($0) !~ /api_/ && $0 !~ /^export[[:space:]]+[A-Z0-9_]+=/ ' "$source_path" > "$abs_dest"
    else
      cp -p "$source_path" "$abs_dest"
    fi

    echo "Copied $source_path -> $dest"
  done

done < "$list_file"
