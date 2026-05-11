# Snacks.nvim GitHub Integration

This document describes the GitHub integration setup for Snacks.nvim in your Neovim configuration.

**Note:** Octo.nvim has been removed in favor of Snacks.nvim GitHub integration for a lighter, faster experience.

## Prerequisites

✅ **GitHub CLI (gh)** - Installed and authenticated
✅ **Snacks.nvim** - Configured with GitHub integration

## Available Keybindings

### GitHub Issues
- `<leader>gi` - Browse open GitHub issues
- `<leader>gI` - Browse all GitHub issues (including closed)

### GitHub Pull Requests
- `<leader>gp` - Browse open pull requests
- `<leader>gP` - Browse all pull requests (including closed/merged)

### GitHub Repositories
- `<leader>gr` - Browse GitHub repositories

### Git Operations
- `<leader>gg` - Open Lazygit
- `<leader>gb` - Git blame current line
- `<leader>gB` - Open current file/line in GitHub browser
- `<leader>gf` - Lazygit current file history
- `<leader>gl` - Lazygit log for current directory

### Terminal and Utilities
- `<c-/>` - Toggle terminal
- `<leader>bd` - Delete current buffer
- `<leader>un` - Dismiss all notifications
- `]]` - Jump to next reference
- `[[` - Jump to previous reference

## Usage

1. **Browse Issues**: Press `<leader>gi` to open a picker with all open issues in the current repository
2. **Browse PRs**: Press `<leader>gp` to see all open pull requests
3. **Navigate**: Use arrow keys or vim navigation in the picker
4. **Actions**: Press `<Enter>` on any item to see available actions (open, comment, close, etc.)

## GitHub Buffer Actions

When viewing a GitHub issue or PR in a buffer:
- `<cr>` - Show available actions
- `i` - Edit title/body
- `a` - Add comment
- `c` - Close issue/PR
- `o` - Reopen issue/PR

## Configuration Location

The main configuration is in: `lua/plugins/snacks.lua`

## Features Enabled

- GitHub issue browsing and management
- Pull request browsing and management
- Repository navigation
- Integration with existing git workflow
- Terminal integration
- Buffer management utilities
- Word reference jumping
- Debug utilities (`dd()`, `bt()`)