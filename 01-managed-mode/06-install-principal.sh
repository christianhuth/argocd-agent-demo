#!/bin/bash

source .env

kubectl apply -n $NAMESPACE_NAME \
  -k "https://github.com/argoproj-labs/argocd-agent/install/kubernetes/principal?ref=$RELEASE_BRANCH" \
  --context kind-$PRINCIPAL_CLUSTER_NAME

kubectl patch configmap argocd-agent-params \
  -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME \
  --patch "{\"data\":{
    \"principal.allowed-namespaces\":\"$AGENT_APP_NAME\"
}}"

kubectl rollout restart deployment argocd-agent-principal \
  -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME

kubectl get configmap argocd-agent-params \
  -n "$NAMESPACE_NAME" \
  --context "kind-$PRINCIPAL_CLUSTER_NAME" \
  -o yaml | grep principal.allowed-namespaces

# Expected output:
# principal.allowed-namespaces: $AGENT_APP_NAME
# ($AGENT_APP_NAME should be replaced with the string value you set for your agent application name.)
