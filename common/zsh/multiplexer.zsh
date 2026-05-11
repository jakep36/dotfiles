# Terminal Multiplexer Functions
# Provides easy switching between tmux and zellij

# Set default multiplexer (can be 'tmux' or 'zellij')
export DEFAULT_MULTIPLEXER=${DEFAULT_MULTIPLEXER:-tmux}

# Development session function for current multiplexer
function dev() {
    if [[ "$DEFAULT_MULTIPLEXER" == "zellij" ]]; then
        dev_zellij
    else
        dev_tmux
    fi
}

# Original tmux dev function
function dev_tmux() {
    # Check if tmux session exists
    if ! tmux has-session -t dev 2>/dev/null; then
        # Create new session in current directory
        tmux new-session -d -s dev
    fi

    # Attach to session if not already in tmux
    if [ -z "$TMUX" ]; then
        tmux attach-session -t dev
    else
        tmux switch-client -t dev
    fi
}

# Zellij dev function
function dev_zellij() {
    # Check if we're already in a zellij session
    if [ -n "$ZELLIJ" ]; then
        echo "Already in zellij session"
        return
    fi

    # Try to attach to existing dev session, otherwise create new one with dev layout
    if zellij list-sessions 2>/dev/null | grep -q "dev"; then
        zellij attach dev
    else
        zellij --layout dev --session dev
    fi
}

# Quick session starter for testing zellij
function zdev() {
    if [ -n "$ZELLIJ" ]; then
        echo "Already in zellij session"
        return
    fi

    zellij --layout dev --session "dev-$(date +%s)"
}

# Simple zellij test
function ztest() {
    if [ -n "$ZELLIJ" ]; then
        echo "Already in zellij session"
        return
    fi

    echo "Starting Zellij with simple layout..."
    echo "Press Ctrl+S to see available commands"
    echo "Press Ctrl+d to exit"
    zellij --layout simple
}

# Quick tmux session for testing
function tdev() {
    local session_name="dev-$(date +%s)"
    tmux new-session -d -s "$session_name"

    if [ -z "$TMUX" ]; then
        tmux attach-session -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    fi
}

# Switch default multiplexer
function switch_mux() {
    case "$1" in
        tmux)
            export DEFAULT_MULTIPLEXER=tmux
            echo "Switched to tmux as default multiplexer"
            ;;
        zellij)
            export DEFAULT_MULTIPLEXER=zellij
            echo "Switched to zellij as default multiplexer"
            ;;
        *)
            echo "Usage: switch_mux [tmux|zellij]"
            echo "Current default: $DEFAULT_MULTIPLEXER"
            ;;
    esac
}

# Show current multiplexer status
function mux_status() {
    echo "Default multiplexer: $DEFAULT_MULTIPLEXER"

    if [ -n "$TMUX" ]; then
        echo "Currently in tmux session: $(tmux display-message -p '#S')"
    elif [ -n "$ZELLIJ" ]; then
        echo "Currently in zellij session"
    else
        echo "Not in any multiplexer session"
    fi
}

# Aliases for convenience
alias mux='mux_status'
alias smux='switch_mux'

# Quick project navigation (enhanced p function that works with both)
function mp() {
    # Use existing p function to get project, then start dev session there
    local project_dir
    if command -v fzf >/dev/null 2>&1; then
        project_dir=$(find ~/Developer -maxdepth 2 -type d -name .git | sed 's|/.git||' | fzf --preview 'ls -la {}')
        if [[ -n "$project_dir" ]]; then
            cd "$project_dir"
            dev
        fi
    else
        echo "fzf not found - install it for project navigation"
    fi
}

# Kill all multiplexer sessions
function kill_all_mux() {
    echo "Killing all tmux sessions..."
    tmux list-sessions 2>/dev/null | cut -d: -f1 | xargs -I {} tmux kill-session -t {} 2>/dev/null || true

    echo "Killing all zellij sessions..."
    zellij delete-all-sessions --yes 2>/dev/null || true

    echo "All multiplexer sessions killed"
}