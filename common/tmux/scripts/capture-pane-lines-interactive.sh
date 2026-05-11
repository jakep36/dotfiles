#!/bin/bash

# Interactive tmux script to capture specified number of lines from a selected pane to clipboard
# Usage: Called from tmux key binding with popup interface

# Color codes for better display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to get all panes with detailed info, sorted by current session first
get_panes() {
    local current_session=$(tmux display-message -p '#S')

    # Get current session panes first, then other sessions
    {
        # Current session panes first
        tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{session_name}|#{window_name}|#{pane_title}|#{pane_current_command}|#{pane_current_path}|CURRENT" | grep "^${current_session}:"

        # Other session panes after
        tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{session_name}|#{window_name}|#{pane_title}|#{pane_current_command}|#{pane_current_path}|OTHER" | grep -v "^${current_session}:"
    }
}

# Function to format pane display for fzf with current session highlighting
format_pane_display() {
    local current_session=$(tmux display-message -p '#S')
    local other_sessions_started=false
    local current_count=0

    while IFS='|' read -r pane_id session window title command path session_type; do
        # Skip empty lines
        [ -z "$pane_id" ] && continue

        # Truncate long paths for display
        short_path=$(basename "$path")

        # Count current session panes and add separator for other sessions
        if [ "$session_type" = "CURRENT" ]; then
            current_count=$((current_count + 1))
            # Current session panes with bright highlighting
            printf "🌟 %-18s │ %-12s │ %-15s │ %-20s │ %s\n" \
                "$pane_id" "$session" "$window" "$command" "$short_path"
        else
            # Add separator before first other session pane
            if [ "$other_sessions_started" = false ]; then
                echo ""
                echo "═══════════════════════════════════════════════════════════════════════════════════"
                echo "                             📂 OTHER SESSIONS"
                echo "═══════════════════════════════════════════════════════════════════════════════════"
                other_sessions_started=true
            fi

            # Other session panes with subdued formatting
            printf "   %-18s │ %-12s │ %-15s │ %-20s │ %s\n" \
                "$pane_id" "$session" "$window" "$command" "$short_path"
        fi
    done
}

echo -e "${BLUE}🔍 Tmux Pane Line Capture Tool${NC}\n"

# Step 1: Select pane
echo -e "${YELLOW}Step 1: Select a pane${NC}"
current_session=$(tmux display-message -p '#S')
echo -e "${GREEN}Current session: ${BLUE}$current_session${NC} (🌟 highlighted at top)\n"

selected_pane_line=$(get_panes | format_pane_display | grep -E "^(🌟|   )" | fzf \
    --height=22 \
    --border=rounded \
    --prompt="📋 Select pane: " \
    --header="   Pane ID            │ Session      │ Window          │ Command              │ Path" \
    --header-lines=0 \
    --preview="pane_id=\$(echo {} | sed 's/^🌟 //' | sed 's/^   //' | awk '{print \$1}'); echo 'Preview of last 10 lines from pane:' \$pane_id && echo '' && tmux capture-pane -pe -t \"\$pane_id\" 2>/dev/null | tail -10 || echo 'No content available'" \
    --preview-window="right:50%:wrap" \
    --color="header:italic:underline" \
    --bind="enter:accept" \
    --bind="esc:abort")

# Check if user cancelled
if [ -z "$selected_pane_line" ]; then
    echo -e "${RED}❌ No pane selected. Exiting.${NC}"
    exit 0
fi

# Extract pane ID from selected line (handle both current session 🌟 and other session formats)
selected_pane=$(echo "$selected_pane_line" | sed 's/^🌟 //' | sed 's/^   //' | awk '{print $1}')

echo -e "${GREEN}✅ Selected pane: $selected_pane${NC}\n"

# Step 2: Get number of lines
echo -e "${YELLOW}Step 2: Enter number of lines to capture${NC}"
echo -e "Current pane has $(tmux capture-pane -pe -t "$selected_pane" | wc -l) total lines"
echo -n -e "${BLUE}Enter number of lines (default 50): ${NC}"
read -r lines_to_capture

# Default to 50 if no input
if [ -z "$lines_to_capture" ]; then
    lines_to_capture=50
    echo "Using default: 50 lines"
fi

# Validate input is a number
if ! [[ "$lines_to_capture" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Error: Please enter a valid number${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Will capture $lines_to_capture lines${NC}\n"

# Step 3: Capture and copy
echo -e "${YELLOW}Step 3: Capturing content...${NC}"

# Capture the specified number of lines from the selected pane
captured_content=$(tmux capture-pane -pe -t "$selected_pane" | tail -n "$lines_to_capture")

# Check if we got any content
if [ -z "$captured_content" ]; then
    echo -e "${RED}❌ No content captured from pane${NC}"
    exit 1
fi

# Copy to system clipboard based on OS
if command -v pbcopy >/dev/null 2>&1; then
    # macOS
    echo "$captured_content" | pbcopy
    clipboard_cmd="pbcopy (macOS)"
elif command -v xclip >/dev/null 2>&1; then
    # Linux with xclip
    echo "$captured_content" | xclip -selection clipboard
    clipboard_cmd="xclip (Linux)"
elif command -v xsel >/dev/null 2>&1; then
    # Linux with xsel
    echo "$captured_content" | xsel --clipboard --input
    clipboard_cmd="xsel (Linux)"
else
    echo -e "${RED}❌ Error: No clipboard utility found (pbcopy/xclip/xsel)${NC}"
    exit 1
fi

# Show success message
echo -e "${GREEN}✅ Successfully captured $lines_to_capture lines from pane $selected_pane${NC}"
echo -e "${GREEN}📋 Content copied to clipboard using $clipboard_cmd${NC}"
echo -e "\n${BLUE}Content preview (first 3 lines):${NC}"
echo "$captured_content" | head -3
if [ $(echo "$captured_content" | wc -l) -gt 3 ]; then
    echo "..."
fi

echo -e "\n${YELLOW}Press any key to close...${NC}"
read -n 1