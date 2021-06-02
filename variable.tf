variable "ad" {
    default = "1"
}
variable "gpu_ad" {
    default = "3"
}

variable "computeNode_Count" {
    default = "2"
}
variable "GPUNode_Count" {
    default = "1"
}

variable "GPUPassword" {
    default = "password"
}

variable "region" { }
variable "tenancy_ocid" { }
variable "user_ocid" { }
variable "fingerprint" { }
variable "private_key_path" {  }
variable "compartment_ocid" { }

variable "compute_shape" {
    default = "BM.HPC2.36"
}
variable "headnode_shape" {
    default = "BM.HPC2.36"
}
variable "gpu_shape" { 
    default = "BM.GPU2.2"
}

variable "installer_url" { 
    default = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/u_crBQofJkBdRvbfs_kogZg6IFDsISxJuTJMXIgkiE0/n/hpc/b/HPC_APPS/o/STAR-CCM+14.04.011_02_linux-x86_64.tar.gz"
}
