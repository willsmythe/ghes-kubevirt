# Packet

kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'


 kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(ip address show label bond0:0 | sed -n 's/[ ]*inet \([^\/]*\).*/\1/p') --kubernetes-version stable-1.14

[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/

## Links

 
 https://www.packet.com/developers/guides/kubeless-on-packet-cloud/
* https://computingforgeeks.com/how-to-run-minikube-on-kvm/
* https://github.com/packethost/csi-packet


##

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.99.97.131:6443 --token fxuf1u.fl6odp2troo1utfc \
    --discovery-token-ca-cert-hash sha256:1e49932c176633676896b2f7e44492d6cfc3d27376282b6e7025e4f95812ab4f



## Flannel

export FLANNEL_RELEASE="v0.11.0"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/$FLANNEL_RELEASE/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/$FLANNEL_RELEASE/Documentation/k8s-manifests/kube-flannel-rbac.yml



kubectl apply -f https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/setup.yaml

kubectl apply -f https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/node.yaml

kubectl apply -f https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/controller.yaml



## Taint (single master node)

https://github.com/kubernetes/kubernetes/issues/65473

```
kubectl taint nodes $(hostname) node-role.kubernetes.io/master:NoSchedule-
```