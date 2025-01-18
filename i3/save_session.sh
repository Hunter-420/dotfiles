#!/bin/bash
SESSION_FILE=~/.config/i3/session.json

# Create an empty JSON array
echo "[]" > "$SESSION_FILE"

wmctrl -lG | while read -r line; do
  # Parse fields from wmctrl output
  window_id=$(echo "$line" | awk '{print $1}')
  x=$(echo "$line" | awk '{print $3}')
  y=$(echo "$line" | awk '{print $4}')
  width=$(echo "$line" | awk '{print $5}')
  height=$(echo "$line" | awk '{print $6}')
  class=$(xprop -id "$window_id" WM_CLASS | awk -F'"' '/WM_CLASS/{print $2}')

  # Skip if class is empty
  if [[ -z "$class" ]]; then
    continue
  fi

  # Append to JSON
  jq --arg id "$window_id" \
     --arg x "$x" \
     --arg y "$y" \
     --arg width "$width" \
     --arg height "$height" \
     --arg class "$class" \
     '. + [{"id": $id, "x": ($x|tonumber), "y": ($y|tonumber), "width": ($width|tonumber), "height": ($height|tonumber), "class": $class}]' \
     "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
done

