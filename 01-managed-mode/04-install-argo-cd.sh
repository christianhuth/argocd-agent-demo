#!/bin/bash

source .env

kubectl apply -n $NAMESPACE_NAME \
  -k "https://github.com/argoproj-labs/argocd-agent/install/kubernetes/argo-cd/principal?ref=$RELEASE_BRANCH" \
  --context kind-$PRINCIPAL_CLUSTER_NAME

kubectl patch configmap argocd-cmd-params-cm \
  -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME \
  --patch '{"data":{"application.namespaces":"*"}}'

kubectl rollout restart deployment argocd-server -n $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME

kubectl get configmap argocd-cmd-params-cm \
  -n "$NAMESPACE_NAME" \
  --context "kind-$PRINCIPAL_CLUSTER_NAME" \
  -o yaml | grep application.namespaces

kubectl apply -n $NAMESPACE_NAME \
  -k "https://github.com/argoproj-labs/argocd-agent/install/kubernetes/argo-cd/agent-$AGENT_MODE?ref=$RELEASE_BRANCH" \
  --context kind-$AGENT_CLUSTER_NAME
