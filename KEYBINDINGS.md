# Unified Keybindings Reference

This document outlines the unified keybinding system designed to work consistently across Mac (Aerospace) and Linux (Hyprland).

## Philosophy

- **Cmd/Super as primary modifier** for window management
- **Alt for secondary/alternative bindings**
- **Ctrl for terminal operations** (tmux, vim)
- **Consistent vim-style navigation** (h/j/k/l)

## Window Management

### Focus Navigation
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Focus left | `Cmd+H` or `Alt+H` | `Super+H` | Vim style |
| Focus down | `Cmd+J` or `Alt+J` | `Super+J` | Vim style |
| Focus up | `Cmd+K` or `Alt+K` | `Super+K` | Vim style |
| Focus right | `Cmd+L` or `Alt+L` | `Super+L` | Vim style |

### Window Movement
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Move left | `Cmd+Shift+H` | `Super+Shift+H` | |
| Move down | `Cmd+Shift+J` | `Super+Shift+J` | |
| Move up | `Cmd+Shift+K` | `Super+Shift+K` | |
| Move right | `Cmd+Shift+L` | `Super+Shift+L` | |

### Window Resizing
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Resize left/decrease | `Cmd+Ctrl+H` | `Super+Ctrl+H` | |
| Resize right/increase | `Cmd+Ctrl+L` | `Super+Ctrl+L` | |
| Resize up | `Cmd+Ctrl+K` | `Super+Ctrl+K` | |
| Resize down | `Cmd+Ctrl+J` | `Super+Ctrl+J` | |

### Workspace Management
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Switch to workspace 1-9 | `Cmd+1-9` | `Super+1-9` | |
| Switch to workspace 10 | `Cmd+0` | `Super+0` | |
| Move window to workspace | `Cmd+Shift+1-9` | `Super+Shift+1-9` | |
| Workspace back-and-forth | `Cmd+Tab` | `Super+Tab` | |

### Layout Control
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Toggle tiling mode | `Cmd+T` | `Super+T` | |
| Toggle floating | `Cmd+F` | `Super+F` | |
| Toggle fullscreen | `Cmd+Shift+F` | `Super+Shift+F` | |
| Change layout | `Cmd+Shift+Space` | `Super+Shift+Space` | |

### Window Operations
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Close window | `Cmd+Q` | `Super+Q` | |
| Launch terminal | `Cmd+Return` | `Super+Return` | |

### Monitor Management
| Action | Mac (Aerospace) | Linux (Hyprland) | Notes |
|--------|-----------------|------------------|-------|
| Move workspace to prev monitor | `Cmd+Shift+Left` | `Super+Shift+Left` | |
| Move workspace to next monitor | `Cmd+Shift+Right` | `Super+Shift+Right` | |

## Tmux Keybindings

Consistent across both platforms:

| Action | Keybinding | Notes |
|--------|------------|-------|
| Prefix | `Ctrl+S` | Changed from default `Ctrl+B` |
| Split horizontal | `Ctrl+S, -` | |
| Split vertical | `Ctrl+S, \|` | |
| Navigate panes | `Ctrl+H/J/K/L` | Vim style with vim-tmux-navigator |
| Next window | `Ctrl+S, N` | |
| Previous window | `Ctrl+S, P` | |
| New window | `Ctrl+S, C` | |
| Kill pane | `Ctrl+S, X` | |

## Neovim Keybindings

LazyVim configuration is identical on both platforms:

| Action | Keybinding | Notes |
|--------|------------|-------|
| Leader key | `Space` | |
| File explorer | `Space+E` | |
| Find files | `Space+F+F` | |
| Find text | `Space+F+G` | |
| Buffer list | `Space+B+B` | |

## Application Shortcuts

### Lazygit
| Action | Keybinding | Notes |
|--------|------------|-------|
| Open in tmux | `Ctrl+S, G` | Custom tmux binding |

### Lazydocker
| Action | Keybinding | Notes |
|--------|------------|-------|
| Open in tmux | `Ctrl+S, D` | Custom tmux binding |

## Platform-Specific Notes

### Mac (Aerospace)
- Alt versions of most commands are available for compatibility
- Cmd+H is remapped (no longer hides application)
- Service mode: `Cmd+Shift+;`

### Linux (Hyprland)
- Super key is typically the Windows/Cmd key
- Additional bindings available for workspace animations
- Service mode configured separately

## Tips for Consistency

1. **Primary modifiers**: Always try Cmd (Mac) / Super (Linux) first
2. **Vim everywhere**: H/J/K/L for directional movement
3. **Numbers for workspaces**: 1-9 for first 9, 0 for 10th
4. **Shift for moving**: Add Shift to move windows/workspaces
5. **Ctrl for resizing**: Add Ctrl for resize operations

## Installation

1. Copy aerospace config: `stow -d ~/dotfiles/mac -t ~/.config aerospace`
2. Copy hyprland config: `stow -d ~/dotfiles/linux -t ~/.config hypr`
3. Reload configurations:
   - Aerospace: `aerospace reload-config`
   - Hyprland: `hyprctl reload`