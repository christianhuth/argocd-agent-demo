#!/bin/bash

source .env

argocd-agentctl pki init \
  --principal-context kind-$PRINCIPAL_CLUSTER_NAME \
  --principal-namespace $NAMESPACE_NAME
