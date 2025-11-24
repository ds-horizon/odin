# Odin Installation Guide

<div align="center">

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-green.svg)](https://www.gnu.org/licenses/lgpl-3.0)
[![Helm Chart](https://img.shields.io/badge/Helm-v0.0.1-blue)](https://github.com/ds-horizon/odin)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30%2B-326CE5?logo=kubernetes)](https://kubernetes.io/)

**Production-ready deployment platform for Kubernetes environments**

</div>

---

## Table of Contents

- [Prerequisites](#prerequisites)
  - [Hardware Requirements](#hardware-requirements)
  - [Software Requirements](#software-requirements)
  - [Version Compatibility Matrix](#version-compatibility-matrix)
  - [Access Requirements](#access-requirements)
- [Quick Start](#quick-start)
- [Post-Installation](#post-installation)
  - [Verification](#verification)
  - [CLI Setup](#cli-setup)
  - [Log Files](#log-files)
  - [Debug Mode](#debug-mode)
- [FAQ](#frequently-asked-questions)
- [Uninstallation](#uninstallation)
- [Operations](#operations)
  - [Monitoring and Logging](#monitoring-and-logging)
- [Getting Started Tutorial](#getting-started-tutorial)
- [References](#references-and-links)

---

## Prerequisites

### Hardware Requirements

#### Local Development (Kind Cluster)

| Resource | Minimum |
|----------|---------|
| **RAM** | 8 GB |
| **CPU** | 4 cores |
| **Disk Space** | 20 GB free |
| **OS** | macOS 11+, Linux (Ubuntu 20.04+) |

#### Cloud/Production Deployment

| Resource | Minimum |
|----------|---------|
| **RAM** | 16 GB |
| **CPU** | 8 cores |
| **Disk Space** | 50 GB |
| **Node Count** | 3 |

### Software Requirements

The following tools must be installed on your system:

#### Required Tools

| Tool | Minimum Version | Purpose | Installation |
|------|----------------|---------|--------------|
| **kubectl** | v1.24+ | Kubernetes CLI | [Install Guide](https://kubernetes.io/docs/tasks/tools/) |
| **Helm** | v3.8+ | Kubernetes package manager | [Install Guide](https://helm.sh/docs/intro/install/) |
| **git** | v2.30+ | Source code management | [Install Guide](https://git-scm.com/downloads) |
| **curl** | v7.68+ | HTTP client for downloads | Pre-installed on most systems |
| **jq** | v1.6+ | JSON processor | [Install Guide](https://stedolan.github.io/jq/download/) |

### Version Compatibility Matrix

#### Kubernetes Version Compatibility

| Kubernetes Version | Status | Notes |
|-------------------|--------|-------|
| **1.30 - 1.34** | ✅ Compatible | Should work |
| **< 1.29** | ⚠️ Not Tested | May have issues |

### Access Requirements

#### For Cloud Deployments

- **Cloud Provider CLI** (if applicable):
  - AWS: `aws-cli` with EKS access
  - GCP: `gcloud` with GKE access
  - Azure: `az` with AKS access
- **Cluster Credentials**: Properly configured kubeconfig

---

## Quick Start

Get Odin running on a local Kind cluster in under 15 minutes:

### One-Command Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ds-horizon/odin/master/install.sh)
```

**What This Does:**
1. ✅ Clones the Odin repository
2. ✅ Checks and installs prerequisites (kubectl, Helm, Docker, Kind)
3. ✅ Creates a local Kind cluster named `odin-cluster`
4. ✅ Sets up local Docker registry
5. ✅ Installs KEDA and Percona MySQL Operator
6. ✅ Deploys Odin with all components
7. ✅ Creates local development accounts
8. ✅ Optionally installs Odin CLI

**Expected Duration**: 7 - 10 minutes (depending on internet speed and hardware)

### What Happens During Installation

You'll see output similar to:

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║             Odin Helm Chart Installation                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

[Step 1/14] Checking kubectl installation
✓ kubectl is available

[Step 2/14] Checking Helm installation
✓ Helm is available

[INFO] Would you like to install Odin on a local Kind cluster? [y/N]: y

[Step 3/14] Setting up Docker for Kind cluster
✓ Docker is running

[Step 4/14] Installing Kind
✓ Kind installed successfully

[Step 5/14] Setting up Docker registry for Kind
✓ Local registry 'kind-registry' started

[Step 6/14] Creating Kubernetes cluster
✓ Kind cluster 'odin-cluster' is ready

...

[Step 14/14] Installing Odin CLI
✓ Odin CLI installed successfully!

🎉 Odin installation completed successfully!
```

### CLI Setup

#### Step 1: Locate the CLI Binary

If you installed the CLI during installation:

```bash
# CLI is installed in your home directory
ls -la ~/odin

# Move to PATH
sudo mv ~/odin /usr/local/bin/odin
chmod +x /usr/local/bin/odin
```

#### Step 2: Verify Installation

```bash
# Check version
odin version
```

#### Step 3: Port-Forward to Deployer

```bash
# Forward deployer service to localhost
kubectl port-forward svc/odin-deployer -n odin 8080:80
```

Keep this terminal open. In a new terminal:

#### Step 4: Configure CLI

```bash
# Configure Odin CLI
odin configure --org-id 0 --backend-address 127.0.0.1:8080 -I -P
```

### Step 5: Test odin

```bash
odin list env
```

Congratulations! 🎉 You've successfully: ✅ Installed Odin. To create and deploy services please refer


## Frequently Asked Questions

### General Questions

**Q: What is the minimum Kubernetes version required?**

A: Kubernetes v1.30 or later. Versions 1.30-1.34 are tested and recommended.

**Q: Can I install Odin on Minikube?**

A: Yes, but Kind is recommended for local development. Minikube may require additional memory configuration.

**Q: How much does Odin cost?**

A: Odin is open-source and free to use under the LGPL-3.0 License. You only pay for the infrastructure it runs on.

### Installation Questions

**Q: Can I use external databases instead of internal ones?**

A: Yes! You can configure external MySQL, Redis, and Elasticsearch:

```yaml
mysql:
  external:
    enabled: true
    master:
      host: "your-rds-endpoint.com"
redis:
  external:
    enabled: true
    host: "your-redis-endpoint.com"
elasticsearch:
  external:
    enabled: true
    host: "your-es-endpoint.com"
```

**Q: How do I customize resource allocations?**

A: Create a custom values file:

```yaml
deployer:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2
      memory: 4Gi
```

Then install with: `./install.sh --values custom-values.yaml`

### Configuration Questions

**Q: What are ES256 keys and why are they required?**

A: ES256 (ECDSA with P-256 curve and SHA-256) keys are used for secure authentication between components. They're automatically generated during installation or you can provide your own.


**Q: How do I enable high availability?**

A: Increase replica counts in your values file:

```yaml
deployer:
  replicaCount: 3
accountManager:
  replicaCount: 2
mysql:
  mysql:
    size: 3
redis:
  architecture: replication
  master:
    count: 1
  replica:
    replicaCount: 2
```

### Cloud-Specific Questions

**Q: Can I install on EKS/GKE/AKS?**

A: Yes! Odin works on all major cloud Kubernetes platforms.


**Q: How do I expose Odin externally?**

A: Use Kubernetes Ingress or LoadBalancer:

```yaml
deployer:
  service:
    type: LoadBalancer  # or configure Ingress
```

### Operational Questions

**Q: How do I backup Odin data?**

A: Enable automated backups for MySQL:

```yaml
mysql:
  backup:
    enabled: true
    schedule:
      - name: "daily-backup"
        schedule: "0 2 * * *"
        keep: 7
        storageName: s3local
```

Backups are stored in MinIO (`odin-backup-bucket`).

**Q: How do I upgrade Odin?**

A: Use Helm upgrade:

```bash
helm repo update
helm upgrade odin odin/odin -n odin --values your-values.yaml
```

For major version upgrades, always review the release notes and backup your data first.

**Q: How do I completely remove Odin?**

A: See [Uninstallation](#uninstallation) section below.

---

## Uninstallation

### Quick Uninstall

Remove Odin while preserving dependencies:

```bash
# Using the uninstall script
./uninstall.sh
```

### Uninstall with Options

```bash
# Specify custom release/namespace
./uninstall.sh --release odin --namespace odin

# Skip confirmation
./uninstall.sh --yes

# With debug output
./uninstall.sh --debug
```

### What Gets Removed

The uninstall script removes:
- ✅ Odin Helm release (deployer, orchestrator, account-manager, discovery-service)
- ✅ Internal MySQL (Percona cluster)
- ✅ Internal Redis
- ✅ Internal Elasticsearch
- ✅ MinIO
- ✅ ElasticMQ
- ✅ FluentBit
---


#### Metric Integration (Future)

Odin will support metrics in future releases

---

## References and Links

### Official Resources

- **GitHub Repository**: https://github.com/ds-horizon/odin
- **CLI Repository**: https://github.com/ds-horizon/odin-cli
- **Issue Tracker**: https://github.com/ds-horizon/odin/issues
- **Releases**: https://github.com/ds-horizon/odin/releases


### Community

- **License**: GNU Lesser General Public License v3.0 (see [LICENSE](LICENSE))
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md) (if available)
- **Code of Conduct**: See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (if available)

### Support

For issues, questions, or contributions:

1. **Check Documentation**: Review this guide and FAQ
2. **Search Issues**: Check if someone else has the same problem
3. **Create Issue**: File a detailed issue on GitHub

---

## Acknowledgments

Odin is built on top of excellent open-source projects:
- Kubernetes community
- Helm project
- KEDA maintainers
- Percona team
- Bitnami chart contributors
- All other open-source dependencies

---

**Last Updated**: January 2025
**Version**: 0.0.1
**Status**: Production Ready

For the latest updates, visit: https://github.com/ds-horizon/odin
