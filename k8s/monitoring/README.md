## Grafana + Prometheus integration (monitoring)

Manifests:
- 00-namespace.yaml
- 01-grafana-deployment.yaml
- 02-grafana-datasource-configmap.yaml
- 03-grafana-provisioning-configmap.yaml
- 04-grafana-dashboard-configmap.yaml
- 05-grafana-ingress.yaml  (optional)

Apply:
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-grafana-deployment.yaml
kubectl apply -f 02-grafana-datasource-configmap.yaml
kubectl apply -f 03-grafana-provisioning-configmap.yaml
kubectl apply -f 04-grafana-dashboard-configmap.yaml
# optional ingress (requires ingress controller + hosts file mapping)
kubectl apply -f 05-grafana-ingress.yaml

Access:
1) If you have ingress and host mapping (grafana.local -> cluster IP / loadbalancer): open http://grafana.local
2) Port-forward (if no ingress):
   kubectl -n monitoring port-forward deploy/grafana 3000:3000
   then open http://localhost:3000
Default admin user/password: admin / admin (change in env or use secret)
