#!/bin/bash
# Fix AeroSpace tiling after restart

# Get current workspace to return to it later
current_workspace=$(aerospace list-workspaces --focused)

# Fix layout on all workspaces with windows
for workspace in $(aerospace list-workspaces --all); do
    if [ "$(aerospace list-windows --workspace "$workspace" | wc -l)" -gt 0 ]; then
        aerospace workspace "$workspace"
        aerospace flatten-workspace-tree
        aerospace layout tiles
        sleep 0.1
    fi
done

# Return to original workspace
aerospace workspace "$current_workspace"