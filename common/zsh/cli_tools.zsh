# Function to navigate to projects using fzf
p() {
    local dir=$(find ~/Developer -maxdepth 4 -type d | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

# Function to kill processes using fzf
pkill() {
    local process=$(ps aux | fzf --height 40% --layout=reverse --prompt="Select process to kill: " | awk '{print $2}')
    if [[ -n "$process" ]]; then
        echo "Killing process $process"
        sudo kill "$process"
    else
        echo "No process selected"
    fi
}

# Function to view git logs with preview and actions
logg() {
    git lg | fzf --ansi --no-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
        --preview-window=right:50%:wrap --height 100% \
        --bind "enter:execute(echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show % | lvim -c \"setlocal buftype=nofile bufhidden=wipe noswapfile nowrap\" -c \"nnoremap <buffer> q :q!<CR>\" -')" \
        --bind "ctrl-e:execute(echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'gh browse %')"
}

# Function to create or attach to tmux sessions
create_tmux_session() {
    local RESULT="$1"
    zoxide add "$RESULT" &>/dev/null
    local FOLDER=$(basename "$RESULT")
    local SESSION_NAME=$(echo "$FOLDER" | tr ' .:' '_')

    if [[ -d "$RESULT/.git" ]]; then
        local GIT_BRANCH_NAME=$(git -C "$RESULT" symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n "$GIT_BRANCH_NAME" ]]; then
            SESSION_NAME="${SESSION_NAME}_${GIT_BRANCH_NAME}"
        fi
    fi

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
    fi

    if [[ -z "$TMUX" ]]; then
        tmux attach -t "$SESSION_NAME"
    else
        tmux switch-client -t "$SESSION_NAME"
    fi
}

# Function to triage bugs using GitHub CLI
triage_bugs() {
    local gh_issue=$(gh issue list --state open --assignee "@me" --label "bug" | \
        fzf --ansi --no-sort \
        --preview 'echo {} | awk "{print \$1}" | xargs -I % gh issue view %' \
        --preview-window=right:50%:wrap --height 100% \
        --bind "enter:execute(echo {} | awk '{print \$1}' | xargs -I % sh -c 'gh issue view % -w')" \
        --bind "ctrl-u:execute(echo {} | awk '{print \$1}' | xargs -I % sh -c 'gh issue edit --remove-assignee \"@me\" %')")
    echo "$gh_issue"
}

# Fix AeroSpace tiling layout
alias fix='~/dotfiles/fix-aerospace.sh'

# Eza aliases (modern ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons --group-directories-first'
alias l='eza -la --icons --group-directories-first'
