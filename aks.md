
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

### Switch default storage class (to managed premium)
```
kubectl patch storageclass default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```
```
kubectl patch storageclass managed-premium -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
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

===

### Networking

HTTP application routing

```
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```

3223920f69cd44c58f81.eastus2.aksapp.io

```
cat << END > ghes-http.yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ghes-http
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
  - host: ghes.3223920f69cd44c58f81.eastus2.aksapp.io
    http:
      paths:
      - backend:
          serviceName: management-console-http
          servicePort: 80
        path: /
END
---
cat << END > ghes-https.yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ghes-https
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
  - host: ghes.3223920f69cd44c58f81.eastus2.aksapp.io
    http:
      paths:
      - backend:
          serviceName: management-console-http
          servicePort: 80
        path: /
END

```        

https://kubernetes.github.io/ingress-nginx/deploy/#azure
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml


kubectl label vm ghes-vm kubevirt.io/vm=ghes-vm

kubectl label pod virt-launcher-ghes-vm-hxhhk kubevirt.io/vm=ghes-vm


