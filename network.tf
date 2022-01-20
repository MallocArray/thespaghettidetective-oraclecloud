resource "oci_core_vcn" "tsdVCN" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${oci_identity_compartment.tsd_compartment.id}"
  display_name   = "${var.project_name}-${random_id.tsd_id.dec}"
}

resource "oci_core_internet_gateway" "tsdIG" {
  compartment_id = "${oci_identity_compartment.tsd_compartment.id}"
  display_name   = "${var.project_name}-IG-${random_id.tsd_id.dec}"
  vcn_id         = "${oci_core_vcn.tsdVCN.id}"
}

resource "oci_core_route_table" "tsdRT" {
  compartment_id = "${oci_identity_compartment.tsd_compartment.id}"
  vcn_id         = "${oci_core_vcn.tsdVCN.id}"
  display_name   = "${var.project_name}-RT-${random_id.tsd_id.dec}"
    route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.tsdIG.id}"
    }
}

resource "oci_core_subnet" "tsdSubnet" {
  cidr_block                 = "10.0.100.0/24"
  compartment_id             = "${oci_identity_compartment.tsd_compartment.id}"
  vcn_id                     = "${oci_core_vcn.tsdVCN.id}"
  display_name               = "${var.project_name}-${random_id.tsd_id.dec}"
  route_table_id             = "${oci_core_route_table.tsdRT.id}"
}
