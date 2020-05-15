# libvirt.tf

#======================================================================================
# Variables
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

variable "vm_mac" {
  description = "Virtual machine's MAC address"
}

variable "vm_ip" {
  description = "Virtual machine's IP address"
}

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
  description = "Location of image (.img) that will be used as OS for VM."
}

variable "network_name" {
  description = "Network to be used"
}

variable "graalvm_tar_gz_link" {
  description = "Link for GraalVM .tar.gz download"
}

#======================================================================================
# Libvirt provider
#======================================================================================

provider "libvirt" {
  uri = "qemu:///system"
}

#======================================================================================
# Templates
#======================================================================================

# Reads cloud init template file and inserts variables into it #
data "template_file" "cloud_init_tpl" {
  template = file("${path.module}/../../templates/cloud_init.tpl")
  vars = {
    user         = var.vm_user
    public_key   = file("${var.vm_ssh_private_key_location}.pub")
    graalvm_link = var.graalvm_tar_gz_link
  }
}

# Reads network configuration template file #
data "template_file" "network_config_tpl" {
  template = file("${path.module}/network_config.cfg")
}

# Reads template for SSH script and inserts variables into it #
data "template_file" "ssh_script_tpl" {
  template = file("${path.module}/../../templates/ssh.tpl")

  vars = {
    user                 = var.vm_user
    ip                   = var.vm_ip
    private_key_location = var.vm_ssh_private_key_location
  }
}

#======================================================================================
# Local files
#======================================================================================

# Create cloud-init configuration file from template #
resource "local_file" "cloud_init" {
  content    = data.template_file.cloud_init_tpl.rendered
  filename   = "${path.module}/cloud_init.cfg"
}

# Creates script for easy SSH to new VM #
resource "local_file" "ssh_script" {
  content    = data.template_file.ssh_script_tpl.rendered
  filename   = "${path.module}/../../ssh.sh"
}

#======================================================================================
# Virtual Machine
#======================================================================================

# Creates resource pool #
resource "libvirt_pool" "pool" {
  name = "${var.vm_name}-pool"
  type = "dir"
  path = "/var/lib/libvirt/pools/${var.vm_name}-pool"
}

# Creates image volume #
resource "libvirt_volume" "image_volume" {
  name   = "${var.vm_name}-image-volume.qcow2"
  pool   = libvirt_pool.pool.name
  source = var.vm_image_location
  format = "qcow2"

  depends_on = [
    libvirt_pool.pool
  ]
}

# Expands image volume with additional storage for user #
resource "libvirt_volume" "user_volume" {
  name             = "${var.vm_user}-user-volume.qcow2"
  pool             = libvirt_pool.pool.name
  base_volume_name = libvirt_volume.image_volume.name
  base_volume_pool = libvirt_pool.pool.name
  size             = var.vm_disk_size
  format           = "qcow2"

  depends_on = [
    libvirt_volume.image_volume,
    libvirt_pool.pool
  ]
}

# Creates cloud init configuration #
resource "libvirt_cloudinit_disk" "cloud_init" {
 name           = "cloudinit.iso"
 pool           = libvirt_pool.pool.name
 user_data      = data.template_file.cloud_init_tpl.rendered
 network_config = data.template_file.network_config_tpl.rendered
}

# Creates KVM virtual machine #
resource "libvirt_domain" "virtual_machine" {

  name   = var.vm_name
  memory = var.vm_ram
  vcpu   = var.vm_cpu
 
  cloudinit = libvirt_cloudinit_disk.cloud_init.id

  disk {
    volume_id = libvirt_volume.user_volume.id
  } 
 
  network_interface {
    network_name   = var.network_name
    mac            = var.vm_mac
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
 
  # Wait for cloud-init to finish initialization #
  provisioner "remote-exec" {
    connection {
      host        = self.network_interface.0.addresses.0
      type        = "ssh"
      user        = var.vm_user
      private_key = file(var.vm_ssh_private_key_location)
    }

    inline = [
      "while ! grep \"Cloud-init .* finished\" /var/log/cloud-init.log; do echo \"$(date -Ins) Waiting for cloud-init to finish\"; sleep 2; done"
    ]
  }
}
