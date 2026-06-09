#!/bin/sh
QS=~/.config/quickshell/kittymenu/shell.qml

# Socket of the kitty we right-clicked in: listen_on appends the kitty PID,
# and Hyprland reports that same PID as the focused window's pid.
pid=$(hyprctl activewindow -j | jq -r '.pid')
sock="unix:/tmp/kitty.sock-$pid"

# Cursor position (global) and which monitor it's on
pos=$(hyprctl cursorpos)
gx=$(echo "$pos" | cut -d, -f1 | tr -d ' ')
gy=$(echo "$pos" | cut -d, -f2 | tr -d ' ')

read -r name mx my <<EOF
$(hyprctl monitors -j | jq -r --argjson x "$gx" --argjson y "$gy" '
  .[] | select(
    $x >= .x and $x < (.x + (.width  / .scale)) and
    $y >= .y and $y < (.y + (.height / .scale))
  ) | "\(.name) \(.x) \(.y)"')
EOF

lx=$((gx - mx))
ly=$((gy - my))

qs ipc -p "$QS" call menu open "$lx" "$ly" "$name" "$sock"
