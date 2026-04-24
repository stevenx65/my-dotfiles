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
  local CONFIGS=("hypr" "waybar" "kitty" "yazi" "mako" "tmux")
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
  log "Deploying configuration files..."
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  mkdir -p "$HOME/.config"
  cp -r "$SCRIPT_DIR/.config/hypr" "$HOME/.config/"
  cp -r "$SCRIPT_DIR/.config/waybar" "$HOME/.config/"
  cp -r "$SCRIPT_DIR/.config/kitty" "$HOME/.config/"
  cp -r "$SCRIPT_DIR/.config/yazi" "$HOME/.config/"
  cp -r "$SCRIPT_DIR/.config/mako" "$HOME/.config/"
  cp -r "$SCRIPT_DIR/.config/tmux" "$HOME/.config/"
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

# Main script execution
log "Script started"

# Detect OS
detect_os

# Backup configurations
backup_config

# Install packages
install_packages

# Deploy configuration files
deploy_config

# Post-installation setup
post_install_setup

# Display summary
summary

log "Script completed"
