#!/bin/bash

source .env

# Create Agent configuration on Principal. 
PRINCIPAL_EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' argocd-hub-control-plane)
echo "<principal-external-ip>: $PRINCIPAL_EXTERNAL_IP"

argocd-agentctl agent create $AGENT_APP_NAME \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME \
  --resource-proxy-server ${PRINCIPAL_EXTERNAL_IP}:9090

# Issue Agent client certificate
argocd-agentctl pki issue agent $AGENT_APP_NAME \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --agent-context kind-$AGENT_CLUSTER_NAME \
  --agent-namespace $NAMESPACE_NAME \
  --upsert

# Propagate Certificate Authority to Agent
argocd-agentctl pki propagate \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME \
  --agent-context kind-$AGENT_CLUSTER_NAME \
  --agent-namespace $NAMESPACE_NAME
