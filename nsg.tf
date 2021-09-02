# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# nsg.tf
#
# Purpose: Create the Network Security Groups needed to assemble the architecture
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule


resource "oci_core_network_security_group" "ATPSecurityGroup" {
  compartment_id = local.nw_compartment_id
  display_name   = "ATPSecurityGroup"
  vcn_id         = local.vcn_id


  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "oci_core_network_security_group_security_rule" "ATPSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.compute_network_subnet_cidr_block
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "ATPSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.ATPSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.compute_network_subnet_cidr_block
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}


resource "oci_core_network_security_group" "WebSecurityGroup" {
  compartment_id = local.nw_compartment_id
  display_name   = "WebSecurityGroup"
  vcn_id         = local.vcn_id
}

resource "oci_core_network_security_group_security_rule" "WebSecurityEgressATPGroupRule" {
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = oci_core_network_security_group.ATPSecurityGroup.id
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "WebSecurityEgressInternetGroupRule" {
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.lbaas_subnet_cidr_block
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "WebSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.WebSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.lbaas_subnet_cidr_block
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 8080
      min = 8080
    }
  }
}

resource "oci_core_network_security_group" "LBSecurityGroup" {
  compartment_id = local.nw_compartment_id
  display_name   = "LBSecurityGroup"
  vcn_id         = local.vcn_id
}


resource "oci_core_network_security_group_security_rule" "LBSecurityEgressInternetGroupRule" {
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}


resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}


resource "oci_core_network_security_group" "SSHSecurityGroup" {
  compartment_id = local.nw_compartment_id
  display_name   = "SSHSecurityGroup"
  vcn_id         = local.vcn_id

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}


resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}