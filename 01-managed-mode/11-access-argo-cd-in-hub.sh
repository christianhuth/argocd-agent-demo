#!/bin/bash

source .env

# Check initial admin password
kubectl -n $NAMESPACE_NAME get secret argocd-initial-admin-secret --context kind-$PRINCIPAL_CLUSTER_NAME \
  -o jsonpath="{.data.password}" | base64 -d && echo

kubectl port-forward svc/argocd-server -n $NAMESPACE_NAME 8080:443 --context kind-$PRINCIPAL_CLUSTER_NAME
