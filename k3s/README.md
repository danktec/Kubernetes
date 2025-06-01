# K3s on DigitalOcean

K3s is a lightweight yet fully-featured Kubernetes deployment built on rancher. https://docs.k3s.io/


## Setup
This project deploys a controller and a worker node on Digital Ocean Droplets. The number of nodes is designed to be horizontally scalable.

```bash
ssh-add ~/.ssh/id_rsa # cache ssh key
export TF_VAR_DoToken=dop_v1_999
export SSHKEYID=$(doctl compute ssh-key list | awk '{print $1}' | egrep -v ID) 
terraform apply
```

Build the Ansible inventory from TF output
```bash
echo "[controller]" > inventory
echo "controller01 ansible_host="`terraform output -json | jq '.k3sController.value[0]'` >> inventory
echo "[workers]" >> inventory
echo "worker01 ansible_host="`terraform output -json | jq '.k3sWorker.value[0]'` >> inventory

ansible-playbook -u root -i inventory ansible-setup.yaml
```

Ansible will set up the cluster nodes and install the dashboard

Copy the rancher config file from the controller into your local kube config to use kubectl remotely.

```bash
ssh root@[controller_ip] cat /etc/rancher/k3s/k3s.yaml >> ~/.kube/config
```

## Set up the admin dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
Once the ansible scripts have set up the cluster and the dashboard is configured run:

```bash
kubectl proxy
```

Direct your browser to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login enter the dashboard_token


### Install Traefik (already on k3s)
https://gist.github.com/jannegpriv/2ea82c023f4f61a317b1eed217d38004

### Storage Driver Integrations



### Install metrics
TODO

### Deploy the nginx-test app
```bash
kubectl create namespace test

cd ../deployments
kubectl apply -f service.yaml -f deployment.yaml -f ingressRoute.yaml
kubectl get ingressroute.traefik.containo.us -n test
```

### Label the node we want to schedule workloads on
```bash
kubectl label nodes debian12-k3scontroller disk=slow
kubectl label nodes debian12-k3sworker disk=fast
```

### Test the deployment
```bash
# Hit any node's IP and traefik will route it
curl http://<node_ip> -H "Host: mydomain.com"
```

### Cordon/drain a node
```bash
kubectl drain debian12-k3sworker --ignore-daemonsets --delete-emptydir-data
```

### Delete a node and re-join it
```bash
[delete the node]
[refresh terraform state]
kubectl delete node debian12-k3sworker # Required to remove named node from the config (could rename the node)
[reapply terraform]
[reapply ansibe]
```

### Deploy Prometheus / Grafana / Loki Monitoring Stack

Expose commands transition the service type from ClusterIP to NodePort, enabling external access to the service.

Use minikube or port-forward command to reach the endpoint

#### Install Prometheus
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext

```

#### Install Grafana
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext
# Get the admin secret for Grafana
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

```

## Digital Ocean CSI
For persistent volumes https://github.com/digitalocean/csi-digitalocean

## Additional cluster commands
```bash
kubectl logs -f -l app=hello --prefix=true
kubectl svc -o yaml
kubectl get nodes|deployments|pods|all -A
kubectl cluster-info
kubectl config view
```