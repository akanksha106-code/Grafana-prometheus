#!/bin/bash
set -e

echo "========================================"
echo "Installing Node Exporter 1.8.2"
echo "========================================"

# Download
echo "Downloading Node Exporter..."
cd /tmp/
wget -q --show-progress https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Extract
echo "Extracting archive..."
tar xzf node_exporter-1.8.2.linux-amd64.tar.gz

# Install
echo "Installing Node Exporter..."
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
sudo chown root:root /usr/local/bin/node_exporter

# Create user
echo "Creating node_exporter user..."
sudo useradd -rs /bin/false node_exporter || echo "User already exists"

# Create service
echo "Creating systemd service..."
sudo cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
After=network-online.target
Wants=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)

[Install]
WantedBy=multi-user.target
EOF

# Start service
echo "Starting Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check status
sleep 2
if sudo systemctl is-active --quiet node_exporter; then
    echo ""
    echo "✓ Node Exporter installed successfully!"
    echo "Metrics available at: http://$(curl -s ifconfig.me):9100/metrics"
else
    echo "✗ Node Exporter failed to start. Check logs with: sudo journalctl -u node_exporter -n 50"
    exit 1
fi
