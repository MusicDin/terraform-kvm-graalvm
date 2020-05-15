# variables.tf

#======================================================================================
# Network variables
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
# Virtual machine variables
#======================================================================================

variable "vm_user" {
  description = "User that will be used to SSH into VM"
}

variable "vm_ssh_private_key_location" {
  description = "Location of file containing SSH private key"
}

variable "vm_name" {
  description = "Virtual machine name"
}

#variable "vm_mac" {
#  description = "Virtual machine's MAC address"
#}

#variable "vm_ip" {
#  description = "Virtual machine's IP address"
#}

variable "vm_ram" {
  description = "Amount of RAM for VM"
}

variable "vm_cpu" {
  description = "Number of vCPU for VM"
}

variable "vm_disk_size" {
  description = "Amount of storage (for user) beside image volume (which will be taken) in bytes (B)"
}

variable "vm_image_location" {
  description = "Location of an image (.img) that will be used as OS for VM"
}

variable "graalvm_tar_gz_link" {
  description = "Link for GraalVM .tar.gz download"
}
