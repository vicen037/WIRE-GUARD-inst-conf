#!/bin/bash

# Comprobaciones iniciales
function check_argument {
  if [ -z "$1" ]; then
    echo "Por favor, proporciona el nombre del usuario como argumento."
    echo "Uso: $0 <nombre_usuario>"
    exit 1
  fi
}

# Verificar si una IP está en uso
function is_ip_in_use {
  ping -c 1 -W 1 "$1" > /dev/null 2>&1
  return $?
}

# Generar claves privadas y públicas para el cliente
function generate_keys {
  local private_key=$(wg genkey)
  local public_key=$(echo "$private_key" | wg pubkey)
  
  echo "$private_key" "$public_key"
}

# Crear el archivo de configuración para el cliente
function create_client_config {
  local private_key=$1
  local public_key=$2
  local server_public_key=$3
  local server_ip=$4
  local server_port=$5
  local client_ip=$6
  local user_name=$7
  local config_dir=$8
  
  # Crear archivo de configuración del cliente
  local client_conf="$config_dir/$user_name.conf"
  echo "[Interface]" > "$client_conf"
  echo "PrivateKey = $private_key" >> "$client_conf"
  echo "Address = $client_ip" >> "$client_conf"
  echo "DNS = 8.8.8.8" >> "$client_conf"  # DNS opcional

  echo "[Peer]" >> "$client_conf"
  echo "PublicKey = $server_public_key" >> "$client_conf"
  echo "Endpoint = $server_ip:$server_port" >> "$client_conf"
  echo "AllowedIPs = 0.0.0.0/0" >> "$client_conf"  # Permitir todo el tráfico
  echo "PersistentKeepalive = 25" >> "$client_conf"

  echo "Archivo de configuración para $user_name creado en: $client_conf"
}

# Guardar la nueva IP utilizada en el archivo de control
function save_ip_counter {
  local ip_counter_file=$1
  local next_ip=$2
  echo $next_ip > "$ip_counter_file"
}

# Leer el contador de IP desde el archivo, o inicializar si no existe
function get_next_ip {
  local ip_counter_file=$1
  if [ -f "$ip_counter_file" ]; then
    cat "$ip_counter_file"
  else
    echo 2  # Empezamos desde 2 para evitar la IP 10.8.0.1 (del servidor)
  fi
}

# Variables de configuración
USER_NAME=$1
KEYS_DIR="/etc/wireguard/keys"
CONFIG_DIR="/etc/wireguard/clients"
IP_COUNTER_FILE="/etc/wireguard/next_ip.txt"
VPN_BASE_IP="10.8.0"  # Red de la VPN
VPN_SUBNET="/24"  # Subnet para la VPN
SERVER_IP="203.0.113.1"  # IP pública del servidor
SERVER_PORT="51820"  # Puerto por defecto del servidor

# Verificamos si el nombre de usuario fue proporcionado
check_argument "$USER_NAME"

# Crear directorios si no existen
mkdir -p "$KEYS_DIR"
mkdir -p "$CONFIG_DIR"

# Obtener la siguiente IP disponible para el cliente
NEXT_IP=$(get_next_ip "$IP_COUNTER_FILE")

# Comprobar si la IP está en uso y asignar una nueva IP si es necesario
while is_ip_in_use "$VPN_BASE_IP.$NEXT_IP"; do
  NEXT_IP=$((NEXT_IP + 1))  # Incrementamos la IP si la actual está en uso
done

CLIENT_IP="$VPN_BASE_IP.$NEXT_IP$VPN_SUBNET"

# Generar claves para el cliente
keys=$(generate_keys)
PRIVATE_KEY=$(echo "$keys" | awk '{print $1}')
PUBLIC_KEY=$(echo "$keys" | awk '{print $2}')

# Obtener la clave pública del servidor
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

# Crear el archivo de configuración para el cliente
create_client_config "$PRIVATE_KEY" "$PUBLIC_KEY" "$SERVER_PUBLIC_KEY" "$SERVER_IP" "$SERVER_PORT" "$CLIENT_IP" "$USER_NAME" "$CONFIG_DIR"

# Incrementar NEXT_IP para el siguiente cliente
NEXT_IP=$((NEXT_IP + 1))

# Guardar el nuevo valor de NEXT_IP para la próxima ejecución
save_ip_counter "$IP_COUNTER_FILE" "$NEXT_IP"

# Guardar las claves generadas en el directorio correspondiente
echo "$PRIVATE_KEY" > "$KEYS_DIR/$USER_NAME_private.key"
echo "$PUBLIC_KEY" > "$KEYS_DIR/$USER_NAME_public.key"

echo "Claves para $USER_NAME guardadas en: $KEYS_DIR/$USER_NAME_private.key y $KEYS_DIR/$USER_NAME_public.key"
