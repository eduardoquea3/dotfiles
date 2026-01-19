# Kit de Keybinds Hint para Sistemas sin HyDE

Este paquete contiene todo lo necesario para tener el menú de keybinds de HyDE en cualquier sistema Hyprland.

## Archivos Incluidos

### Scripts Principales
- `keybinds_hint.sh` - Script principal del menú de keybinds
- `hint-hyprland.py` - Generador Python de keybinds
- `cliphist-copy.sh` - Script independiente para clipboard
- `HyDE-Keybind-System.md` - Documentación completa del sistema

### Temas Rofi
- `keybinds.rasi` - Tema principal para menú de keybinds
- `themes/` - Directorio completo de temas .rasi
  - `clipboard.rasi` - Tema base (usado por keybinds)
  - Todos los demás temas HyDE

## Instalación

### 1. Copiar Archivos
```bash
# Crear estructura de directorios
mkdir -p ~/.local/lib/hyde/keybinds
mkdir -p ~/.local/lib/hyde
mkdir -p ~/.local/share/hyde/rofi/themes

# Copiar scripts
cp keybinds_hint.sh ~/.local/lib/hyde/
cp hint-hyprland.py ~/.local/lib/hyde/keybinds/

# Copiar temas
cp keybinds.rasi ~/.local/share/hyde/rofi/themes/
cp -r themes/* ~/.local/share/hyde/rofi/themes/

# Hacer scripts ejecutables
chmod +x ~/.local/lib/hyde/keybinds_hint.sh
chmod +x ~/.local/lib/hyde/keybinds/hint-hyprland.py
```

### 2. Instalar Dependencias

#### Arch Linux / Manjaro
```bash
sudo pacman -S hyprland rofi jq python3 libnotify
```

#### Debian / Ubuntu
```bash
sudo apt install hyprland rofi jq python3 libnotify-bin
```

#### Fedora
```bash
sudo dnf install hyprland rofi jq python3 libnotify
```

#### openSUSE
```bash
sudo zypper install hyprland rofi jq python3 libnotify
```

### 3. Crear Script de Acceso
```bash
# Crear script principal
cat > ~/.local/bin/keybinds-hint << 'EOF'
#!/usr/bin/env bash

# Configuración
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_CONFIG_HOME="$HOME/.config"
export HYDE_RUNTIME_DIR="${XDG_RUNTIME_DIR}/hyde"

# Directorios
SCRIPT_DIR="$HOME/.local/lib/hyde"
KEYBINDS_CACHE="${HYDE_RUNTIME_DIR}/keybinds_hint.rofi"

# Asegurar directorios
mkdir -p "$HYDE_RUNTIME_DIR"

# Función de notificación
send_notifs() {
    if command -v notify-send &> /dev/null; then
        notify-send "$1" "$2" -t 3000
    fi
}

# Ejecutar script principal
if [[ -f "$SCRIPT_DIR/keybinds_hint.sh" ]]; then
    bash "$SCRIPT_DIR/keybinds_hint.sh" "$@"
else
    send_notifs "Error" "keybinds_hint.sh not found"
fi
EOF

chmod +x ~/.local/bin/keybinds-hint
```

### 4. Configurar Keybind en Hyprland
Agregar a tu `hyprland.conf` o `keybindings.conf`:

```bash
# Keybind para mostrar menú de keybinds
bind = SUPER, slash, exec, pkill -x rofi || keybinds-hint
```

### 5. Configurar Rofi (Opcional)
Si tienes un tema rofi personalizado, puedes crear `~/.config/rofi/theme.rasi` o el sistema usará los temas incluidos.

## Variables de Entorno Opcionales

Puedes personalizar el comportamiento con estas variables:

```bash
export ROFI_KEYBIND_HINT_STYLE="keybinds"          # Tema a usar
export ROFI_KEYBIND_HINT_WIDTH="35em"              # Ancho
export ROFI_KEYBIND_HINT_HEIGHT="35em"             # Alto
export ROFI_KEYBIND_HINT_LINE="13"                 # Líneas visibles
export ROFI_KEYBIND_HINT_FONT="JetBrains Mono 12"  # Fuente
export ROFI_KEYBIND_HINT_SCALE="1.0"               # Escala de fuente
```

## Uso

### Ejecutar Directamente
```bash
keybinds-hint
```

### Desde Rofi
```bash
keybinds-hint c    # Modo completo (default)
keybinds-hint d    # Modo dmenu
keybinds-hint j    # Salida JSON
keybinds-hint m    # Salida Markdown
```

### Con Atajo de Teclado
Presiona `Super + /` (o el keybind que configuraste)

## Características

- ✅ Muestra todos los keybinds de Hyprland organizados por categorías
- ✅ Permite buscar y filtrar keybinds
- ✅ Ejecuta keybinds directamente desde el menú
- ✅ Soporta diferentes formatos de salida
- ✅ Caching para mejor rendimiento
- ✅ Temas personalizables
- ✅ Notificaciones de estado

## Troubleshooting

### Si no funciona:
1. **Verificar Hyprland está corriendo:** `hyprctl version`
2. **Verificar dependencias:** `which rofi jq python3 notify-send`
3. **Revisar permisos:** `ls -la ~/.local/lib/hyde/`
4. **Verificar caché:** `ls -la $XDG_RUNTIME_DIR/hyde/`

### Limpiar caché:
```bash
rm -f "$XDG_RUNTIME_DIR/hyde/keybinds_hint.rofi"
```

### Debug:
```bash
# Ejecutar con verbosidad
bash -x ~/.local/lib/hyde/keybinds_hint.sh c
```

## Notas

- El sistema lee keybinds automáticamente de tu configuración de Hyprland
- No requiere HyDE instalado, solo Hyprland
- Compatible con cualquier distribución Linux
- Los temas .rasi son independientes y funcionan solos