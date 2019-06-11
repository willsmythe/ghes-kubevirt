
# GitHub Enterprise Server running in Kubernetes using KubeVirt

## Install tools

* kubectl
* virtctl
  ```
  export KUBEVIRT_VERSION="v0.18.0"
  
  curl -L -o virtctl \
      https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-darwin-amd64

  chmod +x virtctl 
  ```

* minikube
  ```
  minikube config -p kubevirt set memory 17000
  minikube config -p kubevirt set disk-size 300g

  minikube profile kubevirt
  minikube start
  ```
  Additional Windows-specific configuration (note: this assumes a virtual network switch named `kubevirt`)
  ```
  minikube config -p kubevirt set vm-driver hyperv
  minikube config -p kubevirt set hyperv-virtual-switch kubevirt
  ```
   

## CDI and Kubevirt

### Deploy CDI

*Containerized-Data-Importer (CDI) is a persistent storage management add-on for Kubernetes. It's primary goal is to provide a declarative way to build Virtual Machine Disks on PVCs for Kubevirt VMs*

```
export CDI_VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")
```
```
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml
```
```
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator-cr.yaml
```

### Deploy Kubevirt


#### Deploy the operator

```
export KUBEVIRT_VERSION="v0.18.0"
```

```
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml
```

#### Create the configmap

```
kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --from-literal feature-gates=DataVolumes
```

Alternatively, with no `debug.useEmulation`:

```
kubectl create configmap kubevirt-config -n kubevirt --from-literal feature-gates=DataVolumes
```

#### Deploy Kubevirt

```
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml
```

Check that kubevirt is up and operational:

```
kubectl get pods -n kubevirt
```

## GHES VM

### Create data volumes

This will create the `root` and `data` persistent volume claims. `root` is initialized from the GHES `.qcow2` image. `data` is the persistent store for user data.

```
kubectl apply -f https://raw.githubusercontent.com/willsmythe/ghes-kubevirt/master/ghes-vm-data-volumes.yml
```

Alternatively, on AKS (uses managed premium storage):

```
kubectl apply -f https://raw.githubusercontent.com/willsmythe/ghes-kubevirt/master/ghes-vm-data-volumes-aks.yml
```

### Create the VM resource

```
kubectl apply -f https://raw.githubusercontent.com/willsmythe/ghes-kubevirt/master/ghes-vm.yml
```

Check the status of the VMI:

```
kubectl get vmi ghes-vm
```

Or for more details including events:

```
kubectl describe vmi ghes-vm
```

### Connect to the VM

```
virtctl vnc ghes-vm
```

## Other

### Useful commands

```
minikube ip
minikube dashboard
minikube delete
```

### Cleanup

```
minikube delete -p kubevirt
```

### Random commands

```
kubectl delete -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml
set PATH=c:\tools;%PATH%;
export PATH=/c/tools/:$PATH
docker run -it -v C:\work\github\ghe-server:/ghe-server -w /ghe-server ubuntu:18.04 bash
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/%KUBEVIRT_VERSION%/kubevirt-cr.yaml
```

```
kubectl delete configmap kubevirt-config -n kubevirt
```

### Original

```
kubectl apply -f https://gist.githubusercontent.com/gnawhleinad/0151195ea6412bfe39d6b341666ebcc2/raw/b4e35c8bb71b957c01a04bcfe39efdeeaa7a0b9c/github-enterprise-server.yaml
kubectl patch virtualmachine ghes-vm --type merge -p "{\"spec\":{\"running\":true}}"
```

### Links

* cdi image upload pod doesn't start: https://github.com/kubevirt/kubevirt/issues/2184
* https://help.github.com/en/enterprise/2.17/admin
* Kubevirt Uninstall/cleanup procedures: https://github.com/kubevirt/kubevirt/issues/1491


virtctl expose virtualmachineinstance ghes-vm --name vmiservice --port 8080 --target-port 8080
