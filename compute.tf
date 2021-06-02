resource "oci_core_instance" "TF_HeadNodeInstance" {
        count                   = "1"
        compartment_id              = "${var.compartment_ocid}"
        availability_domain     = "${data.oci_identity_availability_domain.ad.name}" 
        display_name                = "TF_Headnode"
        shape                           = "${var.headnode_shape}"
        source_details {
                source_type = "image"
                source_id   = "${var.image_OracleLinux7_6[var.region]}"
        }     
        subnet_id        = "${oci_core_subnet.TF_Public_Subnet.id}"
        create_vnic_details {
                subnet_id                   = "${oci_core_subnet.TF_Public_Subnet.id}"
        }
        metadata {
            ssh_authorized_keys = "${tls_private_key.key.public_key_openssh}"
        }
        
}
resource "oci_core_instance" "TF_ComputeInstance" {
        count                   = "${var.computeNode_Count}"
        compartment_id              = "${var.compartment_ocid}"
        availability_domain     = "${data.oci_identity_availability_domain.ad.name}"
        display_name                = "TF_Compute${count.index}"
        shape                           = "${var.compute_shape}"
        source_details {
                source_type = "image"
                source_id   = "${var.image_OracleLinux7_6[var.region]}"
        } 
        create_vnic_details {
                subnet_id                   = "${oci_core_subnet.TF_Private_Subnet.id}"
                skip_source_dest_check = "false"
                assign_public_ip = "false"
        }
        subnet_id        = "${oci_core_subnet.TF_Private_Subnet.id}"
        metadata {
            ssh_authorized_keys = "${tls_private_key.key.public_key_openssh}"
        }

        
}
