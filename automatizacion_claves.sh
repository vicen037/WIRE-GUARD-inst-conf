#!/bin/bash

# Comprobar si se pasó el nombre del usuario
if [ -z "$1" ]; then
  echo "Por favor, proporciona el nombre del usuario como argumento."
  echo "Uso: $0 <nombre_usuario>"
  exit 1
fi

# Nombre del usuario
USER_NAME=$1

# Directorio donde se guardarán las claves (puedes cambiar esta ruta)
KEYS_DIR="/etc/wireguard/keys"

# Crear el directorio si no existe
mkdir -p "$KEYS_DIR"

# Generar clave privada
PRIVATE_KEY=$(wg genkey)

# Generar clave pública a partir de la privada
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)

# Guardar las claves en archivos
echo "$PRIVATE_KEY" > "$KEYS_DIR/$USER_NAME_private.key"
echo "$PUBLIC_KEY" > "$KEYS_DIR/$USER_NAME_public.key"

# Mostrar las rutas de las claves generadas
echo "Clave privada para $USER_NAME guardada en: $KEYS_DIR/$USER_NAME_private.key"
echo "Clave pública para $USER_NAME guardada en: $KEYS_DIR/$USER_NAME_public.key"
