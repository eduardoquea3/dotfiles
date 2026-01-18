#!/usr/bin/env bash

# Script independiente equivalente a "hyde-shell cliphist -c"
# Requiere: cliphist, rofi, wl-clipboard (wl-copy)
# Opcional: libnotify (notify-send) para notificaciones

# Configuración
ROFI_THEME="${ROFI_CLIPHIST_STYLE:-/home/eduardo/.config/hypr/rofi/clipboard.rasi}"
CACHE_DIR="${HOME}/.cache/hyde"

# Asegurar que exista el directorio de caché
mkdir -p "${CACHE_DIR}"

# Función para mostrar historial y copiar selección
show_history_and_copy() {
    # Obtener lista del clipboard con formato mejorado
    local clipboard_list
    if ! clipboard_list=$(cliphist list 2>/dev/null | sed 's/\t/ | /g'); then
        if command -v notify-send &> /dev/null; then
            notify-send "Clipboard Error" "Failed to access clipboard history" -t 3000 --urgency=critical
        fi
        exit 1
    fi
    
    if [[ -z "$clipboard_list" ]]; then
        if command -v notify-send &> /dev/null; then
            notify-send "Clipboard" "No items in clipboard history" -t 2000
        fi
        exit 0
    fi
    
    # Mostrar menú rofi para selección con mejor formato
    local selected_item
    selected_item=$(echo "$clipboard_list" | rofi -dmenu \
        -theme "$ROFI_THEME" \
        -i \
        -no-display-columns \
        -p "📋 Clipboard History")
    
    # Salir si no se seleccionó nada
    [[ -z "$selected_item" ]] && exit 0
    
    # Extraer el ID original del item (antes del |)
    local original_item=$(echo "$selected_item" | sed 's/ |.*//')
    
    # Verificar si es datos binarios (imagen)
    if [[ "$original_item" == *"[[ binary data"* ]] || [[ "$original_item" == *"image"* ]]; then
        # Para imágenes: decodificar directamente al portapapeles
        if echo "$original_item" | cliphist decode | wl-copy 2>/dev/null; then
            if command -v notify-send &> /dev/null; then
                notify-send "Clipboard" "🖼️ Image copied to clipboard" -t 2000
            fi
        else
            # Si falla la decodificación, mostrar error
            if command -v notify-send &> /dev/null; then
                notify-send "Clipboard Error" "Failed to decode image data" -t 3000 --urgency=critical
            fi
            exit 1
        fi
    else
        # Para texto: decodificar y copiar el contenido
        local decoded_content
        if decoded_content=$(echo -e "$original_item\t" | cliphist decode 2>/dev/null); then
            echo -n "$decoded_content" | wl-copy
        else
            if command -v notify-send &> /dev/null; then
                notify-send "Clipboard Error" "Failed to decode text content" -t 3000 --urgency=critical
            fi
            exit 1
        fi
        if command -v notify-send &> /dev/null; then
            local preview=$(echo "$decoded_content" | head -c 50)
            [[ ${#decoded_content} -gt 50 ]] && preview="$preview..."
            notify-send "Clipboard" "📝 Text copied: $preview" -t 2000
        fi
    fi
    
    # Eliminar el item del historial (comportamiento original de hyde-shell)
    echo -e "$original_item\t" | cliphist delete
}

# Función principal
main() {
    # Verificar dependencias obligatorias
    for cmd in cliphist rofi wl-copy; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command '$cmd' not found" >&2
            echo "Please install the missing dependencies and try again." >&2
            exit 1
        fi
    done
    
    # Ejecutar la función principal
    show_history_and_copy
}

# Ejecutar si el script es llamado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi