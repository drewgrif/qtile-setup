#!/bin/sh

# polkit
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# background
feh --bg-fill ~/.config/qtile/wallpaper/wallhaven-1pe2pv_3440x1440.png &

# compositor
picom --config ~/.config/qtile/picom/picom.conf --animations -b &

# Notifications
dunst -config ~/.config/qtile/dunst/dunstrc &
