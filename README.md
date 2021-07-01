# <img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Images/STARCCM_logo.png" height="60"> Siemens Simcenter STAR-CCM+ Runbook

# Introduction
Simcenter STAR-CCM+ is a complete multiphysics solution for the simulation of products and designs. This Runbook will take you through the process of deploying a Simcenter STAR-CCM+ cluster on Oracle Cloud with low latency networking between the compute nodes. Running Simcenter STAR-CCM+ on Oracle Cloud is quite straightforward, follow along this guide for all the tips and tricks.

<p align="center">
<img src="https://github.com/oci-hpc/oci-hpc-runbook-StarCCM/raw/master/Images/Screenshot 2019-07-09 at 14.50.19.png" height="300" >
 </p>
 
## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `network-security-groups`, `subnets`, and `instances`.

- Quota to create the following resources: 1 VCN, 2 subnets, 1 Internet Gateway, 1 NAT Gateway, 1 Service Gateway, 3 route rules, and minimum 2 compute instances in instance pool or cluster network (plus bastion host).

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-hpc-runbook-starcm/releases/latest/download/oci-hpc-runbook-starccm-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI

### Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna.git
    cd oci-hpc-runbook-lsdyna
    ls

### Set Up and Configure Terraform

1. Complete the prerequisites described [here](https://github.com/cloud-partners/oci-prerequisites).

2. Create a `terraform.tfvars` file, and specify the following variables:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Availablity Domain 
ad = "<availablity doman>" # for example "GrCH:US-ASHBURN-AD-1"

# Bastion 
bastion_ad               = "<availablity doman>" # for example "GrCH:US-ASHBURN-AD-1"
bastion_boot_volume_size = "<bastion_boot_volume_size>" # for example 50
bastion_shape            = "<bastion_shape>" # for example "VM.Standard.E3.Flex"
boot_volume_size         = "<boot_volume_size>" # for example 100
node_count               = "<node_count>" # for example 2
ssh_key                  = "<ssh_key>"
targetCompartment        = "<targetCompartment>" 
use_custom_name          = false
use_existing_vcn         = false
use_marketplace_image    = true
use_standard_image       = true
cluster_network          = false
instance_pool_shape      = "<instance_pool_shape>" # for example VM.Standard.E3.Flex
lsdyna_binaries          = "<lsdyna_binaries>" # for example https://objectstorage.us-phoenix-1.oraclecloud.com/p/CTYj(...)F7V/n/hpc/b/HPC_APPS/o/LS-DYNA_R12.0.0_CentOS-65_AVX2_MPP_S.zip"

````

### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy
    
# Architecture
![](https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/architecture-hpc.png "Architecture for Running StarCCM+ in OCI")
The architecture for this runbook is as follow, we have one small machine (bastion) that you will connect into. The compute nodes will be on a separate private network linked with RDMA RoCE v2 networking. The bastion will be accesible through SSH from anyone with the key (or VNC if you decide to enable it). Compute nodes will only be accessible through the bastion inside the network. This is made possible with 1 Virtual Cloud Network with 2 subnets, one public and one private.

The above baseline infrastructure provides the following specifications:
-	Networking
    -	1 x 100 Gbps RDMA over converged ethernet (ROCE) v2
    -	Latency as low as 1.5 µs
-	HPC Compute Nodes (BM.HPC2.36)
    -	6.4 TB Local NVME SSD storage per node
    -	36 cores per node
    -	384 GB memory per node
    
# Upload LSDYNA binaries to Object Storage
1. Log In

You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your Object Storage Bucket. Click on the current region in the top right dropdown list to select another one. 

2. Go to Buckets by clicking on  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/menu.png?raw=true" height="30">  and selecting **Storage**  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Storage%20option.png?raw=true" height="130">  > **Buckets**  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Buckets.png?raw=true" height="70">

3. Create a bucket by clicking  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Create%20bucket.png?raw=true" height="30">. Give your bucket a name and select the storage tier and encryption.

4. Once the bucket has been created, upload an object (binary) to the bucket by clicking **Upload**  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Upload%20Object.png?raw=true" height="90">  under **Objects**.

5. Create a Pre-Authenitcated Request (PAR) using the following steps:

	- Click on  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/par%20menu.png?raw=true" height="40">  for the object, then select  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Create%20PAR%20button%20from%20menu.png?raw=true" height="30"> 

	- Select  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Object%20option%20PAR%20menu.png?raw=true" height="100">  for the **Pre-Authenticated Request Target** and then select an access type.

	- Click  <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Create%20PAR.png?raw=true" height="30">

	- Be sure to copy the PAR URL by clicking <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-lsdyna/blob/main/images/Copy.png?raw=true" height="30"> before closing because you will **NOT** have access to the URL again.  

6. Add this PAR to the starccm_binaries variable.

# Running STAR-CCM+
Running Star-CCM+ is pretty straightforward: You can either start the GUI if you have a VNC session started with
```
/mnt/share/install/version/STAR-CCM+version/star/bin/starccm+
```
To specify the host you need to run on, you need to create a machinefile. You can generate it as follow, or manually. Format is hostname:corenumber.
```
sed 's/$/:36/' /etc/opt/oci-hpc/hostfile > machinefile
```
To run on multiple nodes, place the model.sim on the nfs-share drive (Ex:/mnt/nfs-share/work/) and replace the CORENUMBER and PODKEY.
```
/mnt/nfs-share/install/15.02.009/STAR-CCM+15.02.009/star/bin/starccm+ -batch -power\\ 
-licpath 1999@flex.cd-adapco.com -podkey PODKEY -np CORENUMBER 
-machinefile machinefile /mnt/nfs-share/work/model.sim
```
## MPI implementations and RDMA
Performances can really differ depending on the MPI that you are using. 3 are supported by Star-CCM+ out of the box.
 *	IBM Platform MPI: Default or flag platform
 *	Open MPI: Flag intel
 *	Intel MPI: Flag openmpi3
To specify options, you can use the flag -mppflags
When using OCI RDMA on a Cluster Network, you will need to specify these options:

### OpenMPI
For RDMA:
```
-mca btl self -x UCX_TLS=rc,self,sm -x HCOLL_ENABLE_MCAST_ALL=0 -mca coll_hcoll_enable 0 -x UCX_IB_TRAFFIC_CLASS=105 -x UCX_IB_GID_INDEX=3 
```
Additionaly, instead of disabling hyper-threading, you can also force the MPI to pin it on the first 36 cores:
```
--cpu-set 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
```
### IntelMPI
For RDMA:
```
-mppflags "-iface enp94s0f0 -genv I_MPI_FABRICS=shm:dapl -genv DAT_OVERRIDE=/etc/dat.conf -genv I_MPI_DAT_LIBRARY=/usr/lib64/libdat2.so -genv I_MPI_DAPL_PROVIDER=ofa-v2-cma-roe-enp94s0f0 -genv I_MPI_FALLBACK=0"
Additionaly, instead of disabling hyper-threading, you can also force the MPI to pin it on the first 36 cores:
-genv I_MPI_PIN_PROCESSOR_LIST=0-33 -genv I_MPI_PROCESSOR_EXCLUDE_LIST=36-71
```

### PlatformMPI
For RDMA:
```
-mppflags "-intra=shm -e MPI_HASIC_UDAPL=ofa-v2-cma-roe-enp94s0f0 -UDAPL"
```
For better performances:
```
-prot -aff:automatic:bandwidth
```
To pin on the first 36 threads:
```
-cpu_bind=MAP_CPU:0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 ,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
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
