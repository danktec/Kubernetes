
## Bootstrap K8s
```bash
cd k8s/terraform
terraform init
terraform apply

# Load kubeconfig
doctl auth init -t <token>
doctl kubernetes cluster kubeconfig save test-k8s
```

## Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port-forward service to local proxy
kubectl port-forward service/argocd-server -n argocd 8080:443

# Expose service on a public LB
kubectl patch service argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get the admin password 
argocd admin initial-password -n argocd
```

## Set up Wordpress HELM
```bash
helm install wordpress-test-1 \
  --set service.type=ClusterIP \
  --set persistence.size=2Gi \
  --set mariadb.primary.persistence.size=2Gi \
  --set wordpressUsername=admin \
  --set wordpressPassword=[password] \
  --set mariadb.auth.rootPassword=[password] \
  --create-namespace \
  --namespace wordpress-test \
  ../Helm/wordpress
```
