# main.tf

#======================================================================================
# Modules
#======================================================================================

# Creates network module #
module "network-module" {
  source             = "./modules/network/"
  network_name       = var.network_name
  network_gateway    = var.network_gateway
  network_mask       = var.network_mask
  network_dhcp_start = var.network_dhcp_start
  network_dhcp_end   = var.network_dhcp_end
  macs_and_ips       = var.macs_and_ips
}

# Create VM module #
module "libvirt-vm-module" {
  source                      = "./modules/libvirt/"
  vm_user                     = var.vm_user
  vm_name                     = var.vm_name
  vm_cpu                      = var.vm_cpu
  vm_ram                      = var.vm_ram
  vm_disk_size                = var.vm_disk_size
  vm_mac                      = keys(var.macs_and_ips)[0]
  vm_ip                       = values(var.macs_and_ips)[0]
  vm_image_location           = var.vm_image_location
  network_name                = var.network_name
  vm_ssh_private_key_location = var.vm_ssh_private_key_location
  graalvm_tar_gz_link         = var.graalvm_tar_gz_link
}


