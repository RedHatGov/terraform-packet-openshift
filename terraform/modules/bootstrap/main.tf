variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}
variable "count_master" {}
variable "count_compute" {}
variable "depends" {
  type    = any
  default = null
}


resource "packet_device" "bootstrap" {
  depends_on         = [var.depends]
  hostname           = format("bootstrap-%01d.%s.%s", count.index, var.cluster_name, var.cluster_basedomain)
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://${var.bastion_ip}:8080/bootstrap.ipxe"
  plan               = var.plan
  facilities         = [var.facility]
  count              = var.node_count
  billing_cycle    = "hourly"
  project_id       = var.project_id
}

resource "cloudflare_record" "dns_a_bootstrap" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.bootstrap[count.index].access_public_ipv4
  count      = var.node_count
}

locals {
  expanded_masters = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:6443;
        %{ endfor }
  EOT
  expanded_mcs = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:22623;
        %{ endfor }
  EOT
  expanded_compute = <<-EOT
        %{ for i in range(var.count_compute) ~}
        server worker-${i}.${var.cluster_name}.${var.cluster_basedomain}:443;
        %{ endfor }
  EOT
}

output "finished" {
    depends_on = [null_resource.check_dir]
    value      = "Bootstrap node provisioning finished."
}

