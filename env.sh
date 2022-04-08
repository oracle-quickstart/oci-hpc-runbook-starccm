export TF_VAR_user_ocid="<USER_OCID>"
export TF_VAR_fingerprint="<FINGERPRINT>"
export TF_VAR_tenancy_ocid="<TENANCY OCID>"
export TF_VAR_region="<REGION IDENTIFIER>"
export TF_VAR_targetCompartment="COMPARTMENT OCID"
export TF_VAR_vcn_subnet=172.16.0.0/21
export TF_VAR_public_subnet=172.16.0.0/24
export TF_VAR_private_subnet=172.16.1.0/24
export TF_VAR_ad="<AVAILABILITY DOMAIN NAME - CLUSTER NODE>" #kWVD:AP-OSAKA-1-AD-1
export TF_VAR_bastion_ad="<AVAILABILITY DOMAIN NAME - BASTION NODE>"
export TF_VAR_ssh_key=$(cat ~/.ssh/id_rsa.pub)
export TF_VAR_bastion_boot_volume_size=50
export TF_VAR_bastion_shape="VM.Standard2.1"
export TF_VAR_boot_volume_size=50
export TF_VAR_node_count=1
export TF_VAR_use_marketplace_image=true
export TF_VAR_use_standard_image=true
export TF_VAR_cluster_network_shape="BM.HPC2.36"

# set   TF_VAR_ variables: $ source env.sh
# unset TF_VAR_ variables: $ unset ${!TF_VAR_@}
