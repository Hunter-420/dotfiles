#!/bin/bash
SESSION_FILE=~/.config/i3/session.json

if [[ ! -f $SESSION_FILE ]]; then
  echo "No session file found!"
  exit 1
fi

jq -c '.[]' "$SESSION_FILE" | while read -r window; do
  class=$(echo "$window" | jq -r '.class')
  x=$(echo "$window" | jq -r '.x')
  y=$(echo "$window" | jq -r '.y')
  width=$(echo "$window" | jq -r '.width')
  height=$(echo "$window" | jq -r '.height')

  # Launch the application
  i3-msg "exec $class"

  # Wait for the window and adjust its position
  sleep 1  # Adjust if necessary
  wmctrl -r "$class" -e 0,$x,$y,$width,$height
done

