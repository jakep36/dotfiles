#!/bin/sh

LOG=/tmp/tmux-focus-debug.log
echo "--- $(date) ---" >> "$LOG"

TARGET_FILE="$HOME/.claude-notify-target"

if [ ! -f "$TARGET_FILE" ]; then
  echo "ERROR: $TARGET_FILE not found" >> "$LOG"
  exit 0
fi

CLIENT=$(sed -n '1p' "$TARGET_FILE")
TARGET=$(sed -n '2p' "$TARGET_FILE")
echo "CLIENT: $CLIENT TARGET: $TARGET" >> "$LOG"

open -a Ghostty
sleep 0.3
tmux switch-client -c "$CLIENT" -t "$TARGET" 2>> "$LOG"
echo "exit: $?" >> "$LOG"
