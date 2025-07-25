#!/usr/bin/env bash

# Dotfiles installation script
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

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

# Check if stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed!"
        if [[ "$OS" == "Darwin" ]]; then
            print_info "Install with: brew install stow"
        else
            print_info "Install with: sudo pacman -S stow (Arch) or appropriate package manager"
        fi
        exit 1
    fi
}

# Backup existing configs
backup_config() {
    local config_path="$1"
    if [[ -e "$config_path" && ! -L "$config_path" ]]; then
        print_warning "Backing up existing $config_path to ${config_path}.backup"
        mv "$config_path" "${config_path}.backup"
    fi
}

# Install common dotfiles
install_common() {
    print_info "Installing common dotfiles..."
    
    # Git
    backup_config "$HOME/.gitconfig"
    stow -d "$DOTFILES_DIR/common" -t "$HOME" git
    
    # Neovim
    backup_config "$HOME/.config/nvim"
    mkdir -p "$HOME/.config"
    stow -d "$DOTFILES_DIR/common" -t "$HOME/.config" nvim
    
    # Tmux
    backup_config "$HOME/.config/tmux"
    stow -d "$DOTFILES_DIR/common" -t "$HOME/.config" tmux
    
    # Zsh
    backup_config "$HOME/.zshrc"
    backup_config "$HOME/.zshenv"
    backup_config "$HOME/.config/zsh"
    stow -d "$DOTFILES_DIR/common" -t "$HOME" zsh
    
    # Atuin
    if [[ -d "$DOTFILES_DIR/common/atuin" && -n "$(ls -A $DOTFILES_DIR/common/atuin)" ]]; then
        backup_config "$HOME/.config/atuin"
        stow -d "$DOTFILES_DIR/common" -t "$HOME/.config" atuin
    fi
    
    # Lazygit
    if [[ -d "$DOTFILES_DIR/common/lazygit" && -n "$(ls -A $DOTFILES_DIR/common/lazygit)" ]]; then
        backup_config "$HOME/.config/lazygit"
        stow -d "$DOTFILES_DIR/common" -t "$HOME/.config" lazygit
    fi
    
    print_info "Common dotfiles installed!"
}

# Install Mac-specific dotfiles
install_mac() {
    print_info "Installing Mac-specific dotfiles..."
    
    # Aerospace
    backup_config "$HOME/.config/aerospace"
    stow -d "$DOTFILES_DIR/mac" -t "$HOME/.config" aerospace
    
    print_info "Mac-specific dotfiles installed!"
}

# Install Linux-specific dotfiles
install_linux() {
    print_info "Installing Linux-specific dotfiles..."
    
    # Hyprland
    if [[ -d "$DOTFILES_DIR/linux/hypr" && -n "$(ls -A $DOTFILES_DIR/linux/hypr)" ]]; then
        backup_config "$HOME/.config/hypr"
        stow -d "$DOTFILES_DIR/linux" -t "$HOME/.config" hypr
    fi
    
    # Waybar
    if [[ -d "$DOTFILES_DIR/linux/waybar" && -n "$(ls -A $DOTFILES_DIR/linux/waybar)" ]]; then
        backup_config "$HOME/.config/waybar"
        stow -d "$DOTFILES_DIR/linux" -t "$HOME/.config" waybar
    fi
    
    # Wofi
    if [[ -d "$DOTFILES_DIR/linux/wofi" && -n "$(ls -A $DOTFILES_DIR/linux/wofi)" ]]; then
        backup_config "$HOME/.config/wofi"
        stow -d "$DOTFILES_DIR/linux" -t "$HOME/.config" wofi
    fi
    
    print_info "Linux-specific dotfiles installed!"
}

# Main installation
main() {
    print_info "Starting dotfiles installation..."
    print_info "Dotfiles directory: $DOTFILES_DIR"
    print_info "Operating System: $OS"
    
    check_stow
    
    # Install common dotfiles
    install_common
    
    # Install OS-specific dotfiles
    if [[ "$OS" == "Darwin" ]]; then
        install_mac
    elif [[ "$OS" == "Linux" ]]; then
        install_linux
    else
        print_error "Unsupported operating system: $OS"
        exit 1
    fi
    
    print_info "Installation complete!"
    print_info "Remember to:"
    print_info "  1. Source your shell config: source ~/.zshrc"
    print_info "  2. Install tmux plugins: <prefix>+I in tmux"
    print_info "  3. Install neovim plugins: Launch nvim"
}

# Run main function
main "$@"