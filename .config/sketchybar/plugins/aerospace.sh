#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# This script has three modes:
#   1. "init" or no args: full sync — create missing workspace items, remove
#      stale ones, and set styling for all. Called from sketchybarrc.
#      Also shows a warning when AeroSpace is not running.
#   2. "monitor": periodic check for AeroSpace status changes (on↔off).
#   3. Per-workspace (arg = workspace id): style a single workspace.
#      Called by SketchyBar on aerospace_workspace_change events.

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

# ─── Monitor mode ───────────────────────────────────────────────────
# Lightweight periodic check: only re-inits when AeroSpace status changes.
if [ "$1" = "monitor" ]; then
    WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
    WARNING_EXISTS=$(sketchybar --query "aerospace_off" &>/dev/null && echo "yes" || echo "no")

    if [ -n "$WORKSPACES" ] && [ "$WARNING_EXISTS" = "yes" ]; then
        # AeroSpace just started up — transition from warning to workspaces
        "$PLUGIN_DIR/aerospace.sh" init
    elif [ -z "$WORKSPACES" ] && [ "$WARNING_EXISTS" = "no" ]; then
        # AeroSpace just quit — transition from workspaces to warning
        "$PLUGIN_DIR/aerospace.sh" init
    fi
    exit 0
fi

# ─── Per-workspace styling ─────────────────────────────────────────
if [ "$1" != "init" ] && [ -n "$1" ]; then
    FOCUSED=$(resolve_focused)
    if [ "$1" = "$FOCUSED" ]; then
        sketchybar --animate linear 10 --set "$NAME" background.color=0x39ffffff
    else
        sketchybar --animate linear 10 --set "$NAME" background.color=0x00000000
    fi
    exit 0
fi

# ─── Full init / sync ───────────────────────────────────────────────

# Ensure the invisible status monitor exists (checks every 5s for AeroSpace on/off)
if ! sketchybar --query "aerospace_monitor" &>/dev/null; then
    sketchybar --add item "aerospace_monitor" left \
        --set "aerospace_monitor" \
        icon.drawing=off \
        label.drawing=off \
        background.drawing=off \
        padding_left=0 \
        padding_right=0 \
        update_freq=5 \
        script="$PLUGIN_DIR/aerospace.sh monitor"
fi

WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)

if [ -z "$WORKSPACES" ]; then
    # ── AeroSpace is NOT running — show warning indicator ──

    # Remove any existing workspace items (AeroSpace was on, now off)
    for item in $(sketchybar --query bar 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    for i in d.get('items', []):
        if i.startswith('space.'):
            print(i)
except: pass
"); do
        sketchybar --remove "$item"
    done

    # Create warning indicator if it doesn't exist yet
    if ! sketchybar --query "aerospace_off" &>/dev/null; then
        WARN_ICON=$(python3 -c "print(chr(0xf071))")
        sketchybar --add item "aerospace_off" left \
            --set "aerospace_off" \
            icon="Aerospace off" \
            icon.color=0xffffffff \
            label="$WARN_ICON" \
            label.color=0x80FFFF00 \
            padding_left=0 \
            padding_right=0 \
            icon.padding_left=5 \
            icon.padding_right=10 \
            label.padding_left=0 \
            label.padding_right=5 \
            background.drawing=off

        # Position it before the chevron so it sits where workspaces normally are
        if sketchybar --query "chevron" &>/dev/null; then
            sketchybar --move "aerospace_off" before chevron
        fi
    fi

    exit 0
fi

# ── AeroSpace IS running — show workspaces ──

# Remove warning indicator if present
if sketchybar --query "aerospace_off" &>/dev/null; then
    sketchybar --remove "aerospace_off"
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

        # Position it before the chevron so workspaces stay on the far left
        if sketchybar --query "chevron" &>/dev/null; then
            sketchybar --move "space.$sid" before chevron
        fi
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
