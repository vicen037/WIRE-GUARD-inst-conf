#!/bin/bash

# Variables
WG_INTERFACE="wg0"  # Interfaz de WireGuard
WG_PORT="51820"     # Puerto UDP por defecto de WireGuard

# Permitir tráfico en el puerto UDP de WireGuard (51820)
sudo iptables -A INPUT -p udp --dport $WG_PORT -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport $WG_PORT -j ACCEPT

# Permitir tráfico entrante en la interfaz WireGuard
sudo iptables -A INPUT -i $WG_INTERFACE -j ACCEPT
sudo iptables -A OUTPUT -o $WG_INTERFACE -j ACCEPT

# Habilitar el reenvío de IP (para permitir el tráfico entre interfaces)
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configurar NAT para permitir acceso a Internet desde los clientes VPN
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Guardar las reglas para que persistan después de reiniciar
# (En sistemas basados en Debian/Ubuntu, puedes usar iptables-persistent)
sudo apt-get install -y iptables-persistent

# Guardar reglas
sudo netfilter-persistent save

echo "Las reglas de iptables para WireGuard han sido configuradas correctamente."
