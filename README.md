# Argo CD Agent

A small demo of Argo CD Agent mode.

## Prerequisistes

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [argocd-agentctl](https://github.com/argoproj-labs/argocd-agent/releases)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## Architecture Overview

```bash
    kind-argocd-hub               kind-argocd-agent1...
  (Control Plane Cluster)       (Workload Cluster(s))

Pod CIDR: 10.245.0.0/16        Pod CIDR: 10.246.0.0/16...
SVC CIDR: 10.97.0.0/12         SVC CIDR: 10.98.0.0/12...
┌─────────────────────┐        ┌─────────────────────┐
│ ┌─────────────────┐ │        │ ┌─────────────────┐ │
│ │   Argo CD       │ │        │ │   Argo CD       │ │
│ │ ┌─────────────┐ │ │        │ │ ┌─────────────┐ │ │
│ │ │ API Server  │ │ │◄──────┐│ │ │   App       │ │ │
│ │ │ Repository  │ │ │       ││ │ │ Controller  │ │ │
│ │ │ Redis       │ │ │       ││ │ │ Repository  │ │ │
│ │ │ Dex (SSO)   │ │ │       ││ │ │ Redis       │ │ │
│ │ └─────────────┘ │ │       ││ │ └─────────────┘ │ |
│ └─────────────────┘ │       ││ └─────────────────┘ │
│ ┌─────────────────┐ │       ││ ┌─────────────────┐ │
│ │   Principal     │ │◄──────┘│ │     Agent       │ │
│ │ ┌─────────────┐ │ │        │ │                 │ │
│ │ │ gRPC Server │ │ │        │ │                 │ │
│ │ │ Resource    │ │ │        │ │                 │ │
│ │ │ Proxy       │ │ │        │ │                 │ │
│ │ └─────────────┘ │ │        │ └─────────────────┘ │
│ └─────────────────┘ │        └─────────────────────┘
└─────────────────────┘
```

## Demo of the **managed** Mode

```bash
cd 01-managed-mode
./01-create-control-plane-cluster.sh
./02-create-workload-cluster.sh
./03-create-namespaces.sh
```
