#!/usr/bin/env bash
set -euo pipefail

# Copies the files listed in files_to_be_copied.md into this repository.
# The list supports optional inline destinations or block destinations defined
# by lines that start with "Copy below to".

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
list_file="$repo_root/files_to_be_copied.md"

if [[ ! -f "$list_file" ]]; then
  echo "List file not found: $list_file" >&2
  exit 1
fi

expand_pattern() {
  local pattern="$1"
  local quoted
  printf -v quoted '%q' "$pattern"
  bash -lc "shopt -s nullglob dotglob; for path in $quoted; do printf '%s\\0' \"\$path\"; done"
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

  src=""
  dest_hint=""
  IFS=' ' read -r src dest_hint <<< "$line"

  if [[ -z "$src" ]]; then
    continue
  fi

  [[ "$src" == \~* ]] && src="${src/#\~/$HOME}"

  has_glob=0
  if [[ "$src" == *[\*\?\[]* ]]; then
    has_glob=1
  fi

  mapfile -d '' -t expanded < <(expand_pattern "$src")

  if ((${#expanded[@]} == 0)); then
    if (( has_glob )); then
      echo "Warning: no matches for pattern $src" >&2
      continue
    else
      echo "Source not found: $src" >&2
      exit 1
    fi
  fi

  for source_path in "${expanded[@]}"; do
    if [[ ! -e "$source_path" ]]; then
      if (( has_glob )); then
        echo "Warning: skipping missing match $source_path" >&2
        continue
      else
        echo "Source not found: $source_path" >&2
        exit 1
      fi
    fi

    dest="$dest_hint"

    if [[ -z "$dest" ]]; then
      if [[ -n "$current_target_dir" ]]; then
        dest="$current_target_dir/$(basename "$source_path")"
      elif [[ "$source_path" == */Zed/* ]]; then
        dest="Zed/${source_path#*/Zed/}"
      elif [[ "$source_path" == */Windsurf/* ]]; then
        dest="Windsurf/${source_path#*/Windsurf/}"
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
      awk 'tolower($0) !~ /api_/' "$source_path" > "$abs_dest"
    else
      cp -p "$source_path" "$abs_dest"
    fi

    echo "Copied $source_path -> $dest"
  done

done < "$list_file"
