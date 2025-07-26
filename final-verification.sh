#!/bin/bash

echo "=== Part 4 Verification ==="
echo "1. Kubernetes Cluster Status:"
kubectl get nodes

echo -e "\n2. Application Pods:"
kubectl get pods -n todo-app

echo -e "\n3. ArgoCD Status:"
kubectl get pods -n argocd | grep Running | wc -l
echo "ArgoCD pods running"

echo -e "\n4. ArgoCD Application:"
kubectl get applications -n argocd

echo -e "\n5. Application Health Check:"
kubectl port-forward -n todo-app svc/todo-app-service 3001:80 >/dev/null 2>&1 &
PF_PID=$!
sleep 2
curl -s http://localhost:3001/health | jq . 2>/dev/null || curl -s http://localhost:3001/health
kill $PF_PID 2>/dev/null

echo -e "\n6. GitOps Repository Structure:"
echo "Repository: https://github.com/joisyousef/Todo-List-nodejs.git"
echo "Kubernetes manifests path: k8s/app/"
ls -la k8s/app/

echo -e "\n=== All checks complete! ==="

