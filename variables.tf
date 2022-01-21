variable "availability_domain" {
  default = 1
  description = "If errors about 'shape not found', try 2 or 3.  See README for more information"
}

variable "ssh_public_key" {
  default = ""
}

variable "source_ip" {
  default = "0.0.0.0/0"
  description = "IP address to allow access from. Recommended to only allow your personal public IP followed by /32"
}

variable "dns_name" {
  default = ""
  description = "DNS name for the public IP assigned."
}

variable "timezone" {
  default = ""
  description="Example America/Chicago"
}

variable "project_name" {
  default = "tsd"
}

variable "region" {}

variable "compartment_ocid" {}

variable "bucket_name" {
  default = "tsd-backup"
  description = "Name of the Oracle Storage Bucket created previously"
}

variable "ddns_url" {
  default=""
  description = "URL to update Dynamic DNS entry such as http://freedns.afraid.org/dynamic/update.php?xxxdynamicTokenxxx"
}

variable "instance_shape" {
  default = "VM.Standard.A1.Flex"
  description = "Shape Reference: https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm"
}

variable "instance_shape_config_memory_in_gbs" {
  default = 6
  description = "RAM GB"
}

variable "instance_shape_config_ocpus" {
  default = 2
  description = "oCPUs"
}

variable "operating_system" {
  default = "Canonical Ubuntu"
  description = "Full name of OS without version number such as 'Canonical Ubuntu'"
}

variable "operating_system_version" {
  default = "20.04"
  description = "Version name of the specified OS, such as '18.04'"
}

resource "random_id" "tsd_id" {
  byte_length = 2
}
