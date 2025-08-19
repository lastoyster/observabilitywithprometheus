# 📊 DevOps Observability with Terraform, Docker Compose, and Prometheus Stack

This repository contains **Infrastructure as Code (IaC)** templates to deploy a complete observability stack using 
**Terraform** **Docker Compose** and **AWS EC2**. It automates provisioning and monitoring of cloud infrastructure with tools like 
**Prometheus** **Grafana**, **Alertmanager**
 and **Node Exporter**.

---

## 🧭 Architecture Overview

![Observability Stack Architecture](./284796035-6a9f9d90-e56f-4038-82c7-e8eae29d8bcf.png)

### Components

- **Terraform**: Provisions AWS EC2 instance.
- **EC2**: Hosts the observability stack.
- **Docker Compose**: Manages the deployment of containers.
- **Node Exporter**: Collects system metrics from the EC2 instance.
- **Prometheus**: Scrapes metrics and provides data storage.
- **Alertmanager**: Sends alerts based on Prometheus rules.
- **Grafana**: Visualizes metrics using dashboards.
- **PromQL**: Query language used by Grafana to retrieve data from Prometheus.

---
### 1. Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Docker & Docker Compose](https://docs.docker.com/compose/install/)
- AWS credentials configured (`~/.aws/credentials`)

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
