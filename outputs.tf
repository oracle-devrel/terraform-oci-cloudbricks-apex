# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# output.tf
#
# Purpose: Show external information after completion


output "SQLDeveloperPublicURL" {
  value = "http://${oci_load_balancer.LoadBalancer.ip_addresses[0]}/ords/sql-developer"
}

output "APEXPublicURL" {
  value = "http://${oci_load_balancer.LoadBalancer.ip_addresses[0]}/ords/apex"
}