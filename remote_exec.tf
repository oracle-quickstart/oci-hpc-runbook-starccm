resource "null_resource" "remote-exec-HN" {
  depends_on = ["oci_core_instance.TF_HeadNodeInstance"]

  provisioner "file" {
          destination = "/home/opc/.ssh/id_rsa"
          source = "key.pem"

          connection {
          timeout = "15m"
          host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
          user = "opc"
          private_key = "${tls_private_key.key.private_key_pem}"
          agent = false
          }
      }
  provisioner "file" {
          destination = "/home/opc/hn-start.sh"
          source = "hn-start.sh"

          connection {
          timeout = "15m"
          host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
          user = "opc"
          private_key = "${tls_private_key.key.private_key_pem}"
          agent = false
          }
      }
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "15m"
      host        = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
      user        = "opc"
      private_key = "${tls_private_key.key.private_key_pem}"     
    }

    inline = [
    "sudo chmod 755 ~/hn-start.sh",
    "~/hn-start.sh ${oci_core_virtual_network.TF_VCN.cidr_block} ${oci_core_instance.TF_HeadNodeInstance.private_ip}  | tee ~/hn-start.log",
    ]
  }
}



resource "null_resource" "remote-exec-CN" {
  count = "${var.computeNode_Count}"
  depends_on = ["null_resource.remote-exec-HN"]

  provisioner "file" {
    destination = "/home/opc/.ssh/id_rsa"
    source = "key.pem"

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
  }
  provisioner "file" {
    destination = "/home/opc/cn-start.sh"
    source = "cn-start.sh"

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
    "sudo chmod 755 ~/cn-start.sh",
    "~/cn-start.sh ${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]} ${oci_core_instance.TF_HeadNodeInstance.private_ip} | tee ~/cn-start${count.index}.log",
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
    "sed '/${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}/d' ~/iplist.txt >> ~/new_iplist${count.index}.txt",
    "mv ~/new_iplist${count.index}.txt ~/iplist.txt",
    ]
  }

}



resource "null_resource" "remote-exec-GPU" {
  count = "${var.GPUNode_Count}"
  depends_on = ["null_resource.remote-exec-HN"]

  provisioner "file" {
    destination = "/home/opc/.ssh/id_rsa"
    source = "key.pem"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/gpu-start.sh"
    source = "gpu-start.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "remote-exec" {
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }

    inline = [
    "sudo chmod 755 ~/gpu-start.sh",
    "~/gpu-start.sh ${var.GPUPassword} ${oci_core_instance.TF_HeadNodeInstance.private_ip} | tee ~/gpu-start${count.index}.log",
    ]
  }
}


resource "null_resource" "remote-exec-HN2" {
  count = "${var.computeNode_Count > 0 ? 1 : 0}"
  depends_on = ["oci_core_instance.TF_HeadNodeInstance"]
  triggers {
    current_compute_remote_exec_id = "${element(null_resource.remote-exec-CN.*.id,length(null_resource.remote-exec-CN.*.id)-1)}"
  }
  provisioner "file" {
          destination = "/home/opc/generate_ssh_file.sh"
          source = "generate_ssh_file.sh"

          connection {
          timeout = "15m"
          host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
          user = "opc"
          private_key = "${tls_private_key.key.private_key_pem}"
          agent = false
          }
      }
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "15m"
      host        = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
      user        = "opc"
      private_key = "${tls_private_key.key.private_key_pem}"
    }

    inline = [
    "sudo chmod 755 ~/generate_ssh_file.sh",
    "~/generate_ssh_file.sh",
    ]
  }
}