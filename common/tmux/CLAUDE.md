# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a tmux configuration directory containing the main tmux configuration file and various plugins managed by TPM (Tmux Plugin Manager). The setup includes theme plugins, navigation enhancements, and session management tools.

## Common Commands

### Tmux Configuration Management
- Reload tmux configuration: `tmux source ~/.config/tmux/tmux.conf` or use prefix key + `r`
- Install plugins: prefix key + `I` (capital i)
- Update plugins: prefix key + `U` 
- Remove plugins: prefix key + `alt + u`

### Plugin Management
- TPM is located at `~/.config/tmux/plugins/tpm/`
- Plugins are installed in `~/.config/tmux/plugins/`
- Plugin definitions are in `tmux.conf` using `set -g @plugin` syntax

## Key Architecture

### Main Configuration
- `tmux.conf` - Primary configuration file with custom keybindings and plugin declarations
- Prefix key changed from default Ctrl-b to Ctrl-s
- Vi-mode keybindings enabled for copy mode
- Mouse support enabled

### Plugin Structure
- **tpm** - Tmux Plugin Manager for installing/managing other plugins
- **catppuccin-tmux** & **tokyo-night-tmux** - Theme plugins (dual theme setup)
- **vim-tmux-navigator** - Seamless navigation between tmux panes and vim splits
- **tmux-yank** - Enhanced copy functionality
- **tmux-fzf** & **tmux-fzf-url** - Fuzzy finder integrations
- **tmux-sensible** - Sensible default settings
- **tmux-sessionx** - Advanced session management

### Custom Keybindings
- Pane splitting: `\` (horizontal), `-` (vertical)
- Pane resizing: Ctrl+Alt+Arrow keys
- Session switching: prefix + `t` (opens sesh fuzzy finder)
- New window: prefix + `c` (opens in current directory)
- Vim-aware pane navigation: Ctrl+h/j/k/l

### Integration Points
- Sesh session manager integration for enhanced session switching
- FZF integration for URL opening and general fuzzy finding
- Vim/Neovim integration for seamless pane navigation
- System clipboard integration via tmux-yank

When modifying configurations, test changes by reloading the tmux config and ensure plugin compatibility.