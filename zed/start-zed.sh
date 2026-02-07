#!/bin/bash
# Script para iniciar Zed con variables de entorno cargadas
# Guarda tus tokens en ~/.secrets/zed.env (chmod 600)

# Cargar secrets si existen
if [ -f "$HOME/.secrets/zed.env" ]; then
    source "$HOME/.secrets/zed.env"
fi

# Iniciar Zed
zed "$@"
