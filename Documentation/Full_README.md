# <img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Images/STARCCM_logo.png" height="60"> Siemens Simcenter STAR-CCM+ Runbook

# Introduction
This Runbook will take you through the process of deploying one or multiple machines on Oracle Cloud Infrastructure, installing Simcenter STAR-CCM+, configuring the license, and then running a model.

Simcenter STAR-CCM+ is a complete multiphysics solution for the simulation of products and designs.

Running Simcenter STAR-CCM+ on Oracle Cloud Infrastructure is quite straightforward, follow along this guide for all the tips and tricks. 
<p align="center">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Images/Screenshot 2019-07-09 at 14.50.19.png" height="300" >
 </p>
 
**Table of Contents**
- [Introduction](#introduction)
- [Architecture](#architecture)
- [Deployment through Resource Manager](#deployment-through-resource-manager)
  - [Log In](#log-in)
  - [Resource Manager](#resource-manager)
  - [Add STAR-CCM+ installer to Object Storage](#add-star-ccm-installer-to-object-storage)
  - [Select variables](#select-variables)
  - [Run the stack](#run-the-stack)
  - [Access your cluster](#access-your-cluster)
- [Deployment through Terraform Script](#deployment-through-terraform-script)
  - [Terraform Installation](#terraform-installation)
  - [Using terraform](#using-terraform)
    - [Configure](#configure)
    - [Run](#run)
    - [Destroy](#destroy)
- [Deployment via web console](#deployment-via-web-console)
  - [Log In](#log-in-1)
  - [Virtual Cloud Network](#virtual-cloud-network)
    - [Subnets](#subnets)
    - [NAT Gateway](#nat-gateway)
    - [Security List](#security-list)
    - [Route Table](#route-table)
    - [Subnet](#subnet)
  - [Compute Instance](#compute-instance)
  - [Mounting a drive](#mounting-a-drive)
  - [Creating a Network File System](#creating-a-network-file-system)
    - [Headnode](#headnode)
    - [Compute Nodes](#compute-nodes)
  - [Allow communication between machines](#allow-communication-between-machines)
  - [Adding a GPU Node for pre/post processing](#adding-a-gpu-node-for-prepost-processing)
  - [Set up a VNC](#set-up-a-vnc)
  - [Accessing a VNC](#accessing-a-vnc)
  - [Installation](#installation)
    - [Connecting all compute node](#connecting-all-compute-node)
    - [Create a machinefile](#create-a-machinefile)
    - [Disable Hyperthreading](#disable-hyperthreading)
- [Installing STAR-CCM+](#installing-star-ccm)
- [Running the Application](#running-the-application)
- [Benchmark Example](#benchmark-example)
  - [17 Millions Cells](#17-millions-cells)
  - [105 Millions Cells](#105-millions-cells)
 
# Architecture
The architecture for this runbook is as follow, we have one main machine (The headnode) that will start the jobs. Other machines (Compute Nodes) will be accessible from the headnode and STAR-CCM+ will distribute the jobs to the compute nodes. The headnode will be accesible through SSH from anyone with the key (or VNC if you decide to enable it) Compute nodes will only be accessible from inside the network. This is made possible with 1 Virtual Cloud Network with 2 subnets, one public and one private.   

![](https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/HPC_arch_draft.png "GPU Architecture for Running HFSS in OCI")

# Deployment

Deploying this architecture on OCI can be done in different ways.
* The [resource Manager](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/ResourceManager.md#deployment-through-resource-manager) let you deploy it from the console. Only relevant variables are shown but others can be changed in the zip file. 
* [Terraform](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/terraform.md#terraform-installation) is a scripting language for deploying resources. It is the foundation of the Resource Manager, using it will be easier if you need to make modifications to the terraform stack often. 
* The [web console](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/ManualDeployment.md#deployment-via-web-console) let you create each piece of the architecture one by one from a webbrowser. This can be used to avoid any terraform scripting or using existing templates. 

# Deployment through Resource Manager

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Resource Manager
In the OCI console, there is a Resource Manager available that will create all the resources needed. 

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Resource Manager and Stacks. 

Create a new stack: <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/stack.png" height="20">

Download the [ZIP file](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Terraform/starccm.zip) for STAR-CCM+

Add you private key to the zip file

Upload the ZIP file

Choose the Name and Compartment

## Add STAR-CCM+ installer to Object Storage
Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Object Storage and Object Storage.

Create a new bucket or select an existing one. To create one, click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">

Leave the default options: Standard as Storage tiers and Oracle-Managed keys. Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">

Click on the newly created bucket name and then select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">

Select your file and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">

Click on the 3 dots to the right side of the object you just uploaded <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/3dots.png" height="20"> and select "Create Pre-Authenticated Request". 

In the following menu, leave the default options and select an expiration date for the URL of your installer. Click on  <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/pre_auth.png" height="25">

In the next window, copy the "PRE-AUTHENTICATED REQUEST URL" and keep it. You will not be able to retrieve it after you close this window. If you loose it or it expires, it is always possible to recreate another Pre-Authenticated Request that will generate a different URL. 


## Select variables

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20"> and fill in the variables. 

* AD: Availability Domain of the cluster (1,2 or 3)
* COMPUTENODE_COUNT: Number of compute machines (Integer)
* COMPUTE_SHAPE: Shape of the Compute Node (BM.HPC2.36)
* HEADNODE_SHAPE: Shape of the Head Node which is also a Compute Node in our architecture (BM.HPC2.36)
* GPUNODE_COUNT: Number of GPU machines for Pre/Post
* GPUPASSWORD: password to use the VNC session on the Pre/Post Node
* GPU_AD: Availability Domain of the GPU Machine (1, 2 or 3)
* GPU_SHAPE: Shape of the Compute Node (VM.GPU2.1, BM.GPU2.2,...)
* INSTALLER_URL: URL of the installer of STAR-CCM+

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20">

Review the informations and click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create.png" height="20">

## Run the stack

Now that your stack is created, you can run jobs. 

Select the stack that you created.
In the "Terraform Actions" dropdown menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/tf_actions.png" height="20">, run terraform apply to launch the cluster and terraform destroy to delete it. 

## Access your cluster

Once you have created your cluster, if you gave a valid URL for the STAR-CCM+ installation, no other action will be needed except [running your jobs](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/STAR-CCM%2B.md#running-the-application).

Public IP addresses of the created machines can be found on the lower left menu under Outputs. 

The Private Key to access the machines can also be found there. Copy the text in a file on your machine, let's say /home/user/key. 

```
chmod 600 /home/user/key
ssh -i /home/user/key opc@ipaddress
```

Access to the GPU instances can be done through a SSH tunnel:

```
ssh -i /home/user/key -x -L 5902:127.0.0.1:5900 opc@ipaddress
```

And then connect to a VNC viewer with localhost:2.

[More information](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/ManualDeployment.md#accessing-a-vnc) about using a VNC session. 


# Deployment through Terraform Script

## Terraform Installation

Download the binaries on the [terraform website](https://www.terraform.io/) and unzip the package. Depending on your Linux distribution, it should be similar to this:

```
tf_install_dir=~/tf_install_dir
cd $tf_install_dir
wget https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_amd64.zip
unzip terraform_0.12.0_linux_amd64.zip
echo export PATH="\$PATH:$tf_install_dir" >> ~/.bashrc
source ~/.bashrc
```

To check that the installation was done correctly: `terraform -version` should return the version. 

## Using terraform
### Configure
Download the zip file and unzip the content:
* [Cluster](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Terraform/tf_starccm.zip)

Edit the file terraform.tfvars for your settings, info can be found [on the terraform website](https://www.terraform.io/docs/providers/oci/index.html#authentication)

* Tenancy_ocid
* User_ocid
* Compartment_ocid
* Private_key_path
* Fingerprint
* SSH_private_key_path
* SSH_public_key
* Region

**Note1: For Compartment_ocid: To find your compartment ocid, go to the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> and select Identity, then Compartments. Find the compartment and copy the ocid.**

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/compartment_OCID.png" height="150">

**Note2: The private_key_path and fingerprint are not related to the ssh key to access the instance. You can create using those [instructions](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm). The SSH public and private keys can be generated like [this](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm)**


In the variable.tf file, you can change the availability domain, the number of compute nodes, the number of GPU nodes, the shapes of the instances,... 

### Run
```
cd <folder>
terraform init
terraform plan
terraform apply
```

**If you wish to add or remove nodes after the setup has happened, just modify the variable in the variable.tf file and rerun the `terraform apply` command**

### Destroy
```
cd <folder>
terraform destroy
```

## Access your cluster

Once you have created your cluster, if you gave a valid URL for the STAR-CCM+ installation, no other action will be needed except [running your jobs](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/STAR-CCM%2B.md#running-the-application).

Public IP addresses are written at the end of the run. 

The key to log on to your cluster has been created in your main directory as key.pem

```
ssh -i /home/user/key.pem opc@ipaddress
```

Access to the GPU instances can be done through a SSH tunnel:

```
ssh -i /home/user/key.pem -x -L 5902:127.0.0.1:5900 opc@ipaddress
```

And then connect to a VNC viewer with localhost:2.

[More information](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Documentation/ManualDeployment.md#accessing-a-vnc) about using a VNC session. 


# Deployment via web console

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Virtual Cloud Network
Before creating an instance, we need to configure a Virtual Cloud Network. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

On the next page, select the following: 
* Name of your VCN
* Compartment of your VCN
* Choose "CREATE VIRTUAL CLOUD NETWORK PLUS RELATED RESOURCES"

Scroll all the way down and <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

Close the next window. 

### Subnets
If you are using one compute node, the subnet was created during the VNC creation. If you want to create a cluster, we will generate a private subnet for the compute nodes, accessible only from the headnode.

Before we generate a private subnet, we will define a security rule to be able to access it from the headnode. We would also like to download packages on our compute nodes, we will create a NAT gateway to be able to access online repositories to update the machine. 

### NAT Gateway
You have just created a VCN, click on the name.
In the ressource menu on the left side of the page, select NAT Gateways.

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/resources_menu.png" height="200">

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">

Choose a name (Ex:STARCCM_NAT) and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">


### Security List
In the ressource menu on the left side of the page, select Security Lists.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

Select a name like STARCCM_Private_SecList

Add an Ingress Rule with CIDR 10.0.0.0/16 and select All Protocols

Add an Egress Rule with CIDR 0.0.0.0/0 and select All Protocols

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

To allow the creation of a Network File System, we also need to add sa couple of ingress rules for the Default Security List for STARCCM_VCN. Click on "Default Security List for STARCCM_VCN" in the list. 

Add one ingress rules for all ports on TCP for NFS. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 10.0.0.0/16
* IP PROTOCOL: TCP
* Source Port Range: All
* Destination Port Range: All
Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

Add another ingress rule for UDP for NFS:

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 10.0.0.0/16
* IP PROTOCOL: UDP
* Source Port Range: All
* Destination Port Range:111,2049
Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 


### Route Table
In the ressource menu on the left side of the page, select Route Tables.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

Change the name to STARCCM_Private_RT

Click + Additional Route Rule and select the settings:

* TARGET TYPE : NAT Gateway
* DESTINATION CIDR BLOCK : 0.0.0.0/0
* TARGET NAT GATEWAY : STARCCM_NAT

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

### Subnet
In the ressource menu on the left side of the page, select Subnets.
Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

Choose the following settings:

* NAME : STARCCM_Private_Subnet
* TYPE: "REGIONAL"
* CIDR BLOCK: 10.0.3.0/24
* ROUTE TABLE: STARCCM_Private_RT
* SUBNET ACCESS: "PRIVATE SUBNET"
* SECURITY LIST: STARCCM_Private_SecList

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

## Compute Instance
Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Instances.png" height="300">

On the next page, select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="25">

On the next page, select the following:
* Name of your instance
* Availibility Domain: Each region has multiple availability domain. Some instance shapes are only available in certain AD.
* Change the image source to Oracle Linux 7.6
* Instance Type: Select Bare metal
* Instance Shape: 
  * BM.HPC2.36
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* SSH key: Attach your public key file. [For more information](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).
* Virtual Cloud Network: Select the network that you have previsouly created. In the case of a cluster: Select the public subnet for the Headnode and the Private Subnet for the compute nodes.

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="20">

After a few minutes, the instances will turn green meaning it is up and running. You can now SSH into it. After clicking on the name of the instance, you will find the public IP. You can now connect using `ssh opc@xx.xx.xx.xx` from the machine using the key that was provided during the creation. 

For a compute node to be able to access the NAT Gateway, select the compute node and in the Resources menu on the left, click on Attached VNICs. 

Hover over the three dots at the end of the line and select "Edit VNIC"

Uncheck "Skip Source/Destination Check"

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/updateVNIC.png" height="20">

Restart This section for each compute instance. Before you do that, we will create a ssh key specific for the cluster to allow all machines to talk to each other using ssh. Log on to the headnode you created and run the command `ssh-keygen`. Do not change the file location (/home/opc/.ssh/id_rsa) and hit enter when asked about a passphrase (twice). Or run this command:

```cat /dev/zero | ssh-keygen -q -N ""```

Add the content of id_rsa.pub into the file /home/opc/.ssh/authorized_keys. You will also use the content of id_rsa.pub as the public key when creating your compute nodes. 

```cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys```

## Mounting a drive

HPC machines have local NVMe storage but it is not mounted by default. Let's take care of that! 

After logging in using ssh, run the command `lsblk`. 
The drive should be listed with the NAME on the left (Probably nvme0n1, if it is different, change it in the next commands)

The headnode will have the shared drive with the installation and the model. This will be shared between all the different compute nodes. Each compute node will also mount the drive to be running locally on a NVMe drive. In this example the share directory will be 500 GB but feel free to change that.  

If your headnode is also a compute node, you can partition the drive. 

Make sure gdisk is installed : ` sudo yum -y install gdisk `
Let's use it: 
```
sudo gdisk /dev/nvme0n1
> n      # Create new partition
> 1      # Partition Number
>        # Default start of the partition
> +500G  # Size of the shared partition
> 8300   # Type = Linux File System
> n      # Create new partition
> 2      # Partition Number
>        # Default start of the partition
>        # Default end of the partition, to fill the whole drive
> 8300   # Type = Linux File System
> w      # Write to file
> Y      # Accept Changes
```

Format the drive on the compute node:
```
sudo mkfs -t ext4 /dev/nvme0n1
```

Format the partitions on the headnode node:
```
sudo mkfs -t ext4 /dev/nvme0n1p1
sudo mkfs -t ext4 /dev/nvme0n1p2
```

Create a directory and mount the drive to it. For the headnode, select `/mnt/share` as the mount directory for the 500G partition and `/mnt/local` for the larger one. For compute node, select `/mnt/local` as the mount directory of the whole drive.

Compute Node:
```
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1 /mnt/local
sudo chmod 777 /mnt/local
```

Head Node:
```
sudo mkdir /mnt/share
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1p1 /mnt/share
sudo mount /dev/nvme0n1p2 /mnt/local
sudo chmod 777 /mnt/share
sudo chmod 777 /mnt/local
```


## Creating a Network File System

### Headnode

Since the headnode is in a public subnet, we will keep the firewall up and add an exception through. 
```
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload
```
We will also activate the nfs-server:

```
sudo yum -y install nfs-utils
sudo systemctl enable nfs-server.service
sudo systemctl start nfs-server.service
```

Edit the file /etc/exports with vim or your favorite text editor. `sudo vi /etc/exports` and add the line `/mnt/share   10.0.0.0/16(rw)`

To activate those changes:

```
sudo exportfs -a
```

### Compute Nodes

On the compute nodes, since they are in a private subnet with security list restricting access, we can disable it altogether. We will also install the nfs-utils tools and mount the drive. You will need to grab the private IP address of the headnode. You can find it in the instance details in the webbrowser where you created the instances, or find it by running the command `ifconfig` on the headnode. It will probably be something like 10.0.0.2, 10.0.1.2 or 10.0.2.2 depending on the CIDR block of the public subnet. 

```
sudo systemctl stop firewalld
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo mount 10.0.0.2:/mnt/share /mnt/share
```


## Allow communication between machines
After creating the headnode, you generated a key for the cluster using `ssh.keygen`. We will need to send the file `~/.ssh/id_rsa` on all compute nodes. On the headnode, run ```scp /home/opc/.ssh/id_rsa 10.0.3.2:/home/opc/.ssh``` and run it for each compute node by changing the IP address. 

## Adding a GPU Node for pre/post processing

Simcenter STAR-CCM+ can let you take advantage of the power of GPUs for post-processing your model. We can turn a GPU node on demand while the simulation is done. 

Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Instances.png" height="300">

On the next page, select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="25">

On the next page, select the following:
* Name of your instance
* Availibility Domain: Each region has multiple availability domain. Some instance shapes are only available in certain AD.
* Change the image source to Oracle Linux 7.6
* Instance Type: Select Bare metal for BM.GPU2.2 or Virtual Machine for VM.GPU2.1
* Instance Shape: 
  * BM.GPU2.2
  * VM.GPU2.1
  * BM.GPU3.8
  * VM.GPU3.*
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* SSH key: Attach your public key file. [For more information](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).
* Virtual Cloud Network: Select the network that you have previsouly created. In the case of a cluster: Select the public subnet.

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="20">

After a few minutes, the instances will turn green meaning it is up and running. You can now SSH into it. After clicking on the name of the instance, you will find the public IP. You can now connect using `ssh opc@xx.xx.xx.xx` from the machine using the key that was provided during the creation. 

Use SSH to remote login to the machine and mount the share drive as show before: 

```
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo mount 10.0.0.2:/mnt/share /mnt/share
```

You will need to follow the steps to set up a VNC session described below. Once you did that, in STAR-CCM+, select Tools from the top menu then options and visualization. In the GPU Utilization, select Default, Unmanaged or Opportunistic to utilize the GPU. The difference in the visualization modes are explained in the STAR-CCM+ Documentation under "Controlling Graphics Performance"


## Set up a VNC
If you used terraform to create the cluster, this step has been done already for the GPU instance.

By default, the only access to the CentOS machine is through SSH in a console mode. If you want to see the Ansys EDT interface, you will need to set up a VNC connection. The following script will work for the default user opc. The password for the vnc session is set as "password" but it can be edited in the next commands. 

```
sudo yum -y groupinstall "Server with GUI"
sudo yum -y install tigervnc-server mesa-libGL
sudo systemctl set-default graphical.target
sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:0.service
sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:0.service
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo "password" | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
sudo systemctl start vncserver@:0.service
sudo systemctl enable vncserver@:0.service
```

## Accessing a VNC
We will connect through an SSH tunnel to the instance. On your machine, connect using ssh 

```
ssh -x -L 5902:127.0.0.1:5900 opc@public_ip
```

You can now connect using any VNC viewer using localhost:2 as VNC server and the password you set during the vnc installation. 

If you would rather connect without a SSH tunnel. You will need to open ports 5900 and 5901 on the Linux machine both in the firewall and in the security list. 

```
sudo firewall-offline-cmd --zone=public --add-port=5900-5901/tcp
```

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

Select the VCN that you created. Select the Subnet in which the machine reside, probably your public subnet. Select the security list. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 0.0.0.0/0
* IP PROTOCOL: TCP
* Source Port Range: All
* Destination Port Range: 5900-5901
Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

Now you should be able to VNC to the address: ip.add.re.ss:5900

Once you accessed your VNC session, you should go into Applications, then System Tools Then Settings.  

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/CentOSSeetings.jpg" height="100"> 

In the power options, set the Blank screen timeout to "Never". If you do get locked out of your user session, you can ssh to the instance and set a password for the opc user. 

```
sudo passwd opc
```

# Installation
This guide will show the different steps for the Oracle Linux 7.6 image available on Oracle Cloud Infrastructure. 
If you have used the terraform or Resource Manager approach, only the download and installation of STAR-CCM+ on the headnode is needed. 

## Connecting all compute node

If you used terraform to create the cluster, this step has been done already. 
Each compute node needs to be able to talk to each compute node. SSH communication works but RSM has some issue if you don't have each host in the known host file. You can compute it using the CIDR block of you private subnet. 

```
sudo yum install -y nmap
nmap -sn 10.0.3.0/24 | grep "scan report" | sed -e 's/.*(\(.*\)).*/\1/' > iplist.txt
```

Run those commands to download the script to register each node with all the other nodes.

```
wget https://github.com/oci-hpc/oci-hpc-runbook-HFSS/raw/master/scripts/generate_ssh_file.sh
chmod 777 generate_ssh_file.sh
./generate_ssh_file.sh
```

## Create a machinefile

If you used terraform to create the cluster, this step has been done already. 
STAR-CCM+ on the headnode does not automatically know which compute nodes are available. You can create a machinefile at `/mnt/share/install/machinefile.txt` with the private IP address of all the nodes along with the number of CPUs available. 

```
10.0.0.2:72
10.0.3.2:72
10.0.3.3:72
privateIP:cores_available
...
```

## Disable Hyperthreading

If you used terraform to create the cluster, this step has been done already. 
Siemens recommmend to turn off hyperthreading on your compute nodes to get better performances. This means that you have only one thread per CPU. By default, on HPC shapes, you have 36 CPU with 2 threads. You can turn it off like this:
```
for i in {36..71}; do
   echo "Disabling logical HT core $i."
   echo 0 | sudo tee /sys/devices/system/cpu/cpu${i}/online;
done
```

# Installing STAR-CCM+
There are a couple of library that need to be added to the Oracle Linux image on the headnode and the compute nodes.

```
sudo yum -y install libSM libX11 libXext libXt
```

You can download the STAR-CCM+ installer from the Siemens PLM website or push it to your machine using scp. 
`scp /path/own/machine/STAR-CCM_version.zip "opc@1.1.1.1:/home/opc/"`

Without a VNC connection, a silent installation needs to be done. 

```
mkdir /mnt/share/install
/path/own/machine/installscript.sh -i silent -DINSTALLDIR=/mnt/share/install/
```

If you would like to include the installation in the Resource Manager or terraform script. Unzip the files and edit the file hn-start-starccm.sh

# Running the Application
Running Star-CCM+ is pretty straightforward: 
You can either start the GUI if you have a VNC session started with 
```
/mnt/share/install/version/STAR-CCM+version/star/bin/starccm+
```
To run on multiple nodes, place the model.sim in `/mnt/share/work/` and replace the number of cores used in total as the np argument. 

```
/mnt/share/install/14.04.011/STAR-CCM+14.04.011/star/bin/starccm+ -batch -power -licpath 1999@flex.cd-adapco.com -podkey ++AaAaaaAAaAAAAAAAAAaa -np 106 -machinefile /mnt/share/install/machinelist.txt /mnt/share/work/model.sim
```

# Benchmark Example
<p align="center">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Images/lemans.png" height="300">
</p>
Performances of STAR-CCM+ are often measured using the LeMans benchmark with 17 and 105 Millions cells. The next graphs are showing how using more nodes impact the runtime, with a scaling really close to 100%. RDMA network, which has not been discussed in this runbook, only start to differentiate versus regular TCP runs if the Cells / Core ratio starts to go down.  

## 17 Millions Cells

<p align="center">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Images/RunTime_17M.png" height="350">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Images/scaling_17M.png" height="350">
</p>

## 105 Millions Cells

<p align="center">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Images/RunTime_105M.png" height="350">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/blob/master/Images/Scaling_105M.png" height="350">
</p>
