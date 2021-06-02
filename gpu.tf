resource "oci_core_instance" "TF_GPUInstance" {
        count                   = "${var.GPUNode_Count}"
        compartment_id              = "${var.compartment_ocid}"
        availability_domain     = "${var.ad == var.gpu_ad ? data.oci_identity_availability_domain.ad.name : data.oci_identity_availability_domain.gpu_ad.name }" 
        display_name                = "TF_GPUnode${count.index}"
        shape                           = "${var.gpu_shape}"
        source_details {
                source_type = "image"
                source_id   = "${var.image_OracleLinux7_6_GPU[var.region]}"
        }
        subnet_id        = "${oci_core_subnet.TF_GPU_Public_Subnet.id}"
        create_vnic_details {
                subnet_id                   = "${oci_core_subnet.TF_GPU_Public_Subnet.id}"
        }
        metadata {
            ssh_authorized_keys = "${tls_private_key.key.public_key_openssh}"
        }
        
}
