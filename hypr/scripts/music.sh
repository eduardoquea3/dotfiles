#!/bin/bash

playerctl -p spotify metadata --follow \
  --format '{{mpris:artUrl}}|{{artist}}|{{title}}' |
  while IFS="|" read -r cover artist title; do
    dunstify \
      -a "Spotify" \
      -i "$cover" \
      "$title" \
      "$artist"
  done
