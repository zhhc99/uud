#!/bin/bash
set -e

SERVICE_NAME="uud"

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

echo "[uud] Stopping service. DO NOT interrupt because this may take a moment..."
systemctl disable --now "$SERVICE_NAME" || true
rm -f /etc/systemd/system/${SERVICE_NAME}.service
systemctl daemon-reload
rm -rf /opt/uu

echo "[uud] Uninstalled."
