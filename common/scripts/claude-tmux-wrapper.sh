#!/bin/bash

# Claude Code tmux wrapper script
# Opens Claude in a tmux pane if in tmux, otherwise runs normally
# This script preserves all environment variables passed to it

# Debug: Log environment variables to a file
DEBUG_FILE="/tmp/claude-tmux-debug.log"
echo "=== Claude Tmux Wrapper Debug ===" > "$DEBUG_FILE"
echo "Date: $(date)" >> "$DEBUG_FILE"
echo "Arguments: $@" >> "$DEBUG_FILE"
echo "CLAUDE_CODE_SSE_PORT: $CLAUDE_CODE_SSE_PORT" >> "$DEBUG_FILE"
echo "ENABLE_IDE_INTEGRATION: $ENABLE_IDE_INTEGRATION" >> "$DEBUG_FILE"
echo "FORCE_CODE_TERMINAL: $FORCE_CODE_TERMINAL" >> "$DEBUG_FILE"
echo "All env vars:" >> "$DEBUG_FILE"
env | grep -E "CLAUDE|IDE|FORCE" >> "$DEBUG_FILE"
echo "---" >> "$DEBUG_FILE"

# Get the claude command (passed as arguments)
CLAUDE_CMD="$@"

if [ -n "$TMUX" ]; then
    # Check if a pane with title "claudecode" exists
    if tmux list-panes -F '#{pane_title}' | grep -q '^claudecode$'; then
        # Kill existing pane (cleaner than respawn for env vars)
        tmux kill-pane -t ':claudecode'
    fi

    # Create new vertical pane (40% width) on the right
    # We need to explicitly pass the environment variables to the new pane
    # because tmux doesn't inherit them by default
    # Also add a debug echo to verify the variables are set
    tmux split-window -h -p 40 \
        "export CLAUDE_CODE_SSE_PORT='$CLAUDE_CODE_SSE_PORT'; \
         export ENABLE_IDE_INTEGRATION='$ENABLE_IDE_INTEGRATION'; \
         export FORCE_CODE_TERMINAL='$FORCE_CODE_TERMINAL'; \
         echo 'Debug: CLAUDE_CODE_SSE_PORT='$CLAUDE_CODE_SSE_PORT >> /tmp/claude-pane-debug.log; \
         echo 'Starting claude...' >> /tmp/claude-pane-debug.log; \
         $CLAUDE_CMD"

    # Set the pane title for future reference
    tmux select-pane -T 'claudecode' -t '{right}'

    echo "Tmux pane created successfully" >> "$DEBUG_FILE"
else
    # Not in tmux, just run the command
    echo "Not in tmux, executing directly" >> "$DEBUG_FILE"
    exec $CLAUDE_CMD
fi