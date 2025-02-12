#!/bin/bash

# secure-ssh.sh
# author: luc

# Creates a new SSH user, uses public key, and disables root SSH login.
sudo useradd -m -d /home/${1} -s /bin/bash ${1}
sudo mkdir /home/${1}/.ssh
cd /home/luc/SYS-265-SP25
sudo cp /home/luc/SYS-265-SP25/linux/public-keys/id_rsa.pub /home/${1}/.ssh/authorized_keys
sudo chmod 700 /home/${1}/.ssh
sudo chmod 600 /home/${1}/.ssh/authorized_keys
sudo chown -R ${1}:${1} /home/${1}/.ssh


# Disable root SSH login
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

echo "SSH user $NEW_USER has been created, an RSA key pair has been generated, and root SSH access has been disabled."

