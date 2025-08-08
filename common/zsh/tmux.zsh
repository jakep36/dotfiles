function dev() {
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
