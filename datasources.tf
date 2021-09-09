# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# datasource.tf
#
# Purpose: The following script defines the lookup logic used in code to obtain pre-created or JIT-created resources in tenancy.


/********** Get latest OCI Linux Image **********/
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = local.compartment_id
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}


/********** Compartment and CF Accessors **********/
data "oci_identity_compartments" "COMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.linux_compute_instance_compartment_name]
  }
}

data "oci_identity_compartments" "ATPCOMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.ATP_instance_compartment_name]
  }
}

data "oci_identity_compartments" "NWCOMPARTMENTS" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  filter {
    name   = "name"
    values = [var.linux_compute_network_compartment_name]
  }
}

data "oci_core_vcns" "VCN" {
  compartment_id = local.nw_compartment_id
  filter {
    name   = "display_name"
    values = [var.vcn_display_name]
  }
}



/********** Subnet Accessors **********/

data "oci_core_subnets" "COMPUTESUBNET" {
  compartment_id = local.nw_compartment_id
  vcn_id         = local.vcn_id
  filter {
    name   = "display_name"
    values = [var.compute_network_subnet_name]
  }
}

data "oci_core_subnets" "LBAASSUBNET" {
  compartment_id = local.nw_compartment_id
  vcn_id         = local.vcn_id
  filter {
    name   = "display_name"
    values = [var.lbaas_network_subnet_name]
  }
}

data "oci_core_subnets" "ATPSUBNET" {
  compartment_id = local.nw_compartment_id
  vcn_id         = local.vcn_id
  filter {
    name   = "display_name"
    values = [var.ATP_network_subnet_name]
  }
}

/********** Backup Policy Accessors **********/

data "oci_core_volume_backup_policies" "BACKUPPOLICYBOOTVOL" {
  filter {
    name = "display_name"

    values = [var.bkp_policy_boot_volume]
  }
}


locals {

  # Subnet OCID local accessors
  compute_subnet_ocid = length(data.oci_core_subnets.COMPUTESUBNET.subnets) > 0 ? data.oci_core_subnets.COMPUTESUBNET.subnets[0].id : null
  lbaas_subnet_ocid   = length(data.oci_core_subnets.LBAASSUBNET.subnets) > 0 ? data.oci_core_subnets.LBAASSUBNET.subnets[0].id : null
  atp_subnet_ocid     = length(data.oci_core_subnets.ATPSUBNET.subnets) > 0 ? data.oci_core_subnets.ATPSUBNET.subnets[0].id : null
  # Compartment OCID Local Accessor
  compartment_id    = lookup(data.oci_identity_compartments.COMPARTMENTS.compartments[0], "id")
  nw_compartment_id = lookup(data.oci_identity_compartments.NWCOMPARTMENTS.compartments[0], "id")

  ATP_compartment_id = lookup(data.oci_identity_compartments.ATPCOMPARTMENTS.compartments[0], "id")

  # VCN OCID Local Accessor
  vcn_id = lookup(data.oci_core_vcns.VCN.virtual_networks[0], "id")

  # Backup policies retrieval by tfvars volume-specifc values 
  backup_policy_bootvolume_disk_id = data.oci_core_volume_backup_policies.BACKUPPOLICYBOOTVOL.volume_backup_policies[0].id

  # Image collector
  instance_image = data.oci_core_images.InstanceImageOCID.images[0].id

  # Accessor for determine if LBaaS is flex shaped 
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}
