# Instalación y Configuración de WireGuard en Ubuntu 24.04

## Introducción
WireGuard es una moderna y rápida solución VPN que utiliza criptografía de última generación. En este archivo se detallan los pasos para instalar y configurar un servidor WireGuard en Ubuntu 24.04, así como la configuración de clientes (Windows, Android, iOS).

---

## 1. Instalación de WireGuard en Ubuntu 24.04

1. **Actualizar el sistema:**

   Antes de comenzar con la instalación, asegúrate de que tu sistema está actualizado:

   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. **Instalar WireGuard:**

   Para instalar WireGuard, utiliza el siguiente comando:

   ```bash
   sudo apt install wireguard -y
   ```

3. **Verificar la instalación:**

   Una vez instalado, puedes verificar la versión de WireGuard con:

   ```bash
   wg --version
   ```

---

## 2. Configuración del Servidor WireGuard

1. **Generar las claves del servidor:**

   El servidor necesita una **clave privada** y una **clave pública**. Genera estas claves con los siguientes comandos:

   ```bash
   sudo mkdir /etc/wireguard
   cd /etc/wireguard
   sudo wg genkey | tee server_private.key | wg pubkey > server_public.key
   ```

   Esto creará dos archivos:
   - `server_private.key` (clave privada del servidor)
   - `server_public.key` (clave pública del servidor)

2. **Crear el archivo de configuración del servidor:**

   Crea el archivo `wg0.conf` en `/etc/wireguard/` con el siguiente contenido básico:

   ```bash
   sudo nano /etc/wireguard/wg0.conf
   ```

   Ejemplo de archivo `wg0.conf`:

   ```
   [Interface]
   Address = 10.8.0.1/24
   ListenPort = 51820
   PrivateKey = <clave_privada_del_servidor>

   [Peer]
   PublicKey = <clave_publica_del_cliente>
   AllowedIPs = 10.8.0.2/32
   ```

   Asegúrate de reemplazar `<clave_privada_del_servidor>` y `<clave_publica_del_cliente>` con las claves correspondientes.

3. **Habilitar y arrancar el servicio de WireGuard:**

   Activa el servicio para que WireGuard se inicie automáticamente al arrancar el sistema:

   ```bash
   sudo systemctl enable wg-quick@wg0
   sudo systemctl start wg-quick@wg0
   ```

4. **Abrir el puerto en el firewall:**

   Si tienes un firewall activo, permite el tráfico UDP en el puerto 51820:

   ```bash
   sudo ./automatizacion_firewall.sh
   ```

---

## 3. Configuración del Cliente (Ejemplo: Windows)

1. **Ejecutar archivo de automatizacion para crear claves y configuracion de cada usuario:**

   
   ```bash
   sudo ./crear_claves_user_conf.sh
   ```


4. **Conectar el cliente a la VPN:**

   Importa el archivo de configuración en el cliente (usando la app WireGuard para Windows, Android o iOS) y activa la VPN.

---

## 4. Cómo Manejar el Cambio de IP Pública

Si tu IP pública cambia, puedes usar uno de los siguientes métodos:

1. **Usar DDNS (DNS Dinámico):**

   Utiliza servicios gratuitos como **No-IP** o **DuckDNS** para obtener un subdominio que apunte a tu IP pública, y configura el cliente para usar este nombre en lugar de la IP.

2. **Actualizar manualmente la IP en la configuración del cliente:**

   Si prefieres no usar DDNS, tendrás que actualizar manualmente la IP pública en el archivo de configuración del cliente cada vez que cambie.

---

## 5. Conclusión

WireGuard es una opción potente y rápida para implementar una VPN en Ubuntu 24.04. Siguiendo estos pasos, podrás establecer una conexión segura entre tu servidor y tus clientes. Si no tienes un dominio, puedes recurrir a servicios DDNS gratuitos para facilitar el manejo de cambios en la IP pública.
