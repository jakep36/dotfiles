#!/usr/bin/env bash

# Dotfiles sync script
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_HOST="100.119.167.52"
REMOTE_USER="jparsell"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to sync with remote
sync_remote() {
    local action="$1"
    
    case "$action" in
        push)
            print_info "Pushing dotfiles to remote host..."
            rsync -avz --delete \
                --exclude='.git' \
                --exclude='.DS_Store' \
                --exclude='*.swp' \
                "$DOTFILES_DIR/" \
                "${REMOTE_USER}@${REMOTE_HOST}:~/dotfiles/"
            print_info "Push complete!"
            ;;
        pull)
            print_info "Pulling dotfiles from remote host..."
            rsync -avz \
                --exclude='.git' \
                --exclude='.DS_Store' \
                --exclude='*.swp' \
                --exclude='mac/' \
                "${REMOTE_USER}@${REMOTE_HOST}:~/dotfiles/linux/" \
                "$DOTFILES_DIR/linux/"
            print_info "Pull complete!"
            ;;
        *)
            print_error "Unknown action: $action"
            print_info "Usage: $0 [push|pull]"
            exit 1
            ;;
    esac
}

# Git operations
git_sync() {
    cd "$DOTFILES_DIR"
    
    # Check if there are changes
    if [[ -n $(git status -s) ]]; then
        print_info "Committing local changes..."
        git add -A
        git commit -m "Update dotfiles $(date +%Y-%m-%d)"
    fi
    
    # Push to remote if origin is set
    if git remote | grep -q origin; then
        print_info "Pushing to git remote..."
        git push origin main
    else
        print_error "No git remote 'origin' configured"
        print_info "Add with: git remote add origin <your-repo-url>"
    fi
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        # Default: commit and push to git
        git_sync
    else
        # Sync with remote machine
        sync_remote "$1"
    fi
}

main "$@"