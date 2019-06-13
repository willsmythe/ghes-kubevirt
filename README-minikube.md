# Deploying to minikube

## Install

Follow the [general install steps](https://kubernetes.io/docs/tasks/tools/install-minikube/)

## Configure

```
minikube config -p kubevirt set memory 17000
minikube config -p kubevirt set disk-size 300g
```

### Additional Windows-specific configuration steps

```
minikube config -p kubevirt set vm-driver hyperv
minikube config -p kubevirt set hyperv-virtual-switch kubevirt
```

> Note: this assumes a virtual network switch named `kubevirt` has been created.

## Start the instance

```
minikube profile kubevirt
minikube start
```

## Next steps

[Follow the steps](README.md) for deploying KubeVirt and the GHES VM.


### Other

Check if the minikube VM's CPU supports virtualization extensions:

```
minikube ssh -p kubevirt "egrep 'svm|vmx' /proc/cpuinfo"
```

If an error occurs, you need to enable the `debug.useEmulation` feature gate (in addition to the data volumes):

```
kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --from-literal feature-gates=DataVolumes
```

``
kubectl patch configmap kubevirt-config -n kubevirt -p '{"data":{"feature-gates":"DataVolumes", "debug.useEmulation": "true" }}'
```

```
minikube ip
minikube dashboard
minikube delete
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
