# Deploy GHES on managed Kubernetes instance running on Packet

Documentation for setting up a Kubernetes instances on [Package](https://www.packet.com).

> **IMPORTANT**: after separate attempts (standalone Kubernetes install and a minikube install) getting GHES to work on a self-managed Kubernetes cluster running on a Packet VM was abandoned due to an issue with the Container Storage Interface (CSI) plugin for Packet. A CSI plugin acts as an interface between Kubernetes and Packet's storage services, enabling persistent volumes to be created and attached. See [Issue #23: Volumes get created but mounting fails](https://github.com/packethost/csi-packet/issues/23) for more details.

## Useful links

* https://www.packet.com/developers/guides/kubeless-on-packet-cloud/
* https://computingforgeeks.com/how-to-run-minikube-on-kvm/
* https://github.com/packethost/csi-packet
