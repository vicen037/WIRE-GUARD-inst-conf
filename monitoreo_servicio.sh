#!/bin/bash

# Comprobar si el servicio WireGuard está activo
if ! systemctl is-active --quiet wg-quick@wg0; then
    echo "WireGuard no está activo. Reiniciando..."
    sudo systemctl restart wg-quick@wg0
else
    echo "WireGuard está funcionando correctamente."
fi
