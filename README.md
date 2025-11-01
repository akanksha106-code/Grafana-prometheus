# 📊 Jenkins Monitoring with Prometheus & Grafana

<div align="center">

![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Visualization](https://img.shields.io/badge/Visualization-Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI/CD-Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)

**Real-time monitoring solution for Jenkins CI/CD infrastructure**

[Documentation](docs/) • [Installation Guide](docs/INSTALLATION.md) • [Architecture](docs/ARCHITECTURE.md)

</div>

---

## 🎯 Project Overview

A comprehensive, production-ready monitoring solution for Jenkins CI/CD infrastructure using Prometheus for metrics collection and Grafana for visualization, deployed on AWS EC2 instances.

### ✨ Key Features

- ⚡ **Real-time Monitoring**: CPU and memory tracking with 5-second granularity
- 📊 **Custom Dashboards**: Purpose-built Grafana visualizations using PromQL
- 🔄 **Automated Collection**: Continuous metrics gathering from Jenkins and system resources
- 📈 **Historical Analysis**: Time-series data for capacity planning and optimization
- ☁️ **Cloud-Native**: Scalable architecture on AWS infrastructure
- 🛡️ **Production-Ready**: Systemd service management and automated startup

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Monitoring Server (EC2)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Prometheus  │◄─┤ Node Exporter│  │   Grafana    │     │
│  │   :9090      │  │    :9100     │  │    :3000     │     │
│  └──────┬───────┘  └──────────────┘  └──────┬───────┘     │
└─────────┼─────────────────────────────────────┼─────────────┘
          │                                     │
          │ Scrapes Metrics (15s interval)     │ Visualizes Data
          │                                     │
┌─────────▼─────────────────────────────────────▼─────────────┐
│                  Jenkins Build Server (EC2)                  │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │   Jenkins    │  │ Node Exporter│                        │
│  │   :8080      │  │    :9100     │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### 🛠️ Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **Prometheus** | 3.5.0 | Time-series metrics collection and storage |
| **Grafana** | Latest | Data visualization and dashboard platform |
| **Node Exporter** | 1.8.2 | System-level metrics exporter |
| **Jenkins** | Latest | CI/CD build automation server |
| **AWS EC2** | t2.medium | Cloud compute infrastructure (2 vCPU, 4GB RAM) |
| **Ubuntu** | 22.04 LTS | Operating system |

---

## 🚀 Quick Start

### Prerequisites

- ✅ 2x AWS EC2 instances (t2.medium, 4GB RAM recommended)
- ✅ Ubuntu 22.04 LTS
- ✅ Security groups configured for required ports
- ✅ SSH access to instances
- ✅ Basic understanding of Linux commands

### 🔧 Installation

#### 1️⃣ Clone Repository

```bash
git clone https://github.com/akanksha106-code/Grafana-prometheus.git
cd Grafana-prometheus
```

#### 2️⃣ Install Prometheus (Monitoring Server)

```bash
chmod +x scripts/install-prometheus.sh
./scripts/install-prometheus.sh
```

**Access**: `http://<monitoring-server-ip>:9090`

#### 3️⃣ Install Node Exporter (Both Servers)

```bash
chmod +x scripts/install-node-exporter.sh
./scripts/install-node-exporter.sh
```

**Metrics Endpoint**: `http://<server-ip>:9100/metrics`

#### 4️⃣ Install Jenkins (Jenkins Server)

```bash
# Install Java Runtime
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Add Jenkins Repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Access**: `http://<jenkins-server-ip>:8080`

#### 5️⃣ Configure Prometheus

```bash
# Copy configuration
sudo cp configs/prometheus/prometheus.yml /etc/prometheus/

# Edit with your server IPs
sudo nano /etc/prometheus/prometheus.yml

# Replace <JENKINS_PRIVATE_IP> with actual IP

# Restart Prometheus
sudo systemctl restart prometheus
```

#### 6️⃣ Install Grafana (Monitoring Server)

```bash
chmod +x scripts/install-grafana.sh
./scripts/install-grafana.sh
```

**Access**: `http://<monitoring-server-ip>:3000`  
**Default Credentials**: `admin` / `admin` (change on first login)

#### 7️⃣ Configure Grafana

1. **Add Prometheus Data Source**:
   - Navigate to: Configuration → Data Sources → Add data source
   - Select: Prometheus
   - URL: `http://localhost:9090`
   - Click: Save & Test

2. **Import Pre-built Dashboards**:
   - Dashboard → Import → Enter ID `1860` (Node Exporter Full)
   - Dashboard → Import → Enter ID `9964` (Jenkins Performance)

3. **Create Custom CPU/Memory Dashboard** (see below)

---

## 📊 Custom Dashboard Configuration

### CPU Utilization Panel

**PromQL Query**:
```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle",instance=~".*jenkins.*"}[5m])) * 100)
```

**Configuration**:
- Visualization: Time Series
- Unit: Percent (0-100)
- Refresh: 5s
- Title: "Jenkins Server CPU Usage (%)"

### Memory Utilization Panel

**PromQL Query**:
```promql
100 * (1 - ((node_memory_MemAvailable_bytes{instance=~".*jenkins.*"}) / node_memory_MemTotal_bytes{instance=~".*jenkins.*"}))
```

**Configuration**:
- Visualization: Time Series / Gauge
- Unit: Percent (0-100)
- Refresh: 5s
- Title: "Jenkins Server Memory Usage (%)"

---

## 📁 Project Structure

```
Grafana-prometheus/
├── README.md                          # Project documentation
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
├── docs/
│   ├── INSTALLATION.md               # Detailed setup guide
│   ├── ARCHITECTURE.md               # System design document
│   ├── TROUBLESHOOTING.md            # Common issues & solutions
│   └── QUERIES.md                    # PromQL query examples
├── configs/
│   ├── prometheus/
│   │   └── prometheus.yml            # Prometheus configuration
│   ├── systemd/
│   │   ├── prometheus.service        # Prometheus service file
│   │   └── node_exporter.service     # Node Exporter service
│   └── grafana/
│       └── dashboard.json            # Exported dashboard JSON
├── scripts/
│   ├── install-prometheus.sh         # Prometheus setup script
│   ├── install-node-exporter.sh      # Node Exporter setup
│   ├── install-grafana.sh            # Grafana setup script
│   └── configure-all.sh              # One-click setup (all-in-one)
└── screenshots/
    ├── architecture.png              # System architecture diagram
    ├── prometheus-targets.png        # Prometheus targets view
    ├── grafana-cpu-dashboard.png     # CPU monitoring dashboard
    └── grafana-memory-dashboard.png  # Memory monitoring dashboard
```

---

## 🔧 Configuration Details

### Security Group Configuration

**Monitoring Server (EC2 Security Group)**:
```
Inbound Rules:
┌──────────────────┬────────┬─────────────────┐
│ Type             │ Port   │ Source          │
├──────────────────┼────────┼─────────────────┤
│ SSH              │ 22     │ Your IP         │
│ Prometheus       │ 9090   │ 0.0.0.0/0       │
│ Grafana          │ 3000   │ 0.0.0.0/0       │
│ Node Exporter    │ 9100   │ VPC CIDR        │
└──────────────────┴────────┴─────────────────┘
```

**Jenkins Server (EC2 Security Group)**:
```
Inbound Rules:
┌──────────────────┬────────┬─────────────────┐
│ Type             │ Port   │ Source          │
├──────────────────┼────────┼─────────────────┤
│ SSH              │ 22     │ Your IP         │
│ Jenkins          │ 8080   │ 0.0.0.0/0       │
│ Node Exporter    │ 9100   │ VPC CIDR        │
└──────────────────┴────────┴─────────────────┘
```

### Prometheus Target Configuration

Edit `/etc/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter_monitoring'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'node_exporter_jenkins'
    scrape_interval: 5s
    static_configs:
      - targets: ['<JENKINS_PRIVATE_IP>:9100']

  - job_name: 'jenkins_metrics'
    metrics_path: '/prometheus'
    scrape_interval: 15s
    static_configs:
      - targets: ['<JENKINS_PRIVATE_IP>:8080']
```

---

## 📈 Metrics Collected

### System-Level Metrics (via Node Exporter)

- **CPU**: Usage percentage, load average, context switches
- **Memory**: Total, used, available, cached, swap
- **Disk**: I/O operations, throughput, latency, space usage
- **Network**: Bytes sent/received, packet statistics, errors
- **System**: Uptime, processes, file descriptors

### Jenkins-Specific Metrics

- **Build Metrics**: Queue length, duration, success/failure rate
- **Executor Metrics**: Total, busy, idle executors
- **Job Metrics**: Total jobs, last build status
- **Plugin Metrics**: Health check status
- **System Metrics**: JVM heap usage, GC statistics

---

## 🧪 Testing the Setup

### Test 1: Baseline Monitoring
```bash
# Verify all targets are UP
curl http://<monitoring-server-ip>:9090/targets

# Expected: All 3 targets showing green "UP" status
```

### Test 2: Create Test Jenkins Job
```bash
# In Jenkins UI:
1. New Item → Freestyle Project → "test-load-job"
2. Build Steps → Execute Shell:
   for i in {1..60}; do echo "Testing $i"; sleep 1; done
3. Save and Build Now
```

**Expected Results**:
- CPU usage spikes to 15-25%
- Memory increases by 5-10%
- Real-time updates in Grafana dashboard

### Test 3: Concurrent Builds
```bash
# Trigger 3 builds simultaneously
# Monitor resource utilization in Grafana
```

---

## 📚 Documentation

Comprehensive guides available in `/docs`:

- **[Installation Guide](docs/INSTALLATION.md)** - Step-by-step setup instructions
- **[Architecture Document](docs/ARCHITECTURE.md)** - Detailed system design
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues & fixes
- **[Query Examples](docs/QUERIES.md)** - Useful PromQL queries

---

## 🎓 Learning Outcomes

### Skills Demonstrated

✅ **Cloud Infrastructure**: AWS EC2 provisioning, security groups, VPC networking  
✅ **Monitoring Tools**: Prometheus installation, configuration, and PromQL  
✅ **Visualization**: Grafana dashboard creation and data source integration  
✅ **System Administration**: Linux systemd services, user management  
✅ **CI/CD Operations**: Jenkins setup and monitoring integration  
✅ **DevOps Practices**: Infrastructure monitoring, observability implementation  

---

## 🐛 Troubleshooting

### Issue: Prometheus Targets Showing "DOWN"

**Symptoms**: Red "DOWN" status in Prometheus targets page

**Solutions**:
```bash
# Check Node Exporter status
sudo systemctl status node_exporter

# Verify port is open
sudo netstat -tulpn | grep 9100

# Check security group rules in AWS
# Ensure port 9100 is accessible from monitoring server

# Restart Node Exporter
sudo systemctl restart node_exporter
```

### Issue: Grafana Shows "No Data"

**Symptoms**: Dashboard panels display "No data"

**Solutions**:
```bash
# Verify Prometheus data source
# In Grafana: Configuration → Data Sources → Prometheus → Test

# Check time range in dashboard (top-right corner)
# Ensure it's set to "Last 15 minutes" or similar

# Validate PromQL query syntax
# Run query directly in Prometheus UI first

# Check Prometheus logs
sudo journalctl -u prometheus -f
```

### Issue: High Memory Usage

**Symptoms**: Server running out of memory

**Solutions**:
```bash
# Check memory usage
free -h

# Adjust Prometheus retention period
# Edit: /etc/prometheus/prometheus.yml
# Add: --storage.tsdb.retention.time=7d

# Restart Prometheus
sudo systemctl restart prometheus
```

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for complete solutions.

---

## 🚀 Future Enhancements

- [ ] **Alerting**: Configure AlertManager for notifications
- [ ] **Notifications**: Integrate with Slack/Email/PagerDuty
- [ ] **High Availability**: Implement Prometheus federation
- [ ] **Log Aggregation**: Add ELK Stack integration
- [ ] **Application Metrics**: Custom application monitoring
- [ ] **Infrastructure as Code**: Terraform templates
- [ ] **Container Support**: Docker/Kubernetes deployment
- [ ] **Automated Backups**: S3 backup configuration

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🌿 Create your feature branch: `git checkout -b feature/amazing-feature`
3. 💾 Commit your changes: `git commit -m 'Add amazing feature'`
4. 📤 Push to the branch: `git push origin feature/amazing-feature`
5. 🔁 Open a Pull Request

### Contribution Guidelines

- Follow existing code style and structure
- Update documentation for new features
- Add tests where applicable
- Ensure all scripts are tested before submission

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Akanksha**

- 🌐 GitHub: [@akanksha106-code](https://github.com/akanksha106-code)
- 💼 LinkedIn: [Connect with me](https://linkedin.com/in/yourprofile)
- 📧 Email: your.email@example.com

---

## 🌟 Acknowledgments

- **Prometheus Team** - For the excellent monitoring toolkit
- **Grafana Labs** - For the powerful visualization platform
- **Jenkins Community** - For the robust CI/CD solution
- **AWS** - For reliable cloud infrastructure
- **Open Source Community** - For continuous inspiration

---

## 📊 Project Stats

![GitHub Stars](https://img.shields.io/github/stars/akanksha106-code/Grafana-prometheus?style=social)
![GitHub Forks](https://img.shields.io/github/forks/akanksha106-code/Grafana-prometheus?style=social)
![GitHub Issues](https://img.shields.io/github/issues/akanksha106-code/Grafana-prometheus)
![GitHub License](https://img.shields.io/github/license/akanksha106-code/Grafana-prometheus)
![Last Commit](https://img.shields.io/github/last-commit/akanksha106-code/Grafana-prometheus)

---

## 💡 Tips for Production Use

1. **Security**: Always use HTTPS in production with SSL certificates
2. **Authentication**: Enable authentication for Prometheus and Grafana
3. **Backup**: Regular backups of Prometheus data and Grafana dashboards
4. **Monitoring**: Monitor the monitoring system itself (meta-monitoring)
5. **Retention**: Configure appropriate data retention policies
6. **Scaling**: Use Prometheus federation for large-scale deployments

---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you learn DevOps monitoring!

---

<div align="center">

**[⬆ Back to Top](#-jenkins-monitoring-with-prometheus--grafana)**

Made with ❤️ for the DevOps Community

</div>
