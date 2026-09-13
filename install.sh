#!/bin/bash

set -e

GROUP="tunnelusers"
SSHD_CONFIG="/etc/ssh/sshd_config"
INSTALL_PATH="/usr/local/bin/tunnel-manager"

echo "================================="
echo " SSH Tunnel Manager Installer"
echo "================================="
echo ""

# Check root
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run this installer as root."
    exit 1
fi

# Check operating system
if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot detect operating system."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
    echo "Error: This installer currently supports Ubuntu only."
    exit 1
fi

echo "OS: $PRETTY_NAME"

# Check OpenSSH
if ! command -v sshd >/dev/null 2>&1; then
    echo "Error: OpenSSH server is not installed."
    exit 1
fi

echo "OpenSSH: OK"

# Check SSH config
if [[ ! -f "$SSHD_CONFIG" ]]; then
    echo "Error: $SSHD_CONFIG not found."
    exit 1
fi

# Create group if needed
if ! getent group "$GROUP" >/dev/null 2>&1; then
    echo "Creating group: $GROUP"
    groupadd "$GROUP"
else
    echo "Group already exists: $GROUP"
fi

# Backup SSH configuration
BACKUP_FILE="${SSHD_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"

echo "Creating SSH configuration backup..."
cp "$SSHD_CONFIG" "$BACKUP_FILE"

echo "Backup created:"
echo "$BACKUP_FILE"

# Install tunnel-manager
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/tunnel-manager"

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
    echo "Error: tunnel-manager not found."
    echo "Expected location:"
    echo "$SOURCE_SCRIPT"
    exit 1
fi

echo "Installing tunnel-manager..."

cp "$SOURCE_SCRIPT" "$INSTALL_PATH"
chmod 755 "$INSTALL_PATH"

echo "Installed to:"
echo "$INSTALL_PATH"

# Ensure SSH ports
if ! grep -Eq '^[[:space:]]*Port[[:space:]]+22([[:space:]]|$)' "$SSHD_CONFIG"; then
    echo "Adding SSH port 22..."
    sed -i '1iPort 22' "$SSHD_CONFIG"
else
    echo "SSH port 22 already configured."
fi

if ! grep -Eq '^[[:space:]]*Port[[:space:]]+443([[:space:]]|$)' "$SSHD_CONFIG"; then
    echo "Adding SSH port 443..."
    sed -i '1iPort 443' "$SSHD_CONFIG"
else
    echo "SSH port 443 already configured."
fi

# Add tunnelusers SSH rule if it does not already exist
if ! grep -Eq '^[[:space:]]*Match[[:space:]]+Group[[:space:]]+'"$GROUP"'[[:space:]]*$' "$SSHD_CONFIG"; then

    echo "Adding SSH rules for group: $GROUP"

    cat >> "$SSHD_CONFIG" <<EOF

# BEGIN SSH-TUNNEL-MANAGER
Match Group $GROUP
    PasswordAuthentication yes
    PermitTTY no
    AllowTcpForwarding yes
    X11Forwarding no
    PermitTunnel no
# END SSH-TUNNEL-MANAGER
EOF

else
    echo "SSH rule for group $GROUP already exists."
fi

# Validate SSH configuration
echo ""
echo "Validating SSH configuration..."

if sshd -t; then
    echo "SSH configuration: OK"
else
    echo ""
    echo "ERROR: SSH configuration validation failed."
    echo ""
    echo "Restoring backup..."

    cp "$BACKUP_FILE" "$SSHD_CONFIG"

    echo "SSH configuration restored."
    exit 1
fi

# Reload SSH
echo ""
echo "Reloading SSH service..."

if systemctl reload ssh; then
    echo "SSH service reloaded successfully."
else
    echo ""
    echo "ERROR: Failed to reload SSH service."
    echo "The SSH configuration was valid, but reload failed."
    exit 1
fi

echo ""
echo "================================="
echo " Installation completed!"
echo "================================="
echo ""
echo "SSH ports:"
echo "  22"
echo "  443"
echo ""
echo "Tunnel group:"
echo "  $GROUP"
echo ""
echo "Manager:"
echo "  $INSTALL_PATH"
echo ""
echo "Backup:"
echo "  $BACKUP_FILE"
echo ""