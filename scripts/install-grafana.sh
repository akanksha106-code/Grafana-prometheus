#!/bin/bash
set -e

echo "========================================"
echo "Installing Grafana"
echo "========================================"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get install -y software-properties-common wget

# Add GPG key
echo "Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add repository
echo "Adding Grafana repository..."
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main" -y

# Update and install
echo "Installing Grafana..."
sudo apt update
sudo apt install grafana -y

# Start service
echo "Starting Grafana..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Check status
sleep 3
if sudo systemctl is-active --quiet grafana-server; then
    echo ""
    echo "✓ Grafana installed successfully!"
    echo "Access at: http://$(curl -s ifconfig.me):3000"
    echo "Default credentials: admin/admin"
else
    echo "✗ Grafana failed to start. Check logs with: sudo journalctl -u grafana-server -n 50"
    exit 1
fi
