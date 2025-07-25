# Dotfiles

Cross-platform dotfiles for Mac (Aerospace) and Linux (Hyprland) with unified keybindings and consistent developer experience.

## Structure

```
dotfiles/
├── common/          # Shared configs for both platforms
│   ├── git/        # Git configuration
│   ├── nvim/       # Neovim (LazyVim) config
│   ├── tmux/       # Tmux configuration
│   ├── zsh/        # Zsh shell configs
│   ├── atuin/      # Shell history sync
│   └── fzf/        # Fuzzy finder config
├── mac/            # Mac-specific configs
│   └── aerospace/  # Aerospace window manager
├── linux/          # Linux-specific configs
│   ├── hypr/       # Hyprland window manager
│   └── waybar/     # Status bar for Wayland
├── install.sh      # Installation script
├── sync.sh         # Sync between machines
└── KEYBINDINGS.md  # Unified keybinding reference
```

## Installation

### Prerequisites

- GNU Stow
  - Mac: `brew install stow`
  - Arch Linux: `sudo pacman -S stow`

### Quick Install

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run the installation script
./install.sh
```

The install script will:
1. Backup existing configurations
2. Install common dotfiles
3. Install platform-specific configs
4. Set up symbolic links using GNU Stow

### Manual Installation

```bash
# Install common configs
stow -d ~/dotfiles/common -t ~ git
stow -d ~/dotfiles/common -t ~/.config nvim tmux zsh

# Mac-specific
stow -d ~/dotfiles/mac -t ~/.config aerospace

# Linux-specific
stow -d ~/dotfiles/linux -t ~/.config hypr waybar
```

## Syncing Between Machines

### Push changes to remote Linux machine
```bash
./sync.sh push
```

### Pull Linux configs from remote
```bash
./sync.sh pull
```

### Commit and push to git
```bash
./sync.sh
```

## Key Features

### Unified Keybindings
- Consistent muscle memory across Mac and Linux
- Cmd (Mac) ≈ Super (Linux) for window management
- Vim-style navigation everywhere (h/j/k/l)
- See [KEYBINDINGS.md](KEYBINDINGS.md) for full reference

### Developer Tools
- **Neovim**: LazyVim distribution with same plugins
- **Tmux**: Custom prefix (Ctrl+S), vim navigation
- **Git**: Delta for diffs, consistent aliases
- **Shell**: Zsh with custom AWS and CLI tools

### Window Management
- **Mac**: Aerospace with tiling support
- **Linux**: Hyprland with animations
- Both configured for similar keybindings

## Customization

### Adding New Configs

1. Place common configs in `common/app_name/`
2. Place platform-specific in `mac/` or `linux/`
3. Update `install.sh` to include new stow commands
4. Test installation on both platforms

### Modifying Keybindings

- Mac: Edit `mac/aerospace/aerospace.toml`
- Linux: Edit `linux/hypr/hyprland.conf`
- Keep [KEYBINDINGS.md](KEYBINDINGS.md) updated

## Troubleshooting

### Stow Conflicts
If you get conflicts during installation:
```bash
# Remove the conflicting file/link
rm ~/.config/nvim  # or whatever conflicts

# Re-run stow
stow -d ~/dotfiles/common -t ~/.config nvim
```

### Permission Issues
```bash
# Ensure scripts are executable
chmod +x install.sh sync.sh
```

### Remote Sync Issues
- Check SSH access: `ssh jparsell@100.119.167.52`
- Verify rsync is installed on both machines

## TODO
- [ ] Add lazygit configuration
- [ ] Add lazydocker configuration
- [ ] Set up automated backups
- [ ] Add pre-commit hooks