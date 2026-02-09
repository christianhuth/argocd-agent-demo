#!/bin/bash

source .env

# Propagate a default AppProject from principal to the agent
kubectl patch appproject default -n $NAMESPACE_NAME \
  --context kind-$PRINCIPAL_CLUSTER_NAME --type='merge' \
  --patch='{"spec":{"sourceNamespaces":["*"],"destinations":[{"name":"*","namespace":"*","server":"*"}]}}'

# Check that the AppProject appears on the workload cluster
kubectl get appprojs -n $NAMESPACE_NAME --context kind-$AGENT_CLUSTER_NAME

# Check NodePort
PRINCIPAL_EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' argocd-hub-control-plane)
echo "<principal-external-ip>: $PRINCIPAL_EXTERNAL_IP"

PRINCIPAL_NODE_PORT=$(kubectl get svc argocd-agent-principal -n $NAMESPACE_NAME --context kind-$PRINCIPAL_CLUSTER_NAME -o jsonpath='{.spec.ports[0].nodePort}'
)
echo "<principal-node-port>: $PRINCIPAL_NODE_PORT"

cat <<EOF | kubectl apply -f - --context kind-$PRINCIPAL_CLUSTER_NAME
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: test-app
  namespace: $AGENT_APP_NAME
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://$PRINCIPAL_EXTERNAL_IP:$PRINCIPAL_NODE_PORT?agentName=$AGENT_APP_NAME
    namespace: guestbook
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
EOF
