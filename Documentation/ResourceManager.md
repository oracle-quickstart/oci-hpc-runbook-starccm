# <img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Images/STARCCM_logo.png" height="60"> Siemens Simcenter STAR-CCM+ Runbook


# Deployment through Resource Manager

**Table of Contents**
- [Deployment through Resource Manager](#deployment-through-resource-manager)
  - [Log In](#log-in)
  - [Resource Manager](#resource-manager)
  - [Add STAR-CCM+ installer to Object Storage](#add-star-ccm-installer-to-object-storage)
  - [Select variables](#select-variables)
  - [Run the stack](#run-the-stack)
  - [Access your cluster](#access-your-cluster)
  

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Resource Manager
In the OCI console, there is a Resource Manager available that will create all the resources needed. 

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Resource Manager and Stacks. 

Create a new stack: <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/stack.png" height="20">

Download the [ZIP file](https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Terraform/starccm.zip) for STAR-CCM+ and upload it as a stack. 

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


## Select variables

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20"> and fill in the variables. 

Headnode:
* CLUSTER AVAILABILITY DOMAIN: Availability Domain of the headnode (1,2 or 3)
* SHAPE OF THE HEADNODE: Shape of the Head Node which is also the Compute Node in our architecture (BM.GPU3.8)
* VNC TYPE FOR THE HEADNODE: Visualization Type for the headnode: none, VNC or X11VNC


Compute nodes:
* NUMBER OF COMPUTE NODES: How many compute nodes in the private network. This does not include the headnode
* SHAPE OF THE COMPUTE NODES: Shape of the Compute Nodes
* HYPERTHREADING: Turn hyperthreading On or Off. STAR-CCM+ performs usually better when it is turned off. 

Visualization Nodes:
* NUMBER OF VISUALIZATION NODES: Number of visualization machines for Pre/Post
* PASSWORD FOR THE VNC SESSIONS: password to use the VNC session on the Pre/Post Node

Visualization Nodes Options:
* VNC TYPE FOR THE VISUALIZATION NODES: Visualization Type for the headnode: none, VNC or X11VNC
* SHAPE OF THE VISUALIZATION NODES: Shape of the Visualization Node (VM.GPU2.1, BM.GPU2.2,...)
* VISUALIZATION NODE AVAILABILITY DOMAIN: Availability Domain of the GPU Machine (1, 2 or 3)

File Storage:
* NVME SHARE DRIVE: Create a NFS shared drive from a NVMe disk on the headnode (Only available if headnode is BM.HPC2.36 or DENSE shapes)
* BLOCK VOLUME SHARE DRIVE: Create a NFS shared drive from block storage. 
* FSS: Create a FSS to be accessible from all nodes. 

Block Options:
* BLOCK VOLUME SIZE ( GB ): Size of the shared block volume

FSS Options:
* AVAILABILITY DOMAIN OF FSS: AD of the FSS mount

STAR-CCM+:
* URL TO DOWNLOAD STAR-CCM+: URL of the installer of STAR-CCM+ (Leave blank if you wish to download later)
* URL TO DOWNLOAD A MODEL TARBALL: URL of the model you wish to run (Leave blank if you wish to download later)
* SHARE DRIVE FOR THE INSTALLER: Drive on which the installer will be installed (NVMe, Block or FSS)
* SHARE DRIVE FOR THE MODEL: Drive on which the installer will be installed (NVMe, Block or FSS)

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


