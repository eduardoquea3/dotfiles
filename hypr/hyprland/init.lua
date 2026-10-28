--#################
--### AUTOSTART ###
--#################

hl.on("hyprland.start", function()
  hl.exec_cmd "$HOME/.config/hypr/scripts/toggle_quickshell"
  hl.exec_cmd "$HOME/.config/hypr/scripts/set_wallpaper"
  hl.exec_cmd "$HOME/.config/hypr/scripts/music.sh"

  hl.exec_cmd "wl-paste --type text --watch cliphist store"
  hl.exec_cmd "wl-paste --type image --watch cliphist store"
  hl.exec_cmd "dunst"
  hl.exec_cmd "gnome-keyring-daemon --start --components=secrets"
  hl.exec_cmd "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  hl.exec_cmd "qs -c overview"

  hl.exec_cmd("orca-ide open", { workspace = "2 silent" })
  hl.exec_cmd("zen-browser", { workspace = "1 silent" })

  hl.dispatch(hl.dsp.focus({ workspace = 2 }))
end)
