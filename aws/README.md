# Deploying GHES on AWS EKS

> **IMPORTANT**: GHES VM does not currently run on AWS EKS because no standard (non-metal) EC2 instance types support [hardware virtualization](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-system_requirements-kvm_requirements) which is required since the GHES VM does not run in emulation mode (see [issue #6](https://github.com/willsmythe/ghes-kubevirt/issues/6)).

This document has instructions specific to running GitHub Enterprise Server on [Amazon Elastic Container Service for Kubernetes (EKS)](https://aws.amazon.com/eks/).

Once you have the `ghes-kubevirt` Kubernetes cluster up and running, you can follow the [general instructions](../README.md) for deploying KubeVirt and GHES-related resources.

## Pre-reqs

* AWS account with permission to create new resources

## Install and configure tools

1. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

2. [Install kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) (standard Kubernetes CLI)

3. [Install ektctl](https://eksctl.io/) (EKS-specific CLI)

4. [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)
   * You should create an **Administrator** user belonging to a new Administrators group ([see steps](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)) and use the Access Key ID and Secret Access Key for this user to configure the AWS CLI.

## Create the cluster

```
eksctl create cluster \
--name ghes-kubevirt \
--version 1.12 \
--nodegroup-name standard-workers \
--node-type t2.2xlarge \
--nodes 1 \
--nodes-min 1 \
--nodes-max 2 \
--node-ami auto
```

Confirm the cluster is up:

```
kubectl get nodes
```


# Alternate steps (via web console)

> **NOTE**: although you can create the cluster using the web console, it is **significantly** easier to use `eksctl` since it creates all the necessary resource (cluster, security roles, work node groups, EC2 instances, etc) in a single command.

## Create an EKS-managed Kubernetes cluster

### 1. Create service role

> This is required for creating the EKS-managed Kubernetes cluster.

1. Open the IAM console: https://console.aws.amazon.com/iam/

2. Choose **Roles**, then **Create role**.

3. Choose **EKS** from the list of services, then **Allows Amazon EKS to manage your clusters on your behalf** as the use case (bottom of the page).

4. Click **Next: Permissions**, **Next: Tags**, and **Next: Review**.

4. For the role name, use `eksServiceRole`, then click **Create role**.

### 2. Create an EC2 key pair

> This is required for creating the worker nodes used in the cluster.

1. Open https://console.aws.amazon.com/ec2/

2. In the navigation pane (left side), under **NETWORK & SECURITY**, choose **Key Pairs**.

3. Choose **Create Key Pair**.

4. For the key pair name use `ghes-kubevirt`.

5. Click **Create**.

6. The private key file (`ghes-kubevirt.pem`) is automatically downloaded. Save this file to a safe place --- it will be needed later when creating the worker nodes.

For more details, see [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

### 3. Create the cluster

1. Open the Amazon EKS cluster management page: https://console.aws.amazon.com/eks/home#/clusters

2. Click **Create cluster**

3. In the **General configuration** section:
   * For cluster name, use `ghes-kubevirt`
   * For Kubernetes version, Select `1.12` (or later)
   * For role name, select the role created earlier (`eksServiceRole`)

4. In the **Networking** section, for **Security group**, check the box for the group with the description `default VPC security group`.

5. Accept all other default values, and click **Create**.

> It will take about 7-10 minutes for the cluster to be created.

### 3. Add nodes to the cluster

1. Open https://console.aws.amazon.com/cloudformation

2. Click **Create stack**

3. Select **Template is ready**, then select **Amazon S3 URL** and use this URL: `https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/amazon-eks-nodegroup.yaml`

4. Click **Next**.

5. For stack name, use `ghes-kubevirt-worker-nodes`

6. Set these parameter values:
   * EKS Cluster: `ghes-kubevirt`
   * ClusterControlPlaneSecurityGroup: `default (xxxx)`
   * NodeGroupName: `ghes-kubevirt-node-group`
   * NodeAutoScalingGroupMinSize: `1`
   * NodeAutoScalingGroupDesiredCapacity: `1` (sufficient for testing)
   * NodeAutoScalingGroupMaxSize: `2` (or one more than the previous parameter)
   * NodeInstanceType: `c5.4xlarge` (or `t2.2xlarge`)
   * NodeImageId: `ami-04ea7cb66af82ae4a` (assuming **us-east-2** region; for other regions see [Amazon EKS-Optimized AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html))
   * KeyName: `ghes-kubevirt`
   * VpcId: `vpc-xxx` (this was created with the cluster)
   * Subnets: (select all)

7. Click **Next**, then **Next** again.

8. Check the box "I acknowledge that AWS CloudFormation might create IAM resources" and click **Create stack**.

For more details, see [Launching Amazon EKS Worker Nodes](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html).

> This will take a few minutes.

Record the NodeInstanceRole for the node group that was created. You need this when you configure your Amazon EKS worker nodes.


## Other useful resources

1. [Deploying KubeVirt on AWS](https://kubevirt.io/pages/ec2)


