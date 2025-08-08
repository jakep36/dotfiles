#!/bin/bash
# Remote installation script for dotfiles

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
if ! command -v stow &> /dev/null; then
    print_error "GNU Stow is not installed!"
    print_info "Please install it with: sudo pacman -S stow"
    print_info "Then re-run this script."
    exit 1
fi

# Create backup directory
BACKUP_DIR="$HOME/config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
print_info "Created backup directory: $BACKUP_DIR"

# Backup existing configs
configs_to_backup=(
    ".zshrc"
    ".zshenv"
    ".tmux.conf"
    ".gitconfig"
    ".config/nvim"
    ".config/tmux"
    ".config/atuin"
    ".config/lazygit"
    ".config/lazydocker"
)

for config in "${configs_to_backup[@]}"; do
    if [[ -e "$HOME/$config" ]]; then
        print_warning "Backing up $config..."
        cp -r "$HOME/$config" "$BACKUP_DIR/"
    fi
done

print_info "Backups completed!"

# Change to dotfiles directory
cd "$HOME/dotfiles" || exit 1

# Install common dotfiles using stow
print_info "Installing common dotfiles..."
stow -v -t "$HOME" common

# Check if we're on Linux and install Linux-specific configs
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_info "Detected Linux system, installing Linux-specific configs..."
    stow -v -t "$HOME/.config" linux
fi

print_info "Dotfiles installation completed!"

# Verify some key symlinks
print_info "Verifying installation..."
links_to_check=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.tmux.conf"
)

all_good=true
for link in "${links_to_check[@]}"; do
    if [[ -L "$link" ]]; then
        print_info "✓ $link is properly linked"
    else
        print_error "✗ $link is not a symlink"
        all_good=false
    fi
done

if $all_good; then
    print_info "All key symlinks verified successfully!"
else
    print_warning "Some symlinks may not have been created properly"
fi

print_info "Installation complete! Backup stored in: $BACKUP_DIR"