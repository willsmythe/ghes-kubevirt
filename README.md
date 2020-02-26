# Disclaimer

> **WARNING: This is not a supported deployment option for GHES**, and may or may not work with the latest version of GHES, Kubernetes, or any of the required components.

# Deploying GitHub Enterprise Server on Kubernetes (experiment)

Steps for deploying GitHub Enterprise Server on Kubernetes with [KubeVirt](https://kubevirt.io/).

**IMPORTANT**: See disclaimer above.

## Requirements

At a minimum the GitHub Enterprise Server VM *requires* 16GB of memory, 250GB of storage, and must be run in a host machine (or virtual machine) that supports [hardware virtualization](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-system_requirements-kvm_requirements).

These are firm requirements even for running a basic test/evaluation with a single user.

## Create a Kubernetes cluster

The first step is getting a Kubernetes cluster up and running. There are different options for where this cluster runs, but the best options are locally using Minikube or on [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/).

Pick one of the following options:

* [Create a cluster on Azure Kubernetes Service (AKS)](./azure/README.md)
* [Create a cluster locally on Minikube](./minikube/README.md)

Other attempts were made to deploy via [AWS EKS](aws/README.md) and [Packet](packet/README.md) were abandoned due to technical limitions (lack of hardware virtualization support) and problems unrelated to GHES.

Once you have a Kubernetes cluster up, continue with the steps below.

## Deploy KubeVirt and CDI

Two technologies are required on top of Kubernetes:

* [KubeVirt](https://github.com/kubevirt/kubevirt) enables VMs to be represented, managed, and deployed like any other resource in Kubernetes. 

* [Containerized-Data-Importer (CDI)](https://github.com/kubevirt/containerized-data-importer) enables VM disks to be imported as persistent volumes, and therefore managed like any other persistent volume in Kubernetes.

### Deploy CDI

```bash
export CDI_VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")

export CDI_DOWNLOAD_URL=https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION
```

```bash
kubectl create -f ${CDI_DOWNLOAD_URL}/cdi-operator.yaml
kubectl create -f ${CDI_DOWNLOAD_URL}/cdi-operator-cr.yaml
```

### Deploy Kubevirt

#### Deploy the operator

```bash
export KUBEVIRT_VERSION="v0.18.0"
export KUBEVIRT_DOWNLOAD_URL=https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/
```

```bash
kubectl create -f ${KUBEVIRT_DOWNLOAD_URL}/kubevirt-operator.yaml
```

#### Create the configmap / enable data volumes feature gate

You need to create a `kubevirt-config` configmap that enables the `DataVolumes` feature gate (this is required for using data volumes).

```bash
kubectl create configmap kubevirt-config -n kubevirt --from-literal feature-gates=DataVolumes
```

#### Deploy KubeVirt

```bash
kubectl create -f ${KUBEVIRT_DOWNLOAD_URL}/kubevirt-cr.yaml
```

Verify that kubevirt is up and operational:

```bash
kubectl get pods -n kubevirt
```

Once all pods have stared and are operational, proceed to the next step.

## Deploy the GitHub Enterprise Server VM

### Create the data volumes

Two persistent data volumes are needed for the GHES VM:

* `root` is the GHES VM root volume which is initialized from the public 2.17.1 `.qcow2` VM image
* `data` is the persistent data volume where GHES user data is stored

To create these two data volumes:

```bash
export GHES_DOWNLOAD_URL=https://raw.githubusercontent.com/willsmythe/ghes-kubevirt/master
```

#### For Minikube

```bash
kubectl apply -f ${GHES_DOWNLOAD_URL}/ghes-vm-data-volumes.yml
```

#### On Azure AKS

```bash
kubectl apply -f ${GHES_DOWNLOAD_URL}/azure/ghes-vm-data-volumes-premium.yml
```

(this creates the volumes on managed premimum SSD drives versus standard SSD)

Check that the persistent volumes have been created and the import (for root) has completed before creating the VM resource:

```bash
kubectl describe dv ghes-data-dv
kubectl describe dv ghes-root-dv
```

> Note: creating `ghes-root-dv` will take 5-10 minutes.

### Create the VM resource

```bash
kubectl apply -f ${GHES_DOWNLOAD_URL}/ghes-vm.yml
```

Check the status of the VMI:

```bash
kubectl get vmi ghes-vm
```

Or for more details including events:

```bash
kubectl describe vmi ghes-vm
```

### Connect to the VM

To VNC to the VM you first need to install `virtctl`:

```bash
curl -L -o virtctl \
    https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-darwin-amd64

chmod +x virtctl 
```

To open a VNC session to the VM:

```bash
./virtctl vnc ghes-vm
```

> virtctl only supports a handful of VNC clients. If it does not find one, the command will fail. One workaround is to create a `remote-viewer.bat` (see example) or `remote-viewer` shell script and add it to your `$PATH`. Your script should take the single argument (`vnc://ipaddress:port`), adapt it, and launch your preferred VNC program.

## Configure the instance

Before you can access the GitHub Enteprise Server setup wizard (to finish the setup process), you need to enable access to certain TCP ports.

### Enable access to the VM

This exposes certain ports on the VM (80, 443, 8443):

```bash
kubectl apply -f ${GHES_DOWNLOAD_URL}/ghes-vm-services.yml
```

Check the status of the external IP address:

```bash
kubectl get service ghes-vm-http-service
```

### Run the setup experience

Once an external IP address has been established for the `ghes-vm-http-service` service, navigate to the GitHub Enterprise Server setup wizard:

```
http://{publicIP}/setup
```

This may take a minute, and you may be prompted about SSL cert problems.

## Cleanup

To stop the VM:

```bash
./virtctl stop ghes-vm
```

This doesn't delete any data volumes, which means you can restart the VM and pick back up with all of your data:

```bash
./virtctl start ghes-vm
```

Once you are done, the easist way to cleanup the VM and all other resources is to simply delete the Kubernetes cluster you created. For example, on Minikube you can run: `minikube delete -p kubevirt`.

## Troubleshooting

* [cdi image upload pod doesn't start](https://github.com/kubevirt/kubevirt/issues/2184)
* [GHES Admin Guide](https://help.github.com/en/enterprise/2.17/admin)
* [Kubevirt Uninstall/cleanup procedures](https://github.com/kubevirt/kubevirt/issues/1491)

