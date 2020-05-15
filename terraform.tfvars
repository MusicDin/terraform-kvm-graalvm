# terraform.tfvars

#======================================================================================
# Network variables
#======================================================================================

# Name of the network that will be used for VMs #
network_name = "graalvm-network"

# Network gateway (example: 192.168.1.1) #
network_gateway = "192.168.1.1"

# Network mask (example: 255.255.255.0) #
network_mask = "255.255.255.0"

# Defines where DHCP range will start (example: 192.168.1.2) #
network_dhcp_start = "192.168.1.2"

# Defines where DHCP range will end (example: 192.168.1.254) #
network_dhcp_end = "192.168.1.254"

# Defines static DHCP for VM based on given MAC and IP address #
# Note: This MAC address will be used for creating VM  #
macs_and_ips = {
  "52:54:00:6c:3c:33" = "192.168.1.33"
}

#======================================================================================
# Virtual machine variables
#======================================================================================

# Username that will be used to SSH into VM #
vm_user = "graaluser"

# Location of private key that will be used to SHH into VM (example: ~/.ssh/id_rsa) #
vm_ssh_private_key_location = "~/.ssh/graalvm_id_rsa"

# VM name #
vm_name = "graalvm-vm"

# Amount of RAM for VM (In megabytes(MB)) #
vm_ram = "65536"

# Number of vCPU for VM #
vm_cpu = "8" 

# Amount of bytes that will be used for user storage beside image size (In bytes(B)) #
vm_disk_size = "5368709120"

# Location of image (.img) that will be installed on VM (Note: Can be URL) #
vm_image_location = "/var/lib/libvirt/images/focal-server-cloudimg-amd64.img"

# Download URL for GraalVM .tar.gz #
graalvm_tar_gz_link = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz"
