#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# This script has two modes:
#   1. "init" or no args: full sync — create missing workspace items, remove
#      stale ones, and set styling for all. Called from sketchybarrc.
#   2. Per-workspace (arg = workspace id): style a single workspace.
#      Called by SketchyBar on aerospace_workspace_change events.
#      Also called by `sketchybar --update`, where FOCUSED_WORKSPACE may
#      not be set — in that case we query it ourselves.

PLUGIN_DIR="$CONFIG_DIR/plugins"

# Resolve the focused workspace. The env var $FOCUSED_WORKSPACE is set by
# SketchyBar when it triggers the script via a subscribed event.  When
# called from `sketchybar --update` or from sketchybarrc directly, the env
# var is absent, so we fall back to querying AeroSpace.
resolve_focused() {
    if [ -n "$FOCUSED_WORKSPACE" ]; then
        echo "$FOCUSED_WORKSPACE"
    else
        aerospace list-workspaces --focused 2>/dev/null
    fi
}

if [ "$1" != "init" ] && [ -n "$1" ]; then
    # Per-workspace styling (called from event subscription or --update)
    FOCUSED=$(resolve_focused)
    if [ "$1" = "$FOCUSED" ]; then
        sketchybar --animate linear 10 --set "$NAME" background.color=0x39ffffff
    else
        sketchybar --animate linear 10 --set "$NAME" background.color=0x00000000
    fi
    exit 0
fi

# ─── Full init / sync ───────────────────────────────────────────────
# Ensure every AeroSpace workspace has a bar item. This handles the
# race condition where SketchyBar starts before AeroSpace is available.

WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)

if [ -z "$WORKSPACES" ]; then
    # AeroSpace is not running — nothing to do
    exit 0
fi

FOCUSED=$(resolve_focused)

for sid in $WORKSPACES; do
    # Check if this workspace item already exists
    if ! sketchybar --query "space.$sid" &>/dev/null; then
        # Create missing workspace item
        sketchybar --add item "space.$sid" left \
            --subscribe "space.$sid" aerospace_workspace_change \
            --set "space.$sid" \
            icon="$sid" \
            padding_left=0 \
            padding_right=0 \
            icon.padding_left=5 \
            icon.padding_right=5 \
            background.padding_right=0 \
            background.padding_left=0 \
            background.color=0x00000000 \
            background.corner_radius=5 \
            background.height=25 \
            label.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$PLUGIN_DIR/aerospace.sh $sid"
    fi

    # Style: highlight the focused workspace
    if [ "$sid" = "$FOCUSED" ]; then
        sketchybar --set "space.$sid" background.color=0x39ffffff
    else
        sketchybar --set "space.$sid" background.color=0x00000000
    fi
done

# Remove items for workspaces that no longer exist
for item in $(sketchybar --query bar 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    for i in d.get('items', []):
        if i.startswith('space.'):
            print(i)
except: pass
"); do
    sid="${item#space.}"
    if ! echo "$WORKSPACES" | grep -qx "$sid"; then
        sketchybar --remove "$item"
    fi
done