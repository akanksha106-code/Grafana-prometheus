#!/bin/bash
set -e

echo "========================================"
echo "Installing Prometheus 3.5.0"
echo "========================================"

# Create user
echo "Creating Prometheus user..."
sudo useradd --no-create-home --shell /bin/false prometheus || echo "User already exists"

# Create directories
echo "Creating directories..."
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus..."
cd /tmp/
wget -q --show-progress https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz

# Extract
echo "Extracting archive..."
tar -xzf prometheus-3.5.0.linux-amd64.tar.gz
cd prometheus-3.5.0.linux-amd64

# Move files
echo "Installing files..."
sudo mv console* /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus

sudo mv prometheus promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Create service
echo "Creating systemd service..."
sudo cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus Monitoring System
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=:9090 \
    --storage.tsdb.retention.time=15d

[Install]
WantedBy=multi-user.target
EOF

# Start service
echo "Starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check status
sleep 2
if sudo systemctl is-active --quiet prometheus; then
    echo ""
    echo "✓ Prometheus installed successfully!"
    echo "Access at: http://$(curl -s ifconfig.me):9090"
else
    echo "✗ Prometheus failed to start. Check logs with: sudo journalctl -u prometheus -n 50"
    exit 1
fi
