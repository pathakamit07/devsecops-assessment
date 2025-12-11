# k8s manifests for DevSecOps assessment
Files:
- namespace.yaml
- deployment.yaml
- service.yaml
- ingress.yaml
- networkpolicy.yaml
- pdb.yaml
- hpa.yaml

Validation (run from project root):
  kubectl apply --dry-run=client -f .\k8s\

Apply:
  kubectl apply -f .\k8s\

Check pods:
  kubectl get pods -n devsecops
  kubectl describe pod <pod-name> -n devsecops

If you use kind and built the image locally:
  # build image locally then load into kind
  docker build -t webapp:ci .
  kind load docker-image webapp:ci --name devsecops

Notes:
- Ingress requires an ingress controller (eg: nginx ingress) in the cluster.
- The deployment uses a non-root user, disallows privilege escalation and has resource limits.
