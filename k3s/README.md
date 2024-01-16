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
cat /etc/rancher/k3s/k3s.yaml >> ~/.kube/config
```

## Set up the admin dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
Once the ansible scripts have set up the cluster and the dashboard is configured run:

```bash
kubectl proxy
```

Direct your browser to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login enter the dashboard_token


### Deploy an app
```bash
kubectl create deployment app1 --image nginx
#kubectl expose deployment app1 --name app1-svc --type NodePort --port 80
kubectl expose deployment app1 --name app1-svc --type=ClusterIP --port 80
kubectl get deployment app1
kubectl get svc app1-svc
```

### Install Traefik (already on k3s)
https://gist.github.com/jannegpriv/2ea82c023f4f61a317b1eed217d38004

### Install metrics
TODO

### Create an ingress for app1
```bash
kubectl apply -f IngressRoute.yaml
```

### HELM Chart Deployment
TODO


## Additional cluster commands
```bash
kubectl logs -f -l app=hello --prefix=true
kubectl svc -o yaml
kubectl get nodes|deployments|pods|all -A
kubectl cluster-info
kubectl config view
```