#!/bin/bash
set -e

INSTALL_DIR="/opt/uu"
SERVICE_NAME="uuplugin-linux"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
API="https://router.uu.163.com/api/plugin?type=steam-deck-plugin-x86_64"

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

echo "[uud] Installing uuplugin to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"

# --- update.sh ---
cat > "$INSTALL_DIR/update.sh" << 'EOF'
#!/bin/bash
INSTALL_DIR="/opt/uu"
API="https://router.uu.163.com/api/plugin?type=steam-deck-plugin-x86_64"

info=$(curl -fsSL "$API") || { echo "[uud] Failed to reach UU API, skipping update."; exit 0; }
remote_md5=$(echo "$info" | jq -r '.md5')
url=$(echo "$info" | jq -r '.url')

local_md5=$(md5sum "$INSTALL_DIR/uuplugin" 2>/dev/null | cut -d' ' -f1)
if [[ "$local_md5" == "$remote_md5" ]]; then
    echo "[uud] Already up to date."
    exit 0
fi

echo "[uud] Updating..."
tmpfile=$(mktemp)
if ! curl -fsSL "$url" -o "$tmpfile"; then
    echo "[uud] Download failed, skipping update."
    rm -f "$tmpfile"
    exit 0
fi

dl_md5=$(md5sum "$tmpfile" | cut -d' ' -f1)
if [[ "$dl_md5" != "$remote_md5" ]]; then
    echo "[uud] MD5 mismatch, skipping update."
    rm -f "$tmpfile"
    exit 0
fi

tar zxf "$tmpfile" -C "$INSTALL_DIR" uuplugin
chmod +x "$INSTALL_DIR/uuplugin"
rm -f "$tmpfile"
echo "[uud] Update complete."
EOF
chmod +x "$INSTALL_DIR/update.sh"

# --- initial binary ---
echo "[uud] Downloading uuplugin..."
"$INSTALL_DIR/update.sh"

if [[ ! -x "$INSTALL_DIR/uuplugin" ]]; then
    echo "Failed to download uuplugin. Aborting."
    exit 1
fi

# --- uu.conf ---
if [[ ! -f "$INSTALL_DIR/uu.conf" ]]; then
    echo "log_level=info" > "$INSTALL_DIR/uu.conf"
fi

echo "[uud] Registering systemd service $SERVICE_NAME..."

# --- systemd service ---
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=UU Accelerator
Wants=network-online.target
After=network.target network-online.target

[Service]
ExecStartPre=$INSTALL_DIR/update.sh
ExecStart=$INSTALL_DIR/uuplugin $INSTALL_DIR/uu.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

echo "[uud] Installation complete. Service $SERVICE_NAME is running."
echo "[uud] To update manually: sudo $INSTALL_DIR/update.sh"
echo "[uud] To uninstall: curl -sSL https://raw.githubusercontent.com/zhhc99/uud/main/uninstall.sh | sudo bash"
