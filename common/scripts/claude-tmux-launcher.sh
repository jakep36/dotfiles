#!/bin/bash

# This script launches Claude in a tmux pane, preserving environment variables
# It's designed to work with the claudecode.nvim external provider

# The Claude command is passed as all arguments
CLAUDE_CMD="$@"

# Debug logging
echo "=== Claude Tmux Launcher ===" >> /tmp/claude-launcher.log
echo "Date: $(date)" >> /tmp/claude-launcher.log
echo "Command: $CLAUDE_CMD" >> /tmp/claude-launcher.log
echo "CLAUDE_CODE_SSE_PORT: $CLAUDE_CODE_SSE_PORT" >> /tmp/claude-launcher.log
echo "Environment passed to tmux:" >> /tmp/claude-launcher.log
env | grep -E "CLAUDE|IDE|FORCE" >> /tmp/claude-launcher.log
echo "---" >> /tmp/claude-launcher.log

if [ -n "$TMUX" ]; then
    # Check if pane exists and kill it
    if tmux list-panes -F '#{pane_title}' | grep -q '^claudecode$'; then
        tmux kill-pane -t ':claudecode' 2>/dev/null
    fi

    # Create new pane, passing current environment
    # Use -e to preserve environment variables
    tmux split-window -h -p 40 -d \
        -e CLAUDE_CODE_SSE_PORT="$CLAUDE_CODE_SSE_PORT" \
        -e ENABLE_IDE_INTEGRATION="$ENABLE_IDE_INTEGRATION" \
        -e FORCE_CODE_TERMINAL="$FORCE_CODE_TERMINAL" \
        "$CLAUDE_CMD"

    # Set pane title
    tmux select-pane -T 'claudecode' -t '{right}'

    # Keep this script running so the external provider can track it
    # Wait for the tmux pane to close
    while tmux list-panes -F '#{pane_title}' | grep -q '^claudecode$'; do
        sleep 1
    done
else
    # Not in tmux, just run the command directly
    exec $CLAUDE_CMD
fi