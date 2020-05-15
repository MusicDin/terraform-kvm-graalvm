# network.tf

#======================================================================================
# Libvirt provider
#======================================================================================

provider "libvirt" {
  uri = "qemu:///system"
}

#======================================================================================
# Variables
#======================================================================================

variable "network_name" {
  description = "Name of the network that will be used for VMs"
}

variable "network_gateway" {
  description = "Network gateway"
}

variable "network_mask" {
  description = "Network mask"
}

variable "network_dhcp_start" {
  description = "Network DHCP start IP"
}

variable "network_dhcp_end" {
  description = "Network DHCP end IP"
}

variable "macs_and_ips" {
  type = map
  description = "MAC and IP addresses of new VMs that need static DHCP routing"
}

#======================================================================================
# Templates
#======================================================================================

# Reads and inserts values into template file #
data "template_file" "network_config_tpl" {
  template = file("${path.module}/../../templates/network_config.tpl")

  vars = {
    network_name       = var.network_name
    network_gateway    = var.network_gateway
    network_mask       = var.network_mask
    network_dhcp_start = var.network_dhcp_start
    network_dhcp_end   = var.network_dhcp_end
  }
}

#======================================================================================
# Local files
#======================================================================================

# Create network configuration file from template #
resource "local_file" "network_config" {
  content    = data.template_file.network_config_tpl.rendered
  filename   = "${path.module}/network_config.xml"
#  depends_on = [template_file.network_config_tpl]
}

#======================================================================================
# Null resources
#======================================================================================

# Let terraform manage the lifecycle of the network
resource "null_resource" "network" {
  
  # On terraform apply - Create network
  provisioner "local-exec" {
    command     = "virsh net-define ${path.module}/network_config.xml && virsh net-autostart ${var.network_name} && virsh net-start ${var.network_name}"
    interpreter = ["/bin/bash", "-c"]
  }

  # On terraform destroy - Remove network
  provisioner "local-exec" {
    when    = destroy
    command = "virsh net-destroy ${var.network_name} && virsh net-undefine ${var.network_name}"
  }

  depends_on = [local_file.network_config]
}

# Creates static routes for given VMs (depending on their MAC and IP addresses) #
resource "null_resource" "network-static-ips" {

  for_each = var.macs_and_ips
  
  # On terraform apply - Add hosts
  provisioner "local-exec" {
    command     = "virsh net-update ${var.network_name} add ip-dhcp-host \"<host mac='${each.key}' ip='${each.value}'/>\" --live --config"
    interpreter = ["/bin/bash", "-c"]
  }


  depends_on = [null_resource.network]
}
