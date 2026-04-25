#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#           Dotfiles Installation Script | 配置文件安装脚本   ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Utility Functions | 工具函数                   ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Log function with timestamp | 带时间戳的日志函数
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              OS Detection | 操作系统检测                    ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Detect OS and set package manager | 检测操作系统并设置包管理器
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Backup Function | 备份函数                     ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Backup existing configuration files | 备份现有配置文件
backup_config() {
  TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
  BACKUP_DIR="$HOME/.config_backup_$TIMESTAMP"
  mkdir -p "$BACKUP_DIR"
  log "Backing up configuration files to $BACKUP_DIR"

  # Backup specific config directories that will be replaced
  # 备份将被替换的特定配置目录
  local CONFIGS=("$@")
  for config in "${CONFIGS[@]}"; do
    if [[ -d "$HOME/.config/$config" ]]; then
      cp -r "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
  done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Package Installation | 包安装                  ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Install packages based on OS | 根据操作系统安装包
install_packages() {
  log "Installing necessary packages..."
  case "$PACKAGE_MANAGER" in
    pacman)
      # Arch Linux packages | Arch Linux 包
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Config Deployment | 配置部署                   ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Deploy configuration files | 部署配置文件
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Post-Installation | 安装后设置                 ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Post-installation setup | 安装后设置
post_install_setup() {
  log "Performing post-installation setup..."
  # Add any additional setup commands here
  # 在此添加其他设置命令
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Summary Function | 摘要函数                    ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Display deployment summary | 显示部署摘要
summary() {
  log "Deployment summary:"
  log "- OS: $ID"
  log "- Package Manager: $PACKAGE_MANAGER"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Help Message | 帮助信息                        ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Show help message | 显示帮助信息
show_help() {
  cat << EOF
Usage: $0 [OPTIONS]

Install dotfiles with selective configuration options.
使用选择性配置选项安装配置文件。

Options | 选项:
  -h, --help          Show this help message
  -l, --list          List available configurations | 列出可用配置
  -c, --config CONFIG Install only specified configuration(s)
                      仅安装指定的配置
                      Multiple configs can be specified: -c hypr -c waybar
                      可以指定多个配置：-c hypr -c waybar
  -y, --yes           Skip confirmation prompt | 跳过确认提示

Available configurations | 可用配置:
  hypr    - Hyprland window manager configuration | Hyprland 窗口管理器配置
  waybar  - Waybar status bar configuration | Waybar 状态栏配置
  kitty   - Kitty terminal configuration | Kitty 终端配置
  yazi    - Yazi file manager configuration | Yazi 文件管理器配置
  mako    - Mako notification daemon configuration | Mako 通知守护进程配置
  tmux    - Tmux terminal multiplexer configuration | Tmux 终端复用器配置
  fish    - Fish shell configuration | Fish shell 配置

Examples | 示例:
  $0                          # Install all configurations | 安装所有配置
  $0 -c hypr -c waybar        # Install only Hyprland and Waybar | 仅安装 Hyprland 和 Waybar
  $0 -l                       # List available configurations | 列出可用配置
  $0 -c tmux -y               # Install only tmux without confirmation | 仅安装 tmux 且跳过确认
  $0 -c fish -y               # Install only fish without confirmation | 仅安装 fish 且跳过确认

EOF
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              List Configurations | 列出配置                 ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# List available configurations | 列出可用配置
list_configs() {
  echo "Available configurations | 可用配置:"
  echo "  hypr    - Hyprland window manager configuration | Hyprland 窗口管理器配置"
  echo "  waybar  - Waybar status bar configuration | Waybar 状态栏配置"
  echo "  kitty   - Kitty terminal configuration | Kitty 终端配置"
  echo "  yazi    - Yazi file manager configuration | Yazi 文件管理器配置"
  echo "  mako    - Mako notification daemon configuration | Mako 通知守护进程配置"
  echo "  tmux    - Tmux terminal multiplexer configuration | Tmux 终端复用器配置"
  echo "  fish    - Fish shell configuration | Fish shell 配置"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Command Line Parsing | 命令行解析             ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Parse command line arguments | 解析命令行参数
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
# 默认：如果未指定，则安装所有配置
if [[ ${#CONFIGS_TO_INSTALL[@]} -eq 0 ]]; then
  CONFIGS_TO_INSTALL=("hypr" "waybar" "kitty" "yazi" "mako" "tmux" "fish")
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#              Main Script Execution | 主脚本执行             ┃
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Main script execution | 主脚本执行
log "Script started"

# Detect OS | 检测操作系统
detect_os

# Backup configurations | 备份配置
backup_config "${CONFIGS_TO_INSTALL[@]}"

# Install packages | 安装包
install_packages

# Deploy configuration files | 部署配置文件
deploy_config "${CONFIGS_TO_INSTALL[@]}"

# Post-installation setup | 安装后设置
post_install_setup

# Display summary | 显示摘要
summary

log "Script completed"
