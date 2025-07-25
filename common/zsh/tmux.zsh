function dev() {
    # Check if tmux session exists
    if ! tmux has-session -t dev 2>/dev/null; then
        # Create new session with nexus window
        tmux new-session -d -s dev -n nexus -c /Users/jparsell/Developer/nexus/dev/apps/nexus-web

        # Create nexus-cdk window
        tmux new-window -t dev -n nexus-cdk -c /Users/jparsell/Developer/flhubee-cdk

        # Select first window
        tmux select-window -t dev:1
    fi

    # Attach to session if not already in tmux
    if [ -z "$TMUX" ]; then
        tmux attach-session -t dev
    else
        tmux switch-client -t dev
    fi
}
