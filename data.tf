data "oci_identity_availability_domain" "ad" {
  compartment_id = "${var.compartment_ocid}"
  ad_number      = "${var.ad}"
}
data "oci_identity_availability_domain" "gpu_ad" {
  compartment_id = "${var.compartment_ocid}"
  ad_number      = "${var.gpu_ad}"
}
