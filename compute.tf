# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# compute.tf
#
# Purpose: Create n computes to holster static ORDS front end
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy_assignment      


resource "random_shuffle" "fd" {
  input        = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
  result_count = var.num_instances
}


# Create Compute Instance

resource "oci_core_instance" "Compute" {
  count               = var.num_instances
  availability_domain = var.compute_availability_domain_list[count.index % length(var.compute_availability_domain_list)]
  compartment_id      = local.compartment_id
  display_name        = count.index < "9" ? "${var.compute_display_name_base}${var.label_zs[0]}${count.index + 1}" : "${var.compute_display_name_base}${var.label_zs[1]}${count.index + 1}"
  shape               = var.instance_shape
  fault_domain        = var.fault_domain_name[count.index % length(var.fault_domain_name)]



  dynamic "shape_config" {
    for_each = var.is_flex_shape ? [1] : []
    content {
      memory_in_gbs = var.instance_shape_config_memory_in_gbs
      ocpus         = var.instance_shape_config_ocpus
    }
  }

  source_details {
    source_type             = "image"
    source_id               = local.instance_image
    boot_volume_size_in_gbs = "50"
  }

  create_vnic_details {
    subnet_id        = local.compute_subnet_ocid
    nsg_ids          = [oci_core_network_security_group.WebSecurityGroup.id, oci_core_network_security_group.SSHSecurityGroup.id]
    assign_public_ip = var.assign_public_ip_flag
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_is_path ? file(var.ssh_public_key) : var.ssh_public_key
  }



  timeouts {
    create = "15m"
  }
}

resource "oci_core_volume_backup_policy_assignment" "backup_policy_assignment_BootVolume" {
  count     = var.num_instances
  asset_id  = oci_core_instance.Compute[count.index].boot_volume_id
  policy_id = local.backup_policy_bootvolume_disk_id
}