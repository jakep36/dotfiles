#!/bin/sh

TITLE=$1
BODY=$2

if [ "$(uname)" = "Darwin" ]; then
  if [ -n "$TMUX" ]; then
    CLIENT=$(tmux display-message -p '#{client_name}')
    TARGET=$(tmux display-message -p '#S:#I.#P')
    printf '%s\n%s\n' "$CLIENT" "$TARGET" > "$HOME/.claude-notify-target"
  fi
elif [ -n "$TMUX" ]; then
  PANE_TTY=$(tmux display-message -p '#{pane_tty}')
  printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "$BODY" > "$PANE_TTY"
else
  printf '\e]777;notify;%s;%s\a' "$TITLE" "$BODY"
fi
