# Deploying to Minikube

## Install

Install minikube using the standard [Minikube install steps](https://kubernetes.io/docs/tasks/tools/install-minikube/).

## Configure

```bash
minikube config -p kubevirt set memory 18g
minikube config -p kubevirt set disk-size 300g
```

### Additional Windows-specific configuration steps

```bash
minikube config -p kubevirt set vm-driver hyperv
minikube config -p kubevirt set hyperv-virtual-switch kubevirt
```

> Note: this assumes a virtual network switch named `kubevirt` has been created.

## Start the instance (on Windows, be sure you are on C: drive, or you will need to delete .minikube from your profile dir and run it again)

```bash
minikube profile kubevirt
minikube start
```

## Next steps

[Follow the steps](README.md) for deploying KubeVirt and the GHES VM.


### Other

Check if the Minikube VM's CPU supports virtualization extensions:

```bash
minikube ssh -p kubevirt "egrep 'svm|vmx' /proc/cpuinfo"
```

If an error occurs, you need to enable the `debug.useEmulation` feature gate (in addition to the data volumes):

```
kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --from-literal feature-gates=DataVolumes
```

> Notes: See [ghes-kubevirt/issues 6](https://github.com/willsmythe/ghes-kubevirt/issues/6) for more details on problems with running the GHES VM in emulation mode (i.e. it doesn't work currently).

Patch an existing config:

``bash
kubectl patch configmap kubevirt-config -n kubevirt -p '{"data":{"feature-gates":"DataVolumes", "debug.useEmulation": "true" }}'
```

Core Minikube commands:

```bash
minikube ip
minikube dashboard
minikube delete
```
