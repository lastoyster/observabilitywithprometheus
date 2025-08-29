#grafana_aws_install.script

#!/bin/bash

# Exit on error
set -e

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root or use sudo"
  exit 1
fi

echo "🔄 Updating system packages..."
sudo yum update -y

############################################
# 1. Grafana Installation
############################################
echo "📦 Installing Grafana..."
sudo yum install -y https://dl.grafana.com/oss/release/grafana-10.2.3-1.x86_64.rpm
sudo systemctl enable --now grafana-server
grafana_version=$(grafana-server -v | head -n 1)
echo "✅ Grafana installed successfully. Version: $grafana_version"

############################################
# 2. Prometheus Installation (manual method)
############################################
echo "📦 Installing Prometheus..."

# Create user & directories
if id "prometheus" &>/dev/null; then
    echo "ℹ️ User 'prometheus' already exists."
else
    sudo useradd --no-create-home --shell /bin/false prometheus
fi

sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Download Prometheus latest release
cd /tmp
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest \
| grep browser_download_url | grep linux-amd64 \
| cut -d '"' -f 4 | wget -qi -

# Extract and install
tar xvf prometheus*.tar.gz
cd prometheus-*/
sudo cp prometheus promtool /usr/local/bin/
sudo cp -r consoles console_libraries /etc/prometheus

# Prometheus configuration
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Systemd service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable --now prometheus
echo "✅ Prometheus installed and running on :9090"

############################################
# 3. Node Exporter Installation
############################################
echo "📦 Installing Node Exporter..."
cd /tmp
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest \
| grep browser_download_url | grep linux-amd64 \
| cut -d '"' -f 4 | wget -qi -

tar xvf node_exporter*.tar.gz
cd node_exporter-*/
sudo cp node_exporter /usr/local/bin/

# Systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable --now node_exporter
echo "✅ Node Exporter installed and running on :9100"

############################################
# Summary
############################################
echo -e "\n🎉 Monitoring stack setup complete!"
echo "➡️ Grafana:    http://<your-ec2-ip>:3000 (login: admin / admin)"
echo "➡️ Prometheus: http://<your-ec2-ip>:9090"
echo "➡️ Node Exporter: http://<your-ec2-ip>:9100"
