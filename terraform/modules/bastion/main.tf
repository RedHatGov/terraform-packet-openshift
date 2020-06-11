variable "depends" {
  type    = any
  default = null
}

variable "ssh_private_key_path" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "cf_zone_id" {}
variable "ocp_version" {}
variable "ocp_version_zstream" {}
variable "nodes" {
  description = "Generic list of OpenShift node types"
  type        = list(string)
  default     = ["bootstrap", "master", "worker"]
}

provider "packet" {
    auth_token = var.auth_token
}

data "template_file" "user_data" { 
    template = file("${path.module}/templates/user_data_${var.operating_system}.sh")
}

data "template_file" "ipxe_script" {
  depends_on = [packet_device.lb]
  for_each   = toset(var.nodes)
  template   = file("${path.module}/templates/ipxe.tpl")

  vars = {
    node_type           = each.value
    bastion_ip          = packet_device.lb.access_public_ipv4 
    ocp_version         = var.ocp_version
    ocp_version_zstream = var.ocp_version_zstream
  }
}

locals {
  arch           = "x86_64"
  coreos_baseurl = "http://54.172.173.155/pub/openshift-v4/dependencies/rhcos"
  coreos_url     = "${local.coreos_baseurl}/${var.ocp_version}/${var.ocp_version}.${var.ocp_version_zstream}"
  coreos_filenm  = "rhcos-${var.ocp_version}.${var.ocp_version_zstream}-${local.arch}"
  coreos_img     = "${local.coreos_filenm}-metal.${local.arch}.raw.gz"
  coreos_kernel  = "${local.coreos_filenm}-installer-kernel-${local.arch}"
  coreos_initrd  = "${local.coreos_filenm}-installer-initramfs.${local.arch}.img"
  
}

resource "packet_device" "lb" {
    hostname = "lb-0.${var.cluster_name}.${var.cluster_basedomain}" 
    plan = var.plan
    facilities = [var.facility]
    operating_system = var.operating_system
    billing_cycle = var.billing_cycle
    project_id = var.project_id
    user_data = data.template_file.user_data.rendered

}

resource "null_resource" "dircheck" {

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = packet_device.lb.access_public_ipv4
    }


    inline = [
      "while [ ! -d /usr/share/nginx/html ]; do sleep 2; done; ls /usr/share/nginx/html/",
      "while [ ! -f /usr/lib/systemd/system/nfs-server.service ]; do sleep 2; done; ls /usr/lib/systemd/system/nfs-server.service"
    ]
  }
}

resource "null_resource" "ocp_install_ignition" {

  depends_on = [null_resource.dircheck]

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = packet_device.lb.access_public_ipv4
    }


    inline = [
      "curl -o /usr/share/nginx/html/${local.coreos_img} ${local.coreos_url}/${local.coreos_img}",
      "curl -o /usr/share/nginx/html/${local.coreos_kernel} ${local.coreos_url}/${local.coreos_kernel}",
      "curl -o /usr/share/nginx/html/${local.coreos_initrd} ${local.coreos_url}/${local.coreos_initrd}",
      "chmod -R 0755 /usr/share/nginx/html/"
    ]
  }
}

resource "null_resource" "ipxe_files" {

  depends_on = [null_resource.dircheck]  
  for_each  = data.template_file.ipxe_script

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = packet_device.lb.access_public_ipv4
    }

    content       = each.value.rendered
    destination = "/usr/share/nginx/html/${ each.key }.ipxe"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = packet_device.lb.access_public_ipv4
    }


    inline = [
      "chmod -R 0755 /usr/share/nginx/html/",
    ]
  }
}

output "finished" {
    depends_on = [null_resource.file_uploads, null_resource.ipxe_files]
    value      = "Loadbalancer provisioning finished."
}

