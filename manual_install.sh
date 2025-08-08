#!/bin/bash
# Manual installation script for dotfiles (without stow)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create backup directory
BACKUP_DIR="$HOME/config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
print_info "Created backup directory: $BACKUP_DIR"

# Function to backup and link
backup_and_link() {
    local source="$1"
    local target="$2"
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory if it exists
    if [[ -e "$target" && ! -L "$target" ]]; then
        print_warning "Backing up existing $target"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
    elif [[ -L "$target" ]]; then
        print_warning "Removing existing symlink $target"
        rm "$target"
    fi
    
    # Create symlink
    ln -s "$source" "$target"
    if [[ $? -eq 0 ]]; then
        print_info "✓ Linked $target -> $source"
    else
        print_error "✗ Failed to link $target"
    fi
}

DOTFILES_DIR="$HOME/dotfiles"

# Link zsh configs
print_info "Installing zsh configs..."
backup_and_link "$DOTFILES_DIR/common/zsh/zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/common/zsh/zshenv" "$HOME/.zshenv"

# Link individual zsh modules
for zsh_file in "$DOTFILES_DIR/common/zsh/"*.zsh; do
    if [[ -f "$zsh_file" ]]; then
        filename=$(basename "$zsh_file")
        backup_and_link "$zsh_file" "$HOME/$filename"
    fi
done

# Link git config
print_info "Installing git config..."
backup_and_link "$DOTFILES_DIR/common/git/gitconfig" "$HOME/.gitconfig"

# Link tmux config
print_info "Installing tmux config..."
backup_and_link "$DOTFILES_DIR/common/tmux/tmux.conf" "$HOME/.tmux.conf"

# Link nvim config
print_info "Installing nvim config..."
backup_and_link "$DOTFILES_DIR/common/nvim" "$HOME/.config/nvim"

# Link atuin config
print_info "Installing atuin config..."
backup_and_link "$DOTFILES_DIR/common/atuin" "$HOME/.config/atuin"

# Link lazygit config
if [[ -d "$DOTFILES_DIR/common/lazygit" ]]; then
    print_info "Installing lazygit config..."
    backup_and_link "$DOTFILES_DIR/common/lazygit" "$HOME/.config/lazygit"
fi

# Link lazydocker config
if [[ -d "$DOTFILES_DIR/common/lazydocker" ]]; then
    print_info "Installing lazydocker config..."
    backup_and_link "$DOTFILES_DIR/common/lazydocker" "$HOME/.config/lazydocker"
fi

# Check if we're on Linux and install Linux-specific configs
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -d "/etc/arch-release" ]]; then
    print_info "Detected Linux system, installing Linux-specific configs..."
    
    # Link hypr configs if directory exists
    if [[ -d "$DOTFILES_DIR/linux/hypr" ]]; then
        backup_and_link "$DOTFILES_DIR/linux/hypr" "$HOME/.config/hypr"
    fi
    
    # Link waybar configs if directory exists
    if [[ -d "$DOTFILES_DIR/linux/waybar" ]]; then
        backup_and_link "$DOTFILES_DIR/linux/waybar" "$HOME/.config/waybar"
    fi
    
    # Link wofi configs if directory exists
    if [[ -d "$DOTFILES_DIR/linux/wofi" ]]; then
        backup_and_link "$DOTFILES_DIR/linux/wofi" "$HOME/.config/wofi"
    fi
fi

print_info "Installation complete!"
print_info "Backup stored in: $BACKUP_DIR"
print_warning "Note: GNU Stow is not installed. To use the official install script later, install it with: sudo pacman -S stow"