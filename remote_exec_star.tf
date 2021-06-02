
resource "null_resource" "remote-exec-HN_STARCCM_Specific" {
  depends_on = ["oci_core_instance.TF_HeadNodeInstance","null_resource.remote-exec-HN",]
  
  provisioner "file" {
    destination = "/mnt/share/disable_ht.sh"
    source = "disable_ht.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/mnt/share/hn-start-starccm.sh"
    source = "hn-start-starccm.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "20m"
      host        = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
      user        = "opc"
      private_key = "${tls_private_key.key.private_key_pem}"
    }

    inline = [
    "chmod 755 /mnt/share/hn-start-starccm.sh", 
    "/mnt/share/hn-start-starccm.sh ${oci_core_instance.TF_HeadNodeInstance.private_ip} ${var.installer_url} | tee /mnt/share/hn-start-starccm.log",
    ]
  }
}


resource "null_resource" "remote-exec-CN_STARCCM_Specific" {
  depends_on = ["null_resource.remote-exec-HN_STARCCM_Specific",]
  count = "${var.computeNode_Count}"


  provisioner "file" {
    destination = "/mnt/share/cn-start-starccm.sh"
    source = "cn-start-starccm.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }
  
  provisioner "remote-exec" {
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false

    bastion_host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    bastion_user = "opc"
    bastion_private_key = "${tls_private_key.key.private_key_pem}"
    }

    inline = [
    "chmod 755 /mnt/share/cn-start-starccm.sh", 
    "/mnt/share/cn-start-starccm.sh ${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}  | tee /mnt/share/cn-start-starccm${count.index}.log",
    ]
  }

provisioner "remote-exec" {
    when = "destroy"
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }

    inline = [
    "sed '/${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}/d' /mnt/share/install/machinelist.txt >> /mnt/share/install/new_machinelist${count.index}.txt",
    "mv /mnt/share/install/new_machinelist${count.index}.txt /mnt/share/install/machinelist.txt",
    ]
  }


}


