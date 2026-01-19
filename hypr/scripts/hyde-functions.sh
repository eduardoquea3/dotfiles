#!/usr/bin/env bash

# Versión simplificada de funciones necesarias para keybinds_hint
# Extraído del sistema HyDE

# Función para leer configuración de Hyprland
get_hyprConf() {
    local key="$1"
    local default="$2"
    local file="${3:-$HOME/.config/hypr/hyprland.conf}"
    
    if [[ -f "$file" ]]; then
        local value
        value=$(grep "^$key=" "$file" 2>/dev/null | cut -d'=' -f2- | tr -d ' ')
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# Función para enviar notificaciones
send_notifs() {
    local title="$1"
    local message="$2"
    
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message" -t 3000 2>/dev/null
    fi
}

# Función para crear directorios necesarios
ensure_dirs() {
    local dirs=(
        "$XDG_RUNTIME_DIR/hyde"
        "$HOME/.local/share/hyde/rofi/themes"
        "$HOME/.cache/hyde"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done
}

# Función para verificar dependencias
check_deps() {
    local missing=()
    local deps=("hyprctl" "rofi" "jq" "python3")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "❌ Faltan dependencias: ${missing[*]}"
        echo "Instálalas con tu gestor de paquetes"
        return 1
    fi
    
    return 0
}

# Función para obtener el keybind principal
get_main_mod() {
    get_hyprConf "$mainMod" "SUPER"
}

# Variables por defecto
export mainMod="SUPER"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Ejecutar verificación si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Verificando dependencias..."
    if check_deps; then
        echo "✅ Todas las dependencias están instaladas"
        echo "✅ Keybind principal: $(get_main_mod)"
    else
        exit 1
    fi
fi