#!/bin/bash

# Tmux script to capture specified number of lines from a selected pane to clipboard
# Usage: Called from tmux key binding

# Get all panes with session, window, and pane info
get_panes() {
    tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} | #{window_name} | #{pane_title} | #{pane_current_command} | #{pane_current_path}"
}

# Show panes in fzf for selection
selected_pane=$(get_panes | fzf \
    --height=50% \
    --border \
    --prompt="Select pane: " \
    --header="Choose a pane to capture from" \
    --preview="tmux capture-pane -pe -t {1} | tail -20" \
    --preview-window="right:50%" \
    | cut -d' ' -f1)

# Exit if no pane selected
if [ -z "$selected_pane" ]; then
    exit 0
fi

# Get number of lines to capture
echo -n "Number of lines to capture (default 50): "
read lines_to_capture

# Default to 50 if no input
if [ -z "$lines_to_capture" ]; then
    lines_to_capture=50
fi

# Validate input is a number
if ! [[ "$lines_to_capture" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid number"
    exit 1
fi

# Capture the specified number of lines from the selected pane
captured_content=$(tmux capture-pane -pe -t "$selected_pane" | tail -n "$lines_to_capture")

# Copy to system clipboard based on OS
if command -v pbcopy >/dev/null 2>&1; then
    # macOS
    echo "$captured_content" | pbcopy
    clipboard_cmd="pbcopy"
elif command -v xclip >/dev/null 2>&1; then
    # Linux with xclip
    echo "$captured_content" | xclip -selection clipboard
    clipboard_cmd="xclip"
elif command -v xsel >/dev/null 2>&1; then
    # Linux with xsel
    echo "$captured_content" | xsel --clipboard --input
    clipboard_cmd="xsel"
else
    echo "Error: No clipboard utility found (pbcopy/xclip/xsel)"
    exit 1
fi

# Show confirmation
echo "✅ Captured $lines_to_capture lines from pane $selected_pane to clipboard using $clipboard_cmd"