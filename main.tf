data "template_file" "tsd-init" {
  template = "${file("./cloud-init/startup.sh")}"
  # These vars don't do anything, but they have to be defined to not cause errors
  vars = {
    bucket = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.tsd_backup_preauthenticated_request.access_uri}"
    ddns = "${var.ddns_url}"
    tz="${var.timezone}"
  }
}

resource "oci_identity_compartment" "tsd_compartment" {
    compartment_id = "${var.compartment_ocid}"
    description = "TSD Controller Compartment"
    name = "${var.project_name}"
}

resource "oci_core_instance" "tsd_instance" {
  availability_domain = "${data.oci_identity_availability_domain.tsd-AD.name}"
  compartment_id      = "${oci_identity_compartment.tsd_compartment.id}"
  shape               = "${var.instance_shape}"
  display_name        = "${var.project_name}-${random_id.tsd_id.dec}"
  shape_config {
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
    ocpus = var.instance_shape_config_ocpus
  }

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.tsdSubnet.id}"
    nsg_ids          = ["${oci_core_network_security_group.tsd_network_security_group.id}"]
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.supported_shape_images.images[0], "id")}"
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(data.template_file.tsd-init.rendered)}"
    ddns-url            = "${var.ddns_url}"
    timezone            = "${var.timezone}"
    dns-name            = "${var.dns_name}"
    bucket              = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.tsd_backup_preauthenticated_request.access_uri}"
  }

}


data "oci_identity_availability_domain" "tsd-AD" {
    #Required
    compartment_id = "${var.compartment_ocid}"
    #Optional
    ad_number = "${var.availability_domain}"
}


# Gets a list of images within a tenancy with the specified criteria
data "oci_core_images" "supported_shape_images" {
  compartment_id = "${var.compartment_ocid}"
  shape                     = "${var.instance_shape}"
  operating_system         = "${var.operating_system}"
  operating_system_version = "${var.operating_system_version}"
  sort_by                 = "TIMECREATED"
  state                   = "AVAILABLE"
}
