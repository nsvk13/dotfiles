#!/bin/bash

# Dotfiles installer script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt >/dev/null 2>&1; then
            OS="ubuntu"
        elif command -v yum >/dev/null 2>&1; then
            OS="centos"
        elif command -v apk >/dev/null 2>&1; then
            OS="alpine"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    log_info "Detected OS: $OS"
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    case $OS in
        ubuntu)
            sudo apt update
            sudo apt install -y git curl zsh nano
            ;;
        centos)
            sudo yum update -y
            sudo yum install -y git curl zsh nano
            ;;
        alpine)
            sudo apk update
            sudo apk add git curl zsh nano
            ;;
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install git curl zsh nano
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    log_success "Dependencies installed!"
}

install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed!"
    else
        log_warning "Oh My Zsh already installed"
    fi
}

install_powerlevel10k() {
    log_info "Installing Powerlevel10k..."
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log_success "Powerlevel10k installed to Oh My Zsh!"
    else
        log_warning "Powerlevel10k (Oh My Zsh) already installed"
    fi
    
    if [[ ! -d "$HOME/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
        log_success "Powerlevel10k installed to ~/powerlevel10k!"
    else
        log_warning "Powerlevel10k (direct) already installed"
    fi
}

install_zsh_plugins() {
    log_info "Installing Zsh plugins..."
    
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed!"
    else
        log_warning "zsh-autosuggestions already installed"
    fi
    
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed!"
    else
        log_warning "zsh-syntax-highlighting already installed"
    fi
}



setup_nano() {
    log_info "Setting up nano with syntax highlighting..."
    
    if [[ ! -d "$HOME/.nano" ]]; then
        git clone https://github.com/scopatz/nanorc.git "$HOME/.nano"
        log_success "Enhanced nano configs installed!"
    else
        log_warning "Enhanced nano configs already installed"
    fi
}

copy_configs() {
    log_info "Copying configuration files..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local configs_dir="$script_dir/configs"
    
    if [[ ! -d "$configs_dir" ]]; then
        log_error "Configs directory not found: $configs_dir"
        exit 1
    fi
    
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing .zshrc"
    fi
    
    if [[ -f "$HOME/.nanorc" ]]; then
        cp "$HOME/.nanorc" "$HOME/.nanorc.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing .nanorc"
    fi
    
    if [[ -f "$configs_dir/.zshrc" ]]; then
        cp "$configs_dir/.zshrc" "$HOME/.zshrc"
        log_success "Copied .zshrc"
    else
        log_warning ".zshrc not found in configs directory"
    fi
    
    if [[ -f "$configs_dir/.nanorc" ]]; then
        cp "$configs_dir/.nanorc" "$HOME/.nanorc"
        log_success "Copied .nanorc"
    else
        log_warning ".nanorc not found in configs directory"
    fi
    
    if [[ -f "$configs_dir/.p10k.zsh" ]]; then
        cp "$configs_dir/.p10k.zsh" "$HOME/.p10k.zsh"
        log_success "Copied .p10k.zsh"
    fi
}

setup_zsh() {
    log_info "Setting up Zsh..."
    
    if ! command -v zsh >/dev/null 2>&1; then
        log_error "Zsh not found!"
        exit 1
    fi
    
    if [[ "$SHELL" != *"zsh" ]]; then
        log_info "Changing default shell to zsh..."
        chsh -s $(which zsh)
        log_warning "Please restart your terminal or run 'exec zsh' to apply changes"
    fi
    
    log_success "Zsh setup complete!"
}

main() {
    log_info "Starting dotfiles installation..."
    
    detect_os
    install_dependencies
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    setup_nano
    copy_configs
    setup_zsh
    
    log_success "Installation complete!"
    echo ""
    log_info "Next steps:"
    log_info "1. Restart your terminal or run 'exec zsh'"
    log_info "2. Run 'p10k configure' to customize Powerlevel10k if needed"
    echo ""
    log_success "Enjoy your new development environment! 🚀"
}

main "$@"