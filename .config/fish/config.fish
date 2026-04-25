# D-Bus session bus address for Wayland notifications
# 使用 systemd 用户环境中的值（确保正确）
# Get DBUS session bus address from systemd user environment (ensure correctness)
if test -z "$DBUS_SESSION_BUS_ADDRESS"
    set -gx DBUS_SESSION_BUS_ADDRESS (systemctl --user show-environment | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)
end

source /usr/share/cachyos-fish-config/cachyos-config.fish
starship init fish | source
zoxide init fish | source
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
