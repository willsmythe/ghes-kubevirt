# Running GHES via KubeVirt on Azure Kubernetes Services

> Note: this is not not actually working yet ;)

## Create the cluster

```
export RESOURCE_GROUP=ghes-kubevirt
export CLUSTER=ghes-kubevirt
```

```
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name myAKSCluster \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

## Configure kubectl

```
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER
```

Check for nodes

```
kubectl get nodes
```

## Networking

### Attempt 1: HTTP application routing

Documentation: https://docs.microsoft.com/en-us/azure/aks/http-application-routing

```
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```

Take the DNS zone and update -aks.yml

```
TBD
```


```
TODO: kubectl apply -f ghes-vm-aks-har.yml
```        

### Attempt 2: ingress controller

Documentation: https://docs.microsoft.com/en-us/azure/aks/ingress-basic

### Attempt 3: load balancer

```
virtctl expose vmi ghes-vm --name ghes-expose-lb --type LoadBalancer --port 27017 --target-port 80
```

Or this may have worked if it weren't for the UDP ports

```
virtctl expose vmi ghes-vm --name=ghes-vm-mgmt-service --type LoadBalancer
```
