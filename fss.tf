## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_file_storage_file_system" "FSS" {
  count               = var.create_ffs ? 1 : 0
  availability_domain = var.fss_ad
  compartment_id      = var.fss_compartment
  display_name        = "${local.cluster_name}-fss"
  defined_tags        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

}

resource "oci_file_storage_mount_target" "FSSMountTarget" {
  count               = var.create_ffs ? 1 : 0
  availability_domain = var.fss_ad
  compartment_id      = var.fss_compartment
  subnet_id           = local.subnet_id
  display_name        = "${local.cluster_name}-mt"
  hostname_label      = "fileserver"
  defined_tags        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

}

resource "oci_file_storage_export" "FSSExport" {
  count          = var.create_ffs ? 1 : 0
  export_set_id  = oci_file_storage_mount_target.FSSMountTarget.0.export_set_id
  file_system_id = oci_file_storage_file_system.FSS.0.id
  path           = var.nfs_source_path
  export_options {
    source          = data.oci_core_vcn.vcn.cidr_block
    access          = "READ_WRITE"
    identity_squash = "NONE"
  }

}


