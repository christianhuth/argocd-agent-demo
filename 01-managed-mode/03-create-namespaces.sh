#!/bin/bash

source .env

kubectl create namespace $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME

kubectl create namespace $NAMESPACE_NAME --context kind-$AGENT_CLUSTER_NAME
