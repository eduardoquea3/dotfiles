# Dotfiles - Arch Linux Dependencies

Este documento lista las aplicaciones necesarias en Arch Linux para que los dotfiles funcionen correctamente.

## Dependencias para Hyprland y Scripts

### Entorno base
```bash
sudo pacman -S hyprland waybar dunst rofi wlogout mako
```

### Screenshots y captura de pantalla
```bash
sudo pacman -S grim wl-clipboard
# O opcional: grimblast (del AUR)
yay -S grimblast
```

### Portapapeles (Clipboard)
```bash
sudo pacman -S wl-clipboard cliphist
```

### Bloqueo de pantalla
```bash
yay -S hyprlock
```

### Notificaciones
```bash
sudo pacman -S dunst libnotify
```

### Utilidades varias
```bash
sudo pacman -S brightnessctl playerctl pamixer gpick
yay -S wlsunset
```

### Sistema de ventanas y docks
```bash
sudo pacman -S eww-wayland
yay -S quickshell
```

## Dependencias adicionales

### Terminal y fuentes
```bash
sudo pacman -S ghostty
# Fuentes recomendadas
yay -S nerd-fonts-dank-mono
```

### Editor
```bash
sudo pacman -S neovim
```

### Shell
```bash
sudo pacman -S zsh starship
yay -S zsh-autosuggestions zsh-syntax-highlighting
```

### Utilidades de desarrollo
```bash
sudo pacman -S git docker lazygit lazydocker
yay -S atuin
```

### GNOME Keyring (para secretos)
```bash
sudo pacman -S gnome-keyring libsecret
```

## Instalación rápida

```bash
# Paquetes principales de pacman
sudo pacman -S hyprland waybar dunst rofi wlogout mako grim wl-clipboard \
    cliphist brightnessctl playerctl pamixer gpick libnotify \
    ghostty neovim zsh starship git docker lazygit lazydocker

# Paquetes del AUR
yay -S grimblast hyprlock quickshell wlsunset nerd-fonts-dank-mono \
    zsh-autosuggestions zsh-syntax-highlighting atuin
```

## Configuración post-instalación

1. Clonar los dotfiles
2. Ejecutar `./deploy.sh` para crear los symlinks
3. Reiniciar la sesión o ejecutar `hyprctl reload`

## Notas

- Algunos scripts requieren `python` para funcionalidades adicionales
- `gsettings` (del paquete glib2) se usa para obtener la fuente del sistema en wlogout
