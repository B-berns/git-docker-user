#!/bin/bash
set -e

echo "[+] Creating user 'wazuh'..."

# Create user with home directory and default shell
if id "wazuh" &>/dev/null; then
    echo "User 'wazuh' already exists."
else
    sudo useradd -m -s /bin/bash wazuh
    echo "User 'wazuh' created."
fi

# Add user to sudoers with no password
echo "[+] Granting passwordless sudo..."
echo "wazuh ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/wazuh > /dev/null
sudo chmod 0440 /etc/sudoers.d/wazuh

# Install Git, Docker, Docker Compose
echo "[+] Installing Git, Docker, Docker Compose..."

# Enable Docker repo
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install all packages
sudo dnf install -y git docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
sudo systemctl enable --now docker

# Add wazuh to docker group
echo "[+] Adding 'wazuh' to docker group..."
sudo usermod -aG docker wazuh

echo "[✓] Setup complete."
echo "[i] You can now switch to 'wazuh' user and run docker without sudo:"
echo "    su - wazuh"
echo "    docker run hello-world"
