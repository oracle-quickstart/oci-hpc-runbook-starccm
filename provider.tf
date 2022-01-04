## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  api_fingerprint      = var.api_fingerprint
  api_user_ocid        = var.api_user_ocid
  api_user_key = var.api_user_key
}

provider "oci" {
  alias                = "homeregion"
  tenancy_ocid         = var.tenancy_ocid
  api_user_ocid          = var.api_user_ocid
  api_fingerprint          = var.api_fingerprint
  api_user_key     = var.api_user_key
  region               = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  disable_auto_retries = "true"
}