# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# lbaas.tf
#
# Purpose: Creates the Load Balancer Logic and it's depedencies
# Registry: https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/load_balancer_load_balancer
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/load_balancer_listener
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/load_balancer_backend
#           https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/load_balancer_backend_set
#           


resource "oci_load_balancer" "LoadBalancer" {
  shape = var.lb_shape
  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = local.compartment_id

  subnet_ids = [
    local.lbaas_subnet_ocid,
  ]

  display_name               = var.lbaas_display_name
  network_security_group_ids = [oci_core_network_security_group.LBSecurityGroup.id]
}

resource "oci_load_balancer_backend_set" "BackendSet" {
  name             = "ords_bes"
  load_balancer_id = oci_load_balancer.LoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port              = "8080"
    protocol          = "TCP"
    interval_ms       = "10000"
    timeout_in_millis = "3000"
    retries           = "3"
  }
}

resource "oci_load_balancer_listener" "HTTPListener" {
  load_balancer_id         = oci_load_balancer.LoadBalancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.BackendSet.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backend" "Backend" {
  count            = var.num_instances
  load_balancer_id = oci_load_balancer.LoadBalancer.id
  backendset_name  = oci_load_balancer_backend_set.BackendSet.name
  ip_address       = oci_core_instance.Compute[count.index].private_ip
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

