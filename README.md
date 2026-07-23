<div align="center">

# ☁️ Hetzner Cloud Tools

**Hetzner Cloud ecosystem CLI tools (Hardened)**

[![build_status_badge](../../actions/workflows/docker-image-native-multiplatform-pipeline.yaml/badge.svg?branch=main)](.github/workflows/docker-image-native-multiplatform-pipeline.yaml)
[![Hetzner Cloud](https://img.shields.io/badge/Hetzner%20Cloud-D50C2D?style=flat-square)](https://www.hetzner.com/cloud/)

</div>

---

## 📦 Latest Build

<!-- VERSION_INFO_START -->
| Component | Version |
|-----------|---------|
| **Ansible** | [`v2.21.2`](https://github.com/ansible/ansible/releases/tag/v2.21.2) |
| **cert-manager CLI** | [`v2.5.0`](https://github.com/cert-manager/cmctl/releases/tag/v2.5.0) |
| **hcloud CLI** | [`v1.66.0`](https://github.com/hetznercloud/cli/releases/tag/v1.66.0) |
| **Helm** | [`v4.2.3`](https://github.com/helm/helm/releases/tag/v4.2.3) |
| **K9s** | [`v0.51.0`](https://github.com/derailed/k9s/releases/tag/v0.51.0) |
| **Kops** | [`v1.36.0`](https://github.com/kubernetes/kops/releases/tag/v1.36.0) |
| **Kubectl** | [`v1.36.3`](https://github.com/kubernetes/kubernetes/releases/tag/v1.36.3) |
| **Kustomize** | [`5.8.1`](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize/v5.8.1) |
| **SwarmCLI** | [`v1.13.0-rc4`](https://github.com/Eldara-Tech/swarmcli/releases/tag/v1.13.0-rc4) |
| **Terraform** | [`1.16.0-alpha20260715`](https://github.com/hashicorp/terraform/releases/tag/v1.16.0-alpha20260715) |
| **Terragrunt** | [`v1.1.1`](https://github.com/gruntwork-io/terragrunt/releases/tag/v1.1.1) |

> 🔄 Last updated: 2026-07-23T02:56:51+02:00 · [Build #5](https://github.com/stefanbosak/hetznercloud-tools/actions/runs/30000907521)
<!-- VERSION_INFO_END -->

---

## 📋 Overview

This repository provides a fully automated preparation of <span style="color: #0969da;">**containerized**</span> [Hetzner Cloud](https://www.hetzner.com/cloud/) environment using <span style="color: #1a7f37;">**Docker-in-Docker**</span> architecture.

### Covered CLI tools

| Tool | Description |
|------|-------------|
| [Ansible CLI](https://docs.ansible.com/ansible/latest/command_guide/command_line_tools.html) | <span style="color: #8250df;">Configuration management and automation</span> |
| [hcloud CLI](https://github.com/hetznercloud/cli) | <span style="color: #8250df;">Official Hetzner Cloud command-line interface</span> |
| [cert-manager CLI](https://github.com/cert-manager/cmctl/) | <span style="color: #d73a49;">cert-manager CLI</span> |
| [CNPG CLI](https://github.com/cloudnative-pg/cloudnative-pg/) | <span style="color: #d73a49;">CloudNativePG CLI</span> |
| [Docker CLI](https://docker.com) | <span style="color: #d73a49;">Container management CLI</span> |
| [HELM CLI](https://helm.sh/docs/helm/) | <span style="color: #0969da;">Kubernetes package manager</span> |
| [kops CLI](https://kops.sigs.k8s.io/) | <span style="color: #0969da;">Kubernetes cluster management</span> |
| [kubectl CLI](https://kubernetes.io/docs/reference/kubectl/) | <span style="color: #0969da;">Kubernetes command-line tool</span> |
| [k9s CLI](https://k9scli.io/) | <span style="color: #0969da;">Terminal UI for Kubernetes</span> |
| [SwarmCLI](https://github.com/Eldara-Tech/swarmcli) | <span style="color: #0969da;">Terminal UI for Docker Swarm</span> |
| [Terraform CLI](https://developer.hashicorp.com/terraform/cli) | <span style="color: #1a7f37;">Infrastructure as Code tool</span> |
| [Terragrunt CLI](https://terragrunt.gruntwork.io/) | <span style="color: #1a7f37;">Terraform wrapper for DRY configurations</span> |

> [!NOTE]
> Every script and file is reasonably well commented and relevant details can be found there.

> [!IMPORTANT]
> Check details before taking any action.

> [!CAUTION]
> User is responsible for any modification and execution of any parts from this repository.

---

## ⚡ Zero Effort Approach

GitHub Actions workflow file covers all necessary activities which are fully automated in GitHub (re-using Docker container approach as base for automation):

- <span style="color: #1a7f37;">Gathering and propagating latest available tools versions to Docker preparation process</span>
- <span style="color: #0969da;">Building Docker hardened image</span>

---

## 🐳 Docker Container Approach

Docker build wrapper script covers creation of a container built from a multistage Dockerfile using parallel execution of several builders to speed up preparation. Generated image contains all mentioned tools with pre-enabled Bash completions. Docker run wrapper simplifies application execution.

| File | Description |
|------|-------------|
| [`Dockerfile`](Dockerfile) | <span style="color: #0969da;">Recipe for preparation of Docker container</span> |

### 🏗️ Container Images

| Registry | Network Support | Pull Command |
|----------|----------------|--------------|
| [**DockerHub CR**](https://hub.docker.com/r/developmententity/hetznercloud-tools) | <span style="color: #1a7f37;">IPv4 & IPv6</span> | `docker pull developmententity/hetznercloud-tools:initial` |
| [**GitHub CR**](https://github.com/users/stefanbosak/packages/container/package/hetznercloud-tools) | <span style="color: #8250df;">IPv4 only</span> | `docker pull ghcr.io/stefanbosak/hetznercloud-tools:initial` |

---

## 🌍 Hetzner Cloud Environment

Hetzner Cloud environment can be used via hetznercloud-tools container which is automatically generated and available within ghcr.io. The dedicated `run.sh` script pulls and runs the up-to-date container. To access Hetzner Cloud from within the container, create (or re-use) an `hcloud` context on first use:

```bash
hcloud context create <context-name>
```

You'll be prompted for a Hetzner Cloud API token — follow the [token generation guide](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/) if you don't have one yet. The context (including the token) is stored in `~/.config/hcloud/cli.toml`; map that path into the container if you want it to persist across container restarts, so re-authentication isn't required unless the token is revoked or rotated.

**Switch between projects** — list and activate a different context:

```bash
hcloud context list
hcloud context use <context-name>
```

> [!NOTE]
> `hcloud` ([hetznercloud/cli](https://github.com/hetznercloud/cli)) covers the full day-2 lifecycle of Hetzner Cloud resources (`server`, `volume`, `load-balancer`, `network`, `firewall`, `image`, `certificate`, `primary-ip`, `storage-box`, and more), unlike lighter community CLIs that only expose a handful of read-only operations.

---

<div align="center">

<span style="color: #8250df;">**Made with ❤️ for ☁️ Hetzner Cloud ecosystem and 🔒 security**</span>

</div>
