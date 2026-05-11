# Zellij Trial Setup and Comparison

This document outlines your Zellij trial setup, allowing you to test Zellij while keeping your tmux configuration intact for easy fallback.

## Installation Summary

### What Was Installed
- **Zellij**: Installed via Homebrew (`brew install zellij`)
- **Configuration**: Located in `~/dotfiles/common/zellij/` (managed by Stow)
- **Shell Functions**: Added to `~/dotfiles/common/zsh/multiplexer.zsh`

### Files Created/Modified
- `~/dotfiles/common/zellij/.config/zellij/config.kdl` - Main Zellij configuration
- `~/dotfiles/common/zellij/.config/zellij/layouts/dev.kdl` - Development layout
- `~/dotfiles/common/zellij/.config/zellij/layouts/simple.kdl` - Simple test layout
- `~/dotfiles/common/zsh/multiplexer.zsh` - Shell functions for switching
- `~/dotfiles/common/zsh/zshrc` - Modified to source multiplexer.zsh

## Quick Start Guide

### Testing Zellij

```bash
# Start a new shell to load the new functions
exec zsh

# Quick test with simple layout
zellij --layout simple

# Test development layout
zdev

# Or use the unified dev function (switch multiplexer first)
switch_mux zellij
dev
```

### Key Differences from Your Tmux Setup

| Feature | Tmux (Your Setup) | Zellij |
|---------|------------------|--------|
| **Prefix Key** | Ctrl+S | Ctrl+S (configured to match) |
| **Split Panes** | Ctrl+S + `\\` / `-` | Ctrl+S + `\\` / `-` (matched) |
| **Navigation** | Ctrl+h/j/k/l | Ctrl+h/j/k/l (matched) |
| **Session Manager** | Ctrl+S + t (sesh) | Ctrl+S + t (built-in) |
| **Default Mode** | Normal tmux | Locked mode (vim-friendly) |
| **Visual Feedback** | Custom status bar | Built-in hints at bottom |
| **Session Persistence** | tmux-resurrect plugin | Built-in session serialization |
| **Floating Terminal** | ❌ Not available | ✅ Ctrl+S + f |
| **Layout Management** | Manual setup | Predefined layouts |

## Shell Function Reference

### New Functions Available

```bash
# Status and switching
mux_status          # Show current multiplexer and session
switch_mux zellij    # Switch default to zellij
switch_mux tmux      # Switch default to tmux

# Development sessions
dev                 # Use current default multiplexer
dev_tmux            # Force tmux dev session
dev_zellij          # Force zellij dev session
zdev                # Quick zellij test session
tdev                # Quick tmux test session

# Project navigation
mp                  # Navigate to project and start dev session

# Cleanup
kill_all_mux       # Kill all tmux and zellij sessions
```

### Aliases
- `mux` - Show status
- `smux` - Switch multiplexer

## Zellij-Specific Features to Try

### 1. Floating Terminal
```bash
# In any zellij session, press Ctrl+S + f
# This opens a floating terminal overlay - great for quick commands
```

### 2. Built-in Session Management
```bash
# Press Ctrl+S + t to see the session manager
# No need for external tools like sesh
```

### 3. Smart Layout Loading
```bash
# Load layouts directly
zellij --layout dev
zellij --layout simple

# Or use URLs (new feature)
# zellij --layout https://example.com/layout.kdl
```

### 4. Non-Colliding Keybindings
- Default mode is "locked" - vim keys work normally
- No conflicts with vim navigation
- Context hints show available commands

## Key Mappings Reference

### Zellij Navigation (Locked Mode)
- `Ctrl+h/j/k/l` - Navigate panes/tabs (just like tmux)
- `Ctrl+S` - Enter tmux-like mode for other commands
- `Ctrl+S + \\` - Split right
- `Ctrl+S + -` - Split down
- `Ctrl+S + c` - New tab
- `Ctrl+S + t` - Session manager
- `Ctrl+S + f` - Toggle floating terminal
- `Ctrl+S + r` - Reload config

### Additional Modes
- `Ctrl+S + [` - Scroll mode (like tmux copy mode)
- `Ctrl+S + r` then resize keys - Resize mode

## Migration Considerations

### Advantages of Zellij
✅ **Easier learning curve** - Built-in help and hints
✅ **Better defaults** - Works well out of the box
✅ **Modern features** - Floating terminals, built-in session management
✅ **No plugin management** - Core features are built-in
✅ **Better vim integration** - Non-colliding keybindings by default

### Potential Disadvantages
❌ **Less mature ecosystem** - Fewer plugins and integrations
❌ **Different workflow** - Some tmux habits may not translate
❌ **Configuration format** - KDL format vs tmux's simpler syntax
❌ **Plugin system** - Different from tmux, smaller ecosystem

### What You'll Miss from Tmux
- **Sesh integration** - Though built-in session manager may be better
- **Catppuccin theme customization** - Limited theme options
- **tmux-resurrect** - Though built-in serialization may be sufficient
- **Extensive plugin ecosystem** - fzf-url, tmux-yank, etc.

## Testing Plan

### Week 1: Basic Usage
- [ ] Use `zdev` for development sessions
- [ ] Test floating terminal feature (Ctrl+S + f)
- [ ] Try built-in session manager (Ctrl+S + t)
- [ ] Test vim integration in actual development

### Week 2: Advanced Features
- [ ] Create custom layouts for different projects
- [ ] Test session persistence across reboots
- [ ] Try different keybinding configurations
- [ ] Evaluate performance vs tmux

### Decision Criteria
After testing, consider:
1. **Learning curve** - How quickly did you adapt?
2. **Feature parity** - Do you miss critical tmux features?
3. **Performance** - Any noticeable differences?
4. **Workflow improvement** - Does zellij make you more productive?
5. **Stability** - Any crashes or issues?

## Rollback Plan

### Easy Rollback
```bash
# Switch back to tmux as default
switch_mux tmux

# Your original dev function will work normally
dev

# Remove zellij config (optional)
cd ~/dotfiles/common
stow -D zellij
rm -rf zellij/
```

### Clean Removal
```bash
# Uninstall zellij
brew uninstall zellij

# Remove from zshrc (optional)
# Edit ~/dotfiles/common/zsh/zshrc and remove multiplexer.zsh line

# Remove multiplexer.zsh (optional)
rm ~/dotfiles/common/zsh/multiplexer.zsh
```

## Configuration Customization

### Modify Layouts
Edit layouts in `~/.config/zellij/layouts/`:
- `dev.kdl` - Main development layout
- `simple.kdl` - Simple testing layout

### Modify Keybindings
Edit `~/.config/zellij/config.kdl` to adjust:
- Key mappings
- Modes and behaviors
- Theme settings

### Theme Customization
Currently using `catppuccin-mocha`. Available themes:
- `default`
- `catppuccin-latte`
- `catppuccin-frappe`
- `catppuccin-macchiato`
- `catppuccin-mocha`

Change in config.kdl: `theme "theme-name"`

## Support and Resources

- **Zellij Documentation**: https://zellij.dev/documentation/
- **Keybindings Reference**: https://zellij.dev/documentation/keybindings.html
- **Layout Guide**: https://zellij.dev/documentation/layouts.html
- **Your tmux config**: `~/dotfiles/common/tmux/tmux.conf` (preserved)

Remember: All your tmux configuration is preserved and untouched. You can switch back at any time with `switch_mux tmux`.