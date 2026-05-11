#!/bin/sh
N=$1
SESSION=$(tmux list-sessions -F '#{session_name}' | sed -n "${N}p")
[ -n "$SESSION" ] && tmux switch-client -t "$SESSION" && tmux refresh-client -S
