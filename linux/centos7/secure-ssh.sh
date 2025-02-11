#!/bin/bash

# secure-ssh.sh
# author: luc
# Creates a new SSH user, generates an RSA key pair, and disables root SSH login.

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Check if a username is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

NEW_USER="$1"
SSH_DIR="/home/$NEW_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Create the new user and their .ssh directory
useradd -m -s /bin/bash "$NEW_USER"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$NEW_USER:$NEW_USER" "$SSH_DIR"

# Generate an RSA key pair
su - "$NEW_USER" -c "ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ''"

# Add the public key to authorized_keys
cat "$SSH_DIR/id_rsa.pub" > "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown "$NEW_USER:$NEW_USER" "$AUTHORIZED_KEYS"

# Disable root SSH login
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

echo "SSH user $NEW_USER has been created, an RSA key pair has been generated, and root SSH access has been disabled."

