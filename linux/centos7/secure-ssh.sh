#!/bin/bash

# secure-ssh.sh
# author: luc
# creates a new ssh user using $1 parameter
# adds a public key from the local repo or curled from the remote repo
# removes root's ability to ssh in

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Check if username is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

NEW_USER="$1"
SSH_DIR="/home/$NEW_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
LOCAL_KEY="/path/to/local/public_key.pub"
REMOTE_KEY_URL="https://example.com/public_keys/$NEW_USER.pub"

# Create new user
useradd -m -s /bin/bash "$NEW_USER"

# Create .ssh directory
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$NEW_USER:$NEW_USER" "$SSH_DIR"

# Add public key
if [ -f "$LOCAL_KEY" ]; then
    cat "$LOCAL_KEY" >> "$AUTHORIZED_KEYS"
else
    curl -s "$REMOTE_KEY_URL" >> "$AUTHORIZED_KEYS"
fi

chmod 600 "$AUTHORIZED_KEYS"
chown "$NEW_USER:$NEW_USER" "$AUTHORIZED_KEYS"

# Disable root SSH login
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

echo "SSH user $NEW_USER has been created and root SSH access has been disabled."

