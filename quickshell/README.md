# Quickshell

This directory contains a Quickshell config for Hyprland with a top bar, launcher, wallpaper picker, clipboard overlay, keybind viewer, logout menu, and a Codex usage widget.

## Required runtime

Install these components for the config to work as written. Package names vary by distro; Arch examples are shown where useful.

| Component | Needed for | Notes |
| --- | --- | --- |
| Quickshell | All QML entrypoints | Requires the `Quickshell`, `Quickshell.Io`, `Quickshell.Wayland`, and `Quickshell.Hyprland` imports used by the config. |
| Qt Quick stack | All UI components | `QtQuick`, `QtQuick.Layouts`, `QtQuick.Controls`, and `Qt5Compat.GraphicalEffects` are imported by multiple modules. |
| Hyprland | Workspaces, IPC, window actions | The bar, launcher, wallpaper picker, logout menu, and clipboard overlay all rely on Hyprland integration. |
| PipeWire | Audio widget | Used through `Quickshell.Services.Pipewire` in `modules/bar/Volume.qml`. |
| UPower | Battery widget | Used through `Quickshell.Services.UPower` in `modules/bar/Battery.qml`. |
| NetworkManager | Wi-Fi widget | `nmcli` is called from `modules/bar/Wifi.qml`. |
| BlueZ | Bluetooth widget and connection panel | Used through `Quickshell.Bluetooth` in `modules/connectivity/ConnectionPanel.qml`. |
| brightnessctl | Brightness widget | `modules/bar/Brightness.qml` calls `brightnessctl set ...`. |
| cliphist | Clipboard history | Required by `modules/clipboard/Clipboard.qml` and `scripts/cliphist-visual.sh`. |
| wl-clipboard | Clipboard copy | `wl-copy` is used when restoring a clipboard item. |
| jq | Keybind viewer | `modules/keybinds/Keybinds.qml` parses JSON through `jq`. |
| gawk | Clipboard preview helper | `scripts/cliphist-visual.sh` uses `gawk`. |
| ImageMagick | Wallpaper thumbnails | `convert` is used in `modules/launcher/Launcher.qml`. |
| awww / awww-daemon | Wallpaper application | `modules/wallpaper/Wallpaper.qml` and `modules/launcher/Launcher.qml` call `awww`. |
| codexbar | Codex usage widget | `modules/bar/CodexUsage.qml` runs `codexbar usage --provider codex --source cli --format json`. |
| systemd tools | Logout actions | `loginctl` and `systemctl` are used in `modules/logout/Logout.qml`. |
| Bash coreutils | Helper commands | `bash`, `sh`, `find`, `grep`, `sed`, `md5sum`, `mkdir`, `rm`, `head`, and `cat` are used by several modules. |

## Recommended fonts

- JetBrainsMono Nerd Font
- Any Nerd Font icon set that covers the glyphs used by the bar, clipboard, and logout icons

## Feature map

| Feature | File(s) | External dependency |
| --- | --- | --- |
| Top bar and workspaces | `widgets/Bar.qml`, `modules/bar/Workspace.qml` | Hyprland |
| Clock | `modules/bar/Time.qml`, `modules/bar/Date.qml` | None beyond Quickshell/Qt |
| Volume | `modules/bar/Volume.qml` | PipeWire |
| Battery | `modules/bar/Battery.qml` | UPower |
| Wi-Fi | `modules/bar/Wifi.qml` | NetworkManager (`nmcli`) |
| Bluetooth | `modules/bar/Bluetooth.qml`, `modules/connectivity/ConnectionPanel.qml` | BlueZ |
| Brightness | `modules/bar/Brightness.qml` | `brightnessctl` and backlight sysfs |
| Logout menu | `modules/logout/*` | `systemctl`, `loginctl`, and `~/.config/hypr/scripts/lockscreen` |
| Wallpaper picker | `modules/wallpaper/*`, `modules/launcher/*` | `awww`, `awww-daemon`, ImageMagick |
| Launcher | `modules/launcher/*` | `.desktop` files, `md5sum`, `find`, `awk`, ImageMagick |
| Clipboard history | `modules/clipboard/*`, `scripts/cliphist-visual.sh` | `cliphist`, `wl-copy`, `gawk` |
| Keybind viewer | `modules/keybinds/*` | `~/.config/hypr/scripts/hint-hyprland.py`, `jq` |
| Codex usage panel | `modules/bar/CodexUsage*.qml` | `codexbar` |

## Setup

1. Install Quickshell and the Qt/QML modules listed above.
2. Install the external CLI tools from the runtime table.
3. Make sure the Hyprland helper scripts exist at `~/.config/hypr/scripts/`:
   - `hint-hyprland.py`
   - `lockscreen`
   - `wlogout`
4. Ensure `~/.config/hypr/img/` exists and contains wallpapers if you want the wallpaper picker and launcher thumbnails to show content.
5. Install and authenticate `codexbar` so `codexbar usage ...` returns JSON.
6. Launch Quickshell with `shell.qml` as the entrypoint using your normal Quickshell startup method.

## CodexBar

The Codex widget is not hardcoded data. It shells out to:

```bash
codexbar usage --provider codex --source cli --format json
```

If that command fails, the bar shows an error state. For the widget to work, `codexbar` must be installed, on `PATH`, and logged in to the Codex account/provider it expects.

## Verification

- Start Quickshell and confirm the bar renders.
- Check that workspace buttons react to Hyprland workspaces.
- Open the Codex usage popup and confirm it shows limits instead of an error.
- Test `nmcli`, `brightnessctl`, `cliphist`, and `awww` manually if a module stays empty.

## Troubleshooting

- Empty Wi-Fi widget: confirm `nmcli` works and NetworkManager is running.
- Empty battery widget: confirm the system exposes UPower and a display battery device.
- Empty volume widget: confirm PipeWire is running and Quickshell can read the default sink.
- Empty Codex widget: run the `codexbar usage ...` command manually and check JSON output.
- Clipboard overlay missing items: confirm `cliphist` has history and `wl-copy` is installed.
- Wallpaper picker empty: confirm images exist under `~/.config/hypr/img/`.

## Notes

- The config uses Hyprland-specific APIs, so it is not compositor-agnostic.
- Some helpers live outside this repository under `~/.config/hypr/scripts/` and must be provided separately.
