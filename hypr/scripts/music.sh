#!/bin/bash

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/music-art"
mkdir -p "$cache_dir"

resolve_cover() {
  local cover="$1"
  local cache_file

  [[ -n "$cover" ]] || return 1

  case "$cover" in
    file://*)
      printf '%s\n' "${cover#file://}"
      return 0
      ;;
    http://*|https://*)
      cache_file="$cache_dir/$(printf '%s' "$cover" | sha256sum | cut -d' ' -f1)"
      if [[ ! -f "$cache_file" ]] && command -v curl >/dev/null 2>&1; then
        curl -fsSL "$cover" -o "$cache_file" 2>/dev/null || rm -f "$cache_file"
      fi

      [[ -f "$cache_file" ]] && printf '%s\n' "$cache_file" && return 0
      ;;
  esac

  return 1
}

playerctl -p spotify metadata --follow \
  --format '{{status}}|{{mpris:artUrl}}|{{artist}}|{{title}}' |
  while IFS="|" read -r status cover artist title; do
    [[ "$status" == "Playing" && -n "$artist" && -n "$title" ]] || continue

    icon_args=()
    resolved_cover="$(resolve_cover "$cover")"

    if [[ -n "$resolved_cover" ]]; then
      icon_args=(-i "$resolved_cover")
    fi

    dunstify \
      -a "Spotify" \
      "${icon_args[@]}" \
      "$title" \
      "$artist"
  done
