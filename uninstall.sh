#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

echo "[uud] Stopping service, this may take a moment..."
systemctl disable --now uuplugin-linux || true
rm -f /etc/systemd/system/uuplugin-linux.service
systemctl daemon-reload
rm -rf /opt/uu

echo "[uud] Uninstalled."
