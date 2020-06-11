variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}
variable "node_type" {}
variable "depends" {
  type    = any
  default = null
}


resource "packet_device" "node" {
  depends_on         = [var.depends]
  hostname           = format("%s-%01d.%s.%s", var.node_type, count.index, var.cluster_name, var.cluster_basedomain)
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://${var.bastion_ip}:8080/${var.node_type}.ipxe"
  plan               = var.plan
  facilities         = [var.facility]
  count              = var.node_count
  billing_cycle    = "hourly"
  project_id       = var.project_id

}

output "finished" {
  value      = "Provisioning node type ${var.node_type} finished."
}

