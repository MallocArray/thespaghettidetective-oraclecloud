# https://help.ubnt.com/hc/en-us/articles/218506997-tsd-Ports-Used

resource "oci_core_network_security_group" "tsd_network_security_group" {
    compartment_id = "${oci_identity_compartment.tsd_compartment.id}"
    vcn_id         = "${oci_core_vcn.tsdVCN.id}"
    display_name   = "TSD Required Ports"
}

resource "oci_core_network_security_group_security_rule" "tsd_network_security_group_security_rule_3334" {
    network_security_group_id = "${oci_core_network_security_group.tsd_network_security_group.id}"
    direction = "INGRESS"
    protocol = "6"
    description = "Port used for Web Browser communication"
    source   = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = "3334"
            min = "3334"
        }
    }
}
