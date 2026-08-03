#!/bin/sh
# One-shot: report each workspace's number as an "idx" metadata token
# for the sidebar (see [ui.sidebar.spaces] rows in config.toml).
# Run by the idx-sync plugin on startup and workspace lifecycle events.

herdr workspace list 2>/dev/null \
  | /usr/bin/jq -r '.result.workspaces[] | "\(.workspace_id) \(.number)"' \
  | while read -r ws num; do
      herdr workspace report-metadata "$ws" \
        --source idxsync --token "idx=$num" >/dev/null 2>&1
    done
