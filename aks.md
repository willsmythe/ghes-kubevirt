
```
export RESOURCE_GROUP=ghes-kubevirt
export CLUSTER=ghes-kubevirt

set PATH=C:\Users\wismythe\.azure-kubectl;%PATH%

```
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name myAKSCluster \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

```
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER
kubectl get nodes
```


```
cat << END > ghes-dv-3-claim.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ghes-dv-3
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: managed-premium
  resources:
    requests:
      storage: 300Gi
END
```

kubectl patch virtualmachine ghes-vm --type merge -p '{"spec":{"running":true}}'


kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --from-literal feature-gates=DataVolumes
