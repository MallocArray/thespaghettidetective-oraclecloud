output "instance_public_ip" {
  value = "${oci_core_instance.tsd_instance.public_ip}"
  }

output "tds_public_url" {
  value = "${format("https://%s:3334", oci_core_instance.tsd_instance.public_ip)}"
}

output "comments" {
  value = "The controller should become available in aproximately 15-20 minutes, once updates and installation have completed"
}
