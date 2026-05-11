#!/bin/sh

CURRENT=$(tmux display-message -p '#S')
NOTIFY_SESSION=$(sed -n '2p' ~/.claude-notify-target 2>/dev/null | cut -d: -f1)

# Clear notify target once the user is on the notified session
if [ -n "$NOTIFY_SESSION" ] && [ "$CURRENT" = "$NOTIFY_SESSION" ]; then
  : > "$HOME/.claude-notify-target"
  NOTIFY_SESSION=""
fi

i=1
tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
  if [ "$session" = "$CURRENT" ]; then
    printf '#[fg=colour15,bold] %d:%s #[default]' "$i" "$session"
  elif [ "$session" = "$NOTIFY_SESSION" ]; then
    printf '#[fg=colour226,bold] ⚡%d:%s #[default]' "$i" "$session"
  else
    printf '#[fg=colour245] %d:%s #[default]' "$i" "$session"
  fi
  i=$((i + 1))
done
