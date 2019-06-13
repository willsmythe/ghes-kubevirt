# Deploying GHES on Azure Kubernetes Service (AKS)

This document describes requirements and instructions specific to [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes). 

Once you have a Kubernetes cluster up and running, follow the [general steps](../README.md) for deploying KubeVirt and the GitHub Enterprise Server VM.

## Requirements

### Hardware

To avoid running the VM in [emulation mode](https://github.com/kubevirt/kubevirt/blob/master/docs/software-emulation.md), you must choose an Azure VM SKU that supports nested virtualization (like Dv3 and Ev3).

For demo and evaluation purposes, **Standard D8s v3** works well. For more details, see the "D2s-64s v3 latest generation" section on the [Azure Linux VM pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/#d-series) page.

### Software

You need to either [install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) or use the [Azure cloud Shell](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest#install-or-run-in-azure-cloud-shell) which is available in the Azure Portal.

## Create a Kubernetes cluster

```
export RESOURCE_GROUP=ghes-kubevirt
export CLUSTER=ghes-kubevirt
```

Create a resource group:

```
az group create --name $RESOURCE_GROUP --location eastus
```

Create the cluster:

```
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
    --node-vm-size Standard_D8s_v3
    
```

## Connect to the cluster

If you don't already have `kubectl` (the tool for managing Kubernetes resources), install it using the Azure CLI:

```
az aks install-cli
```

To run `kubectl` commands against the cluster you just created run:

```
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER
```

Verify you can connect and there is at least one node in the cluster:

```
kubectl get nodes
```

## Next steps

Now that you have your cluster up and running, follow the [general instructions](../README.md) for deploying KubeVirt and the GitHub Enterprise Server VM.

> Note: when creating the data volumes in the general instructions, note the alternate step for AKS which causes volumes to be created on a faster managed premium SSD drive versus a standard SSD drive.

## Useful links

* [Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using the Azure CLI](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)
* [Nested Virtualization in Azure](https://azure.microsoft.com/en-us/blog/nested-virtualization-in-azure/)
* [Create a nested virtual machine in a Microsoft Azure Linux VM](https://www.brianlinkletter.com/create-a-nested-virtual-machine-in-a-microsoft-azure-linux-vm/)
