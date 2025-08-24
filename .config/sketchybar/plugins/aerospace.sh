#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    # sketchybar --set $NAME background.drawing=true
    sketchybar --animate linear 10 --set $NAME background.color=0x39ffffff
else
    sketchybar --animate linear 10 --set $NAME background.color=0x00000000
    # sketchybar --set $NAME background.drawing=false
fi
