#!/bin/bash

# Comprobar si se pasó el nombre del usuario
if [ -z "$1" ]; then
  echo "Por favor, proporciona el nombre del usuario como argumento."
  echo "Uso: $0 <nombre_usuario>"
  exit 1
fi

# Nombre del usuario
USER_NAME=$1

# Directorio donde se guardarán las claves y archivos de configuración (puedes cambiar esta ruta)
KEYS_DIR="/etc/wireguard/keys"
CONFIG_DIR="/etc/wireguard/clients"

# Dirección IP que se asignará al cliente (puedes personalizar esto)
CLIENT_IP="10.8.0.0"  # Ajusta esto según tu rango de red
DNS="8.8.8.8"  # Opcional, servidor DNS

# Crear los directorios si no existen
mkdir -p "$KEYS_DIR"
mkdir -p "$CONFIG_DIR"

# Generar clave privada
PRIVATE_KEY=$(wg genkey)

# Generar clave pública a partir de la clave privada
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)

# Guardar las claves en archivos
echo "$PRIVATE_KEY" > "$KEYS_DIR/$USER_NAME_private.key"
echo "$PUBLIC_KEY" > "$KEYS_DIR/$USER_NAME_public.key"

# Mostrar las rutas de las claves generadas
echo "Clave privada para $USER_NAME guardada en: $KEYS_DIR/$USER_NAME_private.key"
echo "Clave pública para $USER_NAME guardada en: $KEYS_DIR/$USER_NAME_public.key"

# Dirección IP asignada al cliente
CLIENT_ADDRESS="$CLIENT_IP/24"

# Crear el archivo de configuración para el cliente
CLIENT_CONF="$CONFIG_DIR/$USER_NAME.conf"
echo "[Interface]" > "$CLIENT_CONF"
echo "PrivateKey = $PRIVATE_KEY" >> "$CLIENT_CONF"
echo "Address = $CLIENT_ADDRESS" >> "$CLIENT_CONF"
echo "DNS = $DNS" >> "$CLIENT_CONF"  # Puedes quitar esta línea si no la necesitas

# Información del servidor
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)  # Asegúrate de tener la clave pública del servidor guardada
SERVER_IP="203.0.113.1"  # Sustituye con la IP pública de tu servidor
SERVER_PORT="51820"  # Puerto por defecto, cambia si usas otro

echo "[Peer]" >> "$CLIENT_CONF"
echo "PublicKey = $SERVER_PUBLIC_KEY" >> "$CLIENT_CONF"
echo "Endpoint = $SERVER_IP:$SERVER_PORT" >> "$CLIENT_CONF"
echo "AllowedIPs = 0.0.0.0/0" >> "$CLIENT_CONF"  # Permitir todo el tráfico
echo "PersistentKeepalive = 25" >> "$CLIENT_CONF"  # Mantener la conexión activa

# Mostrar mensaje de éxito
echo "Archivo de configuración para $USER_NAME creado en: $CLIENT_CONF"
