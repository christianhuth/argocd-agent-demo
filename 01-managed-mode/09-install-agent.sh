#!/bin/bash

source .env

# Deploy Agent
kubectl apply -n $NAMESPACE_NAME \
  -k "https://github.com/argoproj-labs/argocd-agent/install/kubernetes/agent?ref=$RELEASE_BRANCH" \
  --context kind-$AGENT_CLUSTER_NAME

# Configure Agent to connect to Principal using mTLS authentication
# Check NodePort
PRINCIPAL_EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' argocd-hub-control-plane)
echo "<principal-external-ip>: $PRINCIPAL_EXTERNAL_IP"

PRINCIPAL_NODE_PORT=$(kubectl get svc argocd-agent-principal -n $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME -o jsonpath='{.spec.ports[0].nodePort}'
)
echo "<principal-node-port>: $PRINCIPAL_NODE_PORT"

kubectl patch configmap argocd-agent-params \
  -n $NAMESPACE_NAME \
  --context kind-$AGENT_CLUSTER_NAME \
  --patch "{\"data\":{
    \"agent.server.address\":\"$PRINCIPAL_EXTERNAL_IP\",
    \"agent.server.port\":\"$PRINCIPAL_NODE_PORT\",
    \"agent.mode\":\"$AGENT_MODE\",
    \"agent.creds\":\"mtls:any\"
  }}"

kubectl rollout restart deployment argocd-agent-agent \
  -n $NAMESPACE_NAME \
  --context kind-$AGENT_CLUSTER_NAME
