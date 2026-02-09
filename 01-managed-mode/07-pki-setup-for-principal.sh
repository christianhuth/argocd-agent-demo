#!/bin/bash

source .env

# Check NodePort
PRINCIPAL_EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' argocd-hub-control-plane)
echo "<principal-external-ip>: $PRINCIPAL_EXTERNAL_IP"

PRINCIPAL_NODE_PORT=$(kubectl get svc argocd-agent-principal -n $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME -o jsonpath='{.spec.ports[0].nodePort}'
)
echo "<principal-node-port>: $PRINCIPAL_NODE_PORT"

# Check DNS Name
PRINCIPAL_DNS_NAME=$(kubectl get svc argocd-agent-principal -n $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME -o jsonpath='{.metadata.name}.{.metadata.namespace}.svc.cluster.local')
echo "<principal-dns-name>: $PRINCIPAL_DNS_NAME"

# Create pki issue
argocd-agentctl pki issue principal \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME \
  --ip 127.0.0.1,$PRINCIPAL_EXTERNAL_IP \
  --dns localhost,$PRINCIPAL_DNS_NAME \
  --upsert

# Check NodePort
RESOURCE_PROXY_INTERNAL_IP=$(kubectl get svc argocd-agent-resource-proxy \
  -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME \
  -o jsonpath='{.spec.clusterIP}')
echo "<resource-proxy-ip>: $RESOURCE_PROXY_INTERNAL_IP"

RESOURCE_PROXY_DNS_NAME=$(kubectl get svc argocd-agent-resource-proxy \
  -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME \
  -o jsonpath='{.metadata.name}.{.metadata.namespace}.svc.cluster.local')
echo "<resource-proxy-dns>: $RESOURCE_PROXY_DNS_NAME"

# Create pki issue
argocd-agentctl pki issue resource-proxy \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME \
  --ip 127.0.0.1,$RESOURCE_PROXY_INTERNAL_IP \
  --dns localhost,$RESOURCE_PROXY_DNS_NAME \
  --upsert

argocd-agentctl jwt create-key \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME \
  --upsert
