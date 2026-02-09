#!/bin/bash

source .env
cat <<EOF | kind create cluster --name $PRINCIPAL_CLUSTER_NAME --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $PRINCIPAL_CLUSTER_NAME
networking:
  podSubnet: "$PRINCIPAL_POD_CIDR"
  serviceSubnet: "$PRINCIPAL_SVC_CIDR"
nodes:
  - role: control-plane
EOF
