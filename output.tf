output "HeadNodePublicIP" {
  value = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
}
output "HeadNodePrivateIP" {
  value = "${oci_core_instance.TF_HeadNodeInstance.private_ip}"
}
output "ComputeNodePrivateIP" {
  value = ["${oci_core_instance.TF_ComputeInstance.*.private_ip}"]
}
output "GPUNodePublicIP" {
  value = ["${oci_core_instance.TF_GPUInstance.*.public_ip}"]
}
output "Private_key" {
  value = "${tls_private_key.key.private_key_pem}"
}