#!/bin/bash

source .env

# Create Argo CD namespace
kubectl create namespace $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME
kubectl create namespace $NAMESPACE_NAME --context kind-$AGENT_CLUSTER_NAME

# Create Agent namespace on Principal
kubectl create namespace $AGENT_APP_NAME --context kind-$PRINCIPAL_CLUSTER_NAME
