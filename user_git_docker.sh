#!/bin/bash
set -e

echo "[1/7] Creating user 'wazuh'..."
if id "wazuh" &>/dev/null; then
    echo "User 'wazuh' already exists."
else
    sudo useradd -m -s /bin/bash wazuh
    echo "User 'wazuh' created."
fi

echo "[2/7] Granting passwordless sudo to 'wazuh'..."
echo "wazuh ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/wazuh > /dev/null
sudo chmod 0440 /etc/sudoers.d/wazuh

echo "[3/7] Adding 'wazuh' to docker group..."
sudo usermod -aG docker wazuh

echo "[4/7] Setting vm.max_map_count to 262144..."
sudo sysctl -w vm.max_map_count=262144
if ! grep -q "^vm.max_map_count" /etc/sysctl.conf; then
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
else
    sudo sed -i 's/^vm.max_map_count.*/vm.max_map_count=262144/' /etc/sysctl.conf
fi
echo "✓ max_map_count set permanently in /etc/sysctl.conf"

echo "[5/7] Installing Git, Docker, and Docker Compose..."

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install -y git docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[6/7] Enabling and starting Docker..."
sudo systemctl enable --now docker

echo "[7/7] Cloning wazuh-docker repo as 'wazuh'..."
sudo -u wazuh -i bash << 'EOF'
cd ~
git clone https://github.com/wazuh/wazuh-docker.git -b v4.12.0
EOF

echo -e "\n[✓] All done!"
echo "Log in as 'wazuh' with: su - wazuh"
echo "Verify Docker works without sudo: docker run hello-world"
echo "Verify max_map_count: sysctl vm.max_map_count"
