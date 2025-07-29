# DevOps Internship Assessment - Todo Application

[![CI/CD Pipeline](https://github.com/joisyousef/Todo-List-nodejs/actions/workflows/ci.yml/badge.svg)](https://github.com/joisyousef/Todo-List-nodejs/actions)

## 📋 Table of Contents

- [DevOps Internship Assessment - Todo Application](#devops-internship-assessment---todo-application)
  - [📋 Table of Contents](#-table-of-contents)
  - [🚀 Overview](#-overview)
  - [🏗️ Architecture](#️-architecture)
  - [🛠️ Prerequisites](#️-prerequisites)
  - [⚡ Quick Start](#-quick-start)
  - [📦 Part 1: Dockerization \& CI Pipeline](#-part-1-dockerization--ci-pipeline)
  - [🔧 Part 2: Infrastructure as Code with Ansible](#-part-2-infrastructure-as-code-with-ansible)
  - [🐳 Part 3: Container Orchestration \& Auto-Updates](#-part-3-container-orchestration--auto-updates)
  - [☸️ Part 4: Kubernetes \& GitOps (Bonus)](#️-part-4-kubernetes--gitops-bonus)
  - [🛠️ Technology Stack](#️-technology-stack)
  - [📁 Project Structure](#-project-structure)
  - [⚙️ Configuration](#️-configuration)
  - [📊 Health Checks \& Monitoring](#-health-checks--monitoring)

## 🚀 Overview

This repository contains a complete DevOps pipeline for the Node.js Todo application, covering:

- Containerization with Docker
- CI/CD automation via GitHub Actions
- Infrastructure provisioning using Ansible
- Container orchestration with Docker Compose
- Automated image updates with Watchtower
- Kubernetes deployment and GitOps with ArgoCD (bonus)

## 🏗️ Architecture

```mermaid
graph TB
    A[Developer] -->|push| B[GitHub Repo]
    B --> C[GitHub Actions CI]
    C --> D[Docker Hub]
    C --> E[Ansible Provisioning]
    E --> F[AWS EC2 Instance]
    F --> G[Docker Compose]
    G --> H[Todo App]
    G --> I[MongoDB]
    J[Watchtower] --> D
    J --> G
    subgraph Kubernetes (Bonus)
      F2[K3s on VM] --> K[ArgoCD]
      K --> L[Todo App Pods]
      K --> M[MongoDB Pod]
    end
```

## 🛠️ Prerequisites

- Docker (v20.10+)
- Docker Compose v2+
- Node.js (v16+)
- Git
- Ansible (v4+)
- AWS EC2 instance with SSH key access
- Docker Hub account

## ⚡ Quick Start

```bash
# Clone
git clone https://github.com/joisyousef/Todo-List-nodejs.git
cd Todo-List-nodejs

# Configure .env
# Edit MONGO_URI

# Part 1: Verify locally
docker build -t todo-app:local .
docker run -p 4000:4000 --env-file .env todo-app:local

# Part 2: Provision VM
cd ansible
ansible-playbook -i inventories/hosts.yml playbooks/site.yml

# Part 3: Deploy with Compose
scp -i devops-assessment-key.pem docker-compose.yml .env ec2-user@<VM_IP>:/opt/todo-app/
ssh -i devops-assessment-key.pem ec2-user@<VM_IP>
cd /opt/todo-app
docker-compose up -d

# Access
http://<VM_IP>:4000

# Bonus Part 4 (after setup)
kubectl port-forward -n todo-app svc/todo-app-service 31159:80
# then http://localhost:31159
```

---

## 📦 Part 1: Dockerization & CI Pipeline

- **Multi-stage Docker build** (`Dockerfile`) targeting `node:18-alpine`
- `.dockerignore` excludes `node_modules`, **.env**, logs, etc.
- **Environment**: `NODE_ENV=production`, exposes port **4000**
- **Healthcheck** on `/health`
- **GitHub Actions** (`.github/workflows/ci.yml`): tests, multi-arch build, **automatic tagging** (`sha-<GITHUB_SHA>` + `latest`), pushes to Docker Hub
- **Artifacts**: test reports uploaded as Action artifacts

## 🔧 Part 2: Infrastructure as Code with Ansible

- **Roles & handlers** under `ansible/roles`
- **Inventory** in `ansible/inventories/hosts.yml`
- **Playbook** `site.yml`:

  - Docker engine install
  - Docker Compose plugin install
  - User setup (ec2-user in `docker` group)
  - Systemd Docker start + enable
  - Firewall rules for port **4000**, **22**, **31159**
  - Idempotent, uses `become: yes` only on needed tasks

## 🐳 Part 3: Container Orchestration & Auto-Updates

- **docker-compose.yml** on VM:

  - `todo-app` service (image `joisyousef/todo-app:latest`)
  - `mongo` service with volume
  - **Healthchecks** for both
  - **Watchtower** service for auto-pull new `:latest`

- **Access** via VM_IP:4000

## ☸️ Part 4: Kubernetes & GitOps (Bonus)

- **k3s** lightweight Kubernetes on VM
- **Manifests** in `k8s/app/`: namespace, configmap, deployments, services, NodePort
- **ImagePullSecret** for Docker Hub
- **ArgoCD** installation via Ansible (playbook `kubernetes-setup.yml`)
- **Application** CRD in `argocd/todo-app-application.yml`
- **Access**:

  - ArgoCD UI: http\://\<VM_IP>:30080
  - App: http\://\<VM_IP>:31159

## 🛠️ Technology Stack

| Component             | Technology           |
| --------------------- | -------------------- |
| Application runtime   | Node.js 18 / Express |
| Template engine       | EJS                  |
| Database              | MongoDB 5.0          |
| CI/CD                 | GitHub Actions       |
| Containerization      | Docker               |
| Orchestration (local) | Docker Compose v2    |
| Orchestration (bonus) | K3s / ArgoCD         |
| IaC                   | Ansible              |
| Auto-update           | Watchtower           |

## 📁 Project Structure

```
├── ansible/                # Ansible code
├── argocd/                 # ArgoCD app definitions
├── k8s/                    # Kubernetes manifests (bonus)
├── vm-cloud-init/          # Cloud-init for VM boot
├── Dockerfile
├── docker-compose.yml      # Compose for VM deploy
├── .env.example
├── .github/workflows/ci.yml
├── src/                    # App code (controllers, models, views)
└── README.md
```

## ⚙️ Configuration

- `.env` with `MONGO_URI`, `PORT`, `JWT_SECRET`
- Ansible inventory at `ansible/inventories/hosts.yml`
- Docker Compose `docker-compose.yml` on VM: port mapping, env vars
- Kubernetes NodePort **31159** for service

## 📊 Health Checks & Monitoring

- **App**: `GET /health`
- **Compose healthcheck** in `docker-compose.yml`
- **Kubernetes** liveness/readiness probes on `/health` port **4000**
