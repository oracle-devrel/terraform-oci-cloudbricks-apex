# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# variables.tf 
#
# Purpose: The following file declares all variables used in this backend repository

/********** Provider Variables NOT OVERLOADABLE **********/

variable "region" {
  description = "Target region where artifacts are going to be created"
}

variable "tenancy_ocid" {
  description = "OCID of tenancy"
}

variable "user_ocid" {
  description = "User OCID in tenancy."
}

variable "fingerprint" {
  description = "API Key Fingerprint for user_ocid derived from public API Key imported in OCI User config"
}

variable "private_key_path" {
  description = "Private Key Absolute path location where terraform is executed"

}

/********** Provider Variables NOT OVERLOADABLE **********/

/********** Brick Variables **********/

/********** Compute SSH Key Variables **********/
variable "ssh_public_is_path" {
  description = "Describes if SSH Public Key is located on file or inside code"
  default     = false
}

variable "ssh_private_is_path" {
  description = "Describes if SSH Private Key is located on file or inside code"
  default     = false
}

variable "ssh_public_key" {
  description = "Defines SSH Public Key to be used in order to remotely connect to compute instance"
  type        = string

}

variable "ssh_private_key" {
  description = "Private key to log into machine"

}
/********** Compute SSH Key Variables **********/

/********** Compute Variables **********/
variable "num_instances" {
  description = "Amount of instances to create"
  default     = 0
}

variable "label_zs" {
  type        = list(any)
  description = "Auxiliary variable to concatenate with compute number"
  default     = ["0", ""]
}


variable "compute_display_name_base" {
  description = "Defines the compute and hostname Label for created compute"
}

variable "instance_shape" {
  description = "Defines the shape to be used on compute creation"
}

variable "fault_domain_name" {
  type        = list(any)
  description = "Describes the fault domain to be used by machine"
  default     = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]

}


variable "assign_public_ip_flag" {
  description = "Defines either machine will have or not a Public IP assigned. All Pvt networks this variable must be false"
  default     = false
}

variable "bkp_policy_boot_volume" {
  description = "Describes the backup policy attached to the boot volume"
  default     = "gold"
}


variable "linux_compute_instance_compartment_name" {
  description = "Defines the compartment name where the infrastructure will be created"
}

variable "linux_compute_network_compartment_name" {
  description = "Defines the compartment where the Network is currently located"
}


variable "instance_shape_config_memory_in_gbs" {
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes."
  default     = ""
}

variable "instance_shape_config_ocpus" {
  description = "(Updatable) The total number of OCPUs available to the instance."
  default     = ""
}

variable "is_flex_shape" {
  description = "Boolean that describes if the shape is flex or not"
  default     = false
  type        = bool

}

/********** Compute Variables **********/

/********** Compute Datasource and Subnet Lookup related variables **********/
variable "compute_availability_domain_list" {
  type        = list(any)
  description = "Defines the availability domain list where OCI artifact will be created. This is a numeric value greater than 0"
}

variable "vcn_display_name" {
  description = "VCN Display name to execute lookup"
}

variable "compute_network_subnet_cidr_block" {
  description = "CIDR Block of the subnet where the computes are located at"
}
/********** Compute Datasource related variables **********/

variable "lbaas_display_name" {
  description = "Display Name for Load Balancer"

}

variable "lbaas_subnet_cidr_block" {
  description = "CIDR Block of the subnet where the LBaaS is located at"
}

variable "lbaas_ca_cert_is_path" {
  description = "Declared if the certificate LBaaS is in a path or if it is string"
  default     = true

}

variable "lbaas_pvt_key_is_path" {
  description = "Declares if the Private Key of LBaaS is in a path or string"
  default     = true

}

variable "lbaas_ssl_cert_is_path" {
  description = "Declares if the public certificate is in a path or string"
  default     = true

}

variable "certificate_bundle_display_name" {
  description = "Display name of certificate associated to LBaaS"
  default     = "certificate"

}

variable "lbaas_ca_cert" {
  description = "Load Balancer ca certificate"
  default     = ""
}

variable "certificate_private_key" {
  description = "Load Balancer Private Key"
  default     = ""

}

variable "lbaas_ssl_cert" {
  description = "Load Balancer Public Certificate"
  default     = ""
}

variable "verify_peer_certificate" {
  description = "Defines if peer verification is enabled"
  default     = true

}
variable "ATP_password" {}
variable "availability_domain" {
  default = ""
}
variable "availability_domain_name" {
  default = ""
}

variable "compute_network_subnet_name" {
  description = "Compute Subnet Name"

}

variable "lbaas_network_subnet_name" {
  description = "LBaaS Subnet Name"

}

variable "ATP_network_subnet_name" {
  description = "ATP Subnet Name"

}


variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "ATP_private_endpoint" {
  default = true
}

variable "ATP_database_cpu_core_count" {
  default = 1
}

variable "ATP_database_data_storage_size_in_tbs" {
  default = 1
}

variable "ATP_database_db_name" {
  default = "aTFdb"
}

variable "ATP_database_db_version" {
  default = "19c"
}

variable "ATP_database_defined_tags_value" {
  default = "value"
}

variable "ATP_database_display_name" {
  default = "ATP"
}

variable "ATP_database_freeform_tags" {
  default = {
    "Owner" = "ATP"
  }
}

variable "ATP_database_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "ATP_tde_wallet_zip_file" {
  default = "tde_wallet_aTFdb.zip"
}

variable "ATP_private_endpoint_label" {
  default = "ATPPrivateEndpoint"
}

variable "ATP_data_guard_enabled" {
  default = false
}

/********** Brick Variables **********/