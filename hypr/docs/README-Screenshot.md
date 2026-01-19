# Kit de Screenshot para Sistemas sin HyDE

Este paquete contiene todo lo necesario para capturar screenshots con anotaciones en Wayland/Hyprland, compatible con el keybind `Super + P`.

## Archivos Incluidos

### Scripts Principales
- `screenshot.sh` - Script principal de captura de pantalla
- `grimblast` - Motor de captura modificado para HyDE
- `hyde-functions.sh` - Funciones auxiliares

### Scripts Adicionales (ya incluidos)
- `cliphist-copy.sh` - Script para clipboard (necesario para copiar screenshots)

## Instalación

### 1. Copiar Archivos
```bash
# Crear estructura de directorios
mkdir -p ~/.local/lib/hyde
mkdir -p ~/.local/lib/hyde/screenshot
mkdir -p ~/.local/bin

# Copiar scripts
cp screenshot.sh ~/.local/lib/hyde/
cp grimblast ~/.local/lib/hyde/screenshot/
cp hyde-functions.sh ~/.local/lib/hyde/
cp cliphist-copy.sh ~/.local/lib/hyde/  # Opcional, para copiar screenshots

# Hacer scripts ejecutables
chmod +x ~/.local/lib/hyde/screenshot.sh
chmod +x ~/.local/lib/hyde/screenshot/grimblast
chmod +x ~/.local/lib/hyde/hyde-functions.sh
chmod +x ~/.local/lib/hyde/cliphist-copy.sh
```

### 2. Instalar Dependencias

#### Arch Linux / Manjaro
```bash
sudo pacman -S grim slurp satty wl-clipboard jq libnotify
# Opcional para OCR y QR:
sudo pacman -S tesseract tesseract-data-eng zbar
```

#### Debian / Ubuntu
```bash
sudo apt install grim slurp satty wl-clipboard jq libnotify-bin
# Opcional para OCR y QR:
sudo apt install tesseract-ocr tesseract-ocr-eng zbar-tools
```

#### Fedora
```bash
sudo dnf install grim slurp satty wl-clipboard jq libnotify
# Opcional para OCR y QR:
sudo dnf install tesseract tesseract-langpack-eng zbar
```

#### openSUSE
```bash
sudo zypper install grim slurp satty wl-clipboard jq libnotify
# Opcional para OCR y QR:
sudo zypper install tesseract tesseract-ocr-traineddata-eng zbar
```

### 3. Crear Script de Acceso
```bash
cat > ~/.local/bin/screenshot-tool << 'EOF'
#!/usr/bin/env bash

# Configuración
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"

# Cargar funciones auxiliares
if [[ -f "$HOME/.local/lib/hyde/hyde-functions.sh" ]]; then
    source "$HOME/.local/lib/hyde/hyde-functions.sh"
fi

# Directorios
SCREENSHOT_DIR="$XDG_PICTURES_DIR/Screenshots"
SCRIPT_DIR="$HOME/.local/lib/hyde"
GRIMBLAST_DIR="$SCRIPT_DIR/screenshot"

# Crear directorio de screenshots
mkdir -p "$SCREENSHOT_DIR"

# Función de notificación
send_notifs() {
    if command -v notify-send &> /dev/null; then
        notify-send "$1" "$2" -t 3000
    fi
}

# Verificar dependencias
check_deps() {
    local missing=()
    local deps=("grim" "slurp" "wl-copy")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        send_notifs "Error" "Faltan dependencias: ${missing[*]}"
        exit 1
    fi
}

# Ejecutar script principal
if [[ -f "$SCRIPT_DIR/screenshot.sh" ]]; then
    check_deps
    bash "$SCRIPT_DIR/screenshot.sh" "$@"
else
    send_notifs "Error" "screenshot.sh not found"
    exit 1
fi
EOF

chmod +x ~/.local/bin/screenshot-tool
```

### 4. Configurar Keybinds en Hyprland
Agregar a tu `hyprland.conf` o `keybindings.conf`:

```bash
# Screenshots
bind = SUPER, P, exec, screenshot-tool s        # Select area
bind = SUPER CONTROL, P, exec, screenshot-tool sf # Select area (frozen)
bind = SUPER ALT, P, exec, screenshot-tool m    # Current monitor
bind = , Print, exec, screenshot-tool p         # All monitors
bind = SUPER SHIFT, P, exec, hyprpicker -an     # Color picker
```

## Uso

### Modos Disponibles

#### `s` - Select Area (default)
```bash
screenshot-tool s
# Selecciona área con el cursor, permite anotar, guarda en ~/Pictures/Screenshots
```

#### `sf` - Select Area (Frozen)
```bash
screenshot-tool sf
# Congela pantalla, selecciona área, permite anotar
```

#### `m` - Monitor
```bash
screenshot-tool m
# Captura monitor activo
```

#### `p` - Print All
```bash
screenshot-tool p
# Captura todos los monitores
```

#### `sc` - OCR
```bash
screenshot-tool sc
# Selecciona área, extrae texto con Tesseract
```

#### `sq` - QR Code
```bash
screenshot-tool sq
# Selecciona área, detecta y extrae QR codes
```

### Variables de Entorno Opcionales

```bash
# Herramienta de anotación (satty o swappy)
export SCREENSHOT_ANNOTATION_TOOL="satty"

# Argumentos adicionales para anotación
export SCREENSHOT_ANNOTATION_ARGS="--filename - --copy-stdout"

# Habilitar/deshabilitar anotación
export SCREENSHOT_ANNOTATION_ENABLED="true"

# Idiomas para OCR
export SCREENSHOT_OCR_TESSERACT_LANGUAGES="eng"

# Editor de imágenes para modo edit
export GRIMBLAST_EDITOR="gimp"
```

## Características

### Captura
- ✅ Selección de área con `slurp`
- ✅ Captura de monitor activo
- ✅ Captura de todos los monitores
- ✅ Modo congelado para selecciones dinámicas

### Anotación
- ✅ Integración con `satty` (herramienta de anotación moderna)
- ✅ Soporte para `swappy` (alternativa)
- ✅ Copia automática al clipboard
- ✅ Guardado automático con timestamp

### Funciones Avanzadas
- ✅ OCR con Tesseract
- ✅ Detección de QR codes con Zbar
- ✅ Integración con Hyprland
- ✅ Notificaciones desktop

## Configuración de Directorios

### Directorio de Guardado
Por defecto: `~/Pictures/Screenshots`

Formato de nombre: `YYMMDD_HHhMMmSSs_screenshot.png`

### Cambiar Directorio
```bash
export XDG_PICTURES_DIR="$HOME/Imágenes"
# O crear enlace simbólico:
ln -s ~/Imágenes ~/Pictures
```

## Troubleshooting

### Si no funciona la captura:
1. **Verificar Wayland:** `echo $XDG_SESSION_TYPE`
2. **Verificar Hyprland:** `hyprctl version`
3. **Verificar dependencias:** `which grim slurp wl-copy`
4. **Revisar permisos:** `ls -la ~/.local/lib/hyde/`

### Si no funciona la anotación:
1. **Verificar satty:** `which satty`
2. **Verificar swappy:** `which swappy`
3. **Probar sin anotación:**
   ```bash
   SCREENSHOT_ANNOTATION_ENABLED=false screenshot-tool s
   ```

### Si no se guarda en Pictures:
```bash
# Crear directorio manualmente
mkdir -p ~/Pictures/Screenshots

# O establecer variable
export XDG_PICTURES_DIR="$HOME/Pictures"
```

### Debug
```bash
# Ejecutar con verbosidad
bash -x ~/.local/lib/hyde/screenshot.sh s

# Ver logs de satty
satty --help
```

## Notas

- Diseñado específicamente para Wayland + Hyprland
- No funciona en X11 (usa `flameshot` o `scrot` en su lugar)
- Requiere soporte de clipboard Wayland (`wl-clipboard`)
- Compatible con cualquier distribución Linux
- Los archivos son independientes y no requieren HyDE instalado

## Alternativas

Si no tienes `satty`:
```bash
# Usar swappy
export SCREENSHOT_ANNOTATION_TOOL="swappy"
sudo apt install swappy  # Debian/Ubuntu
sudo pacman -S swappy    # Arch
```

Si no quieres anotaciones:
```bash
export SCREENSHOT_ANNOTATION_ENABLED="false"
```