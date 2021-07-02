## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "bastion_config" {
  template = file("config.bastion")
  vars = {
    key = tls_private_key.ssh.private_key_pem
  }
}

data "template_file" "config" {
  template = file("config.hpc")
}


