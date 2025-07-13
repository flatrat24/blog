#!/usr/bin/env bash

today="$(date '+%Y-%m-%d')"
buffer="$(mktemp)"

{ echo "+++"; echo "date=$today"; echo ""; echo "[extra]"; echo "song_title="; echo "song_url="; echo "+++"; } >> "$buffer"

mv "$buffer" "$HOME/blog/content/journal/$today.md"

nvim "$HOME/blog/content/journal/$today.md"
