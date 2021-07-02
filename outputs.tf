## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bastion" {
  value = oci_core_instance.bastion.public_ip
}

output "private_ips" {
  value = join(" ", local.cluster_instances_ips)
}

