#!/bin/bash

# Utility functions for logging
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Detect OS and set package manager
detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      arch)
        PACKAGE_MANAGER="pacman"
        ;;
      ubuntu|debian)
        PACKAGE_MANAGER="apt"
        ;;
      fedora|rhel)
        PACKAGE_MANAGER="dnf"
        ;;
      darwin)
        PACKAGE_MANAGER="brew"
        ;;
      *)
        log "Unsupported OS: $ID"
        exit 1
        ;;
    esac
  else
    log "OS detection failed!"
    exit 1
  fi
}

# Backup function
backup_config() {
  TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
  BACKUP_DIR="$HOME/.config_backup_$TIMESTAMP"
  mkdir -p "$BACKUP_DIR"
  log "Backing up configuration files to $BACKUP_DIR"

  # Backup specific config directories that will be replaced
  local CONFIGS=("$@")
  for config in "${CONFIGS[@]}"; do
    if [[ -d "$HOME/.config/$config" ]]; then
      cp -r "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
  done
}

# Install packages based on OS
install_packages() {
  log "Installing necessary packages..."
  case "$PACKAGE_MANAGER" in
    pacman)
      sudo pacman -S --noconfirm hyprland waybar kitty yazi neovim stow \
        wlogout pavucontrol network-manager-applet btop blueman \
        fcitx5 fcitx5-configtool waypaper cliphist wl-clipboard \
        polkit-kde-agent brightnessctl mako libcanberra tmux
      ;;
    apt)
      log "Warning: apt packages not fully configured"
      ;;
    dnf)
      log "Warning: dnf packages not fully configured"
      ;;
    brew)
      log "Warning: brew packages not fully configured (macOS not supported for Hyprland)"
      ;;
  esac
}

# Deploy configuration files
deploy_config() {
  local CONFIGS=("$@")
  log "Deploying configuration files for: ${CONFIGS[*]}"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  mkdir -p "$HOME/.config"
  for config in "${CONFIGS[@]}"; do
    if [[ -d "$SCRIPT_DIR/.config/$config" ]]; then
      cp -r "$SCRIPT_DIR/.config/$config" "$HOME/.config/"
      log "Deployed $config"
    else
      log "Warning: $config configuration not found, skipping"
    fi
  done
}

# Post-installation setup
post_install_setup() {
  log "Performing post-installation setup..."
  # Add any additional setup commands here
}

# Summary function
summary() {
  log "Deployment summary:"
  log "- OS: $ID"
  log "- Package Manager: $PACKAGE_MANAGER"
}

# Show help message
show_help() {
  cat << EOF
Usage: $0 [OPTIONS]

Install dotfiles with selective configuration options.

Options:
  -h, --help          Show this help message
  -l, --list          List available configurations
  -c, --config CONFIG Install only specified configuration(s)
                      Multiple configs can be specified: -c hypr -c waybar
  -y, --yes           Skip confirmation prompt

Available configurations:
  hypr    - Hyprland window manager configuration
  waybar  - Waybar status bar configuration
  kitty   - Kitty terminal configuration
  yazi    - Yazi file manager configuration
  mako    - Mako notification daemon configuration
  tmux    - Tmux terminal multiplexer configuration

Examples:
  $0                          # Install all configurations
  $0 -c hypr -c waybar        # Install only Hyprland and Waybar
  $0 -l                       # List available configurations
  $0 -c tmux -y               # Install only tmux without confirmation

EOF
}

# List available configurations
list_configs() {
  echo "Available configurations:"
  echo "  hypr    - Hyprland window manager configuration"
  echo "  waybar  - Waybar status bar configuration"
  echo "  kitty   - Kitty terminal configuration"
  echo "  yazi    - Yazi file manager configuration"
  echo "  mako    - Mako notification daemon configuration"
  echo "  tmux    - Tmux terminal multiplexer configuration"
}

# Parse command line arguments
CONFIGS_TO_INSTALL=()
SKIP_CONFIRMATION=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -l|--list)
      list_configs
      exit 0
      ;;
    -c|--config)
      if [[ -n "$2" ]]; then
        CONFIGS_TO_INSTALL+=("$2")
        shift 2
      else
        log "Error: -c/--config requires a configuration name"
        exit 1
      fi
      ;;
    -y|--yes)
      SKIP_CONFIRMATION=true
      shift
      ;;
    *)
      log "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Default: install all configurations if none specified
if [[ ${#CONFIGS_TO_INSTALL[@]} -eq 0 ]]; then
  CONFIGS_TO_INSTALL=("hypr" "waybar" "kitty" "yazi" "mako" "tmux")
fi

# Main script execution
log "Script started"

# Detect OS
detect_os

# Backup configurations
backup_config "${CONFIGS_TO_INSTALL[@]}"

# Install packages
install_packages

# Deploy configuration files
deploy_config "${CONFIGS_TO_INSTALL[@]}"

# Post-installation setup
post_install_setup

# Display summary
summary

log "Script completed"
