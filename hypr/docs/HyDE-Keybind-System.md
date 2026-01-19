# Sistema de Descripciones de Keybindings en HyDE

## ¿Qué es el sistema `$d`?

HyDE utiliza un sistema de variables para organizar y describir los keybindings mediante la variable `$d`. Esto permite crear menús interactivos que muestran descripciones legibles de cada atajo.

## Estructura Básica

### 1. Variables de Grupo
```bash
$wm=Window Management
$l=Launcher
$hc=Hardware Controls
$ut=Utilities
$rice=Theming and Wallpaper
$ws=Workspaces
```

### 2. Definición del Grupo `$d`
```bash
$d=[$wm]                    # Grupo principal
$d=[$wm|Change focus]       # Subgrupo específico
$d=[$l|Rofi menus]          # Grupo con subgrupo
```

### 3. Sintaxis del Keybind
```bash
bindd = $mainMod, Q, $d close focused window, exec, hyde-shell dontkillsteam
```

**Desglose:**
- `bindd` - Tipo de binding de HyDE
- `$mainMod, Q` - Teclas del atajo
- `$d close focused window` - Descripción (grupo + descripción específica)
- `exec, hyde-shell dontkillsteam` - Comando a ejecutar

## Jerarquía de Grupos

### Nivel 1: Grupos Principales
- `$wm` - Window Management
- `$l` - Launcher  
- `$hc` - Hardware Controls
- `$ut` - Utilities
- `$rice` - Theming and Wallpaper
- `$ws` - Workspaces

### Nivel 2: Subgrupos
```bash
$d=[$wm|Change focus]        # Cambio de foco
$d=[$wm|Resize Active Window] # Redimensionar ventanas
$d=[$l|Rofi menus]          # Menús de rofi
$d=[$hc|Audio]              # Controles de audio
```

### Nivel 3: Subgrupos anidados
```bash
$d=[$ws|Navigation|Relative workspace]
$d=[$ws|Navigation|Special workspace]
$d=[$ws|Navigation|Move window silently]
```

## Formatos de Bindings

### `bindd` - Binding estándar
```bash
bindd = $mainMod, D, $d application finder, exec, pkill -x rofi || $rofi-launch d
```

### `bindde` - Binding con efecto de sonar/eco
Para acciones que necesitan feedback visual prolongado
```bash
bindde = $mainMod Shift, Right, $d resize window right, resizeactive, 30 0
```

### `binddl` - Binding largo (long press)
Para acciones que requieren mantener presionada la tecla
```bash
binddl = , F10, $d toggle mute output, exec, hyde-shell volumecontrol -o m
```

### `binddel` - Binding largo con efecto
Combinación de largo + efecto
```bash
binddel = , XF86MonBrightnessUp, $d increase brightness, exec, hyde-shell brightnesscontrol i
```

### `binddm` - Binding con mouse
Para acciones del mouse
```bash
binddm = $mainMod, mouse:272, $d hold to move window, movewindow
```

## Ventajas del Sistema

### 1. **Organización Jerárquica**
- Permite agrupar keybindings por categoría
- Facilita la navegación en menús visuales
- Reduce duplicación de descripciones

### 2. **Descripciones Contextuales**
El grupo se prefija automáticamente a la descripción:
```bash
$d=[$l|Rofi menus]
# Resultado: "Rofi menus - application finder"
bindd = $mainMod, D, $d application finder, exec, pkill -x rofi || $rofi-launch d
```

### 3. **Compatibilidad con GUI**
La variable `$d` puede ser parseada por herramientas gráficas para:
- Menús interactivos de keybindings
- Ayuda visual de atajos
- Documentación automática

### 4. **Facilidad de Mantenimiento**
- Cambiar el nombre de un grupo afecta a todos sus keybindings
- Reordenar categorías es trivial
- Consistencia en nomenclatura

## Ejemplo Práctico: Keybind de Línea 97

```bash
bindd = $mainMod, slash, $d keybindings hint, exec, pkill -x rofi || hyde-shell keybinds_hint c
```

**Desglose completo:**
- **Tipo**: `bindd` (binding estándar)
- **Atajo**: `$mainMod + slash` (Super + /)
- **Grupo actual**: `$d=[$l|Rofi menus]`
- **Descripción final**: "Rofi menus - keybindings hint"
- **Acción**: Ejecuta el menú de ayuda de keybindings

## Implementación en Menús

Cuando se ejecuta `hyde-shell keybinds_hint`, el sistema:
1. Parsea todos los keybindings con descripción `$d`
2. Extrae las descripciones completas (grupo + descripción específica)
3. Muestra un menú rofi con todas las opciones organizadas
4. Permite filtrar y seleccionar keybindings

## Personalización

### Agregar Nuevo Grupo
```bash
$mymod=My Custom Category
$d=[$mymod]
bindd = $mainMod, F1, $d my custom action, exec, my-command
```

### Modificar Grupos Existentes
```bash
# Cambiar nombre de grupo
$wm=Window Control  # Antes: Window Management
```

### Subgrupos Específicos
```bash
$d=[$ut|Screen Capture|Advanced]
bindd = $mainMod Shift Control, P, $d advanced screen capture, exec, advanced-screenshot
```

## Variables Especiales Comunes

```bash
$mainMod = SUPER           # Tecla principal (Super/Windows)
$TERMINAL = kitty         # Terminal por defecto
$EDITOR = code            # Editor por defecto
$EXPLORER = dolphin      # Explorador de archivos
$BROWSER = firefox       # Navegador web
$rofi-launch=hyde-shell rofilaunch  # Comando de lanzamiento genérico
```

## Buenas Prácticas

1. **Nombres descriptivos**: Usar nombres claros para grupos
2. **Jerarquía lógica**: Agrupar por funcionalidad
3. **Consistencia**: Mantener formato en descripciones
4. **Documentación**: Los grupos sirven como auto-documentación

Este sistema hace que los keybindings sean auto-documentados y fácilmente navegables a través de interfaces gráficas.