# Running GHES on Azure Kubernetes Services

This document describes requirements and instructions specific to [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes).

## Get started

### VM SKU

To avoid [emulation](https://github.com/kubevirt/kubevirt/blob/master/docs/software-emulation.md), choose an Azure VM SKU that supports nested virtualization (like Dv3 and Ev3). Standard D8s v3 works well for testing. 

### Storage

Choose 

## Create the cluster


```
export RESOURCE_GROUP=ghes-kubevirt
export CLUSTER=ghes-kubevirt

or

set RESOURCE_GROUP=ghes-kubevirt
set CLUSTER=ghes-kubevirt
```

```
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
    
```

## Configure kubectl

```
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER

-OR-

az aks get-credentials --resource-group %RESOURCE_GROUP% --name %CLUSTER%
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

## Links

* https://azure.microsoft.com/en-us/blog/nested-virtualization-in-azure/
* https://www.brianlinkletter.com/create-a-nested-virtual-machine-in-a-microsoft-azure-linux-vm/

Alternatively: on AKS (uses managed premium storage):

```
kubectl apply -f https://raw.githubusercontent.com/willsmythe/ghes-kubevirt/master/aks/ghes-vm-data-volumes-aks.yml
```
