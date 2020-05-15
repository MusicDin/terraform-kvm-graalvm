# terraform-kvm-graalvm
Install VM with GraalVM on KVM using Terraform.

## Prerequisite

Installed [KVM](https://www.linux-kvm.org) and [Terraform](https://www.terraform.io/).

## Usage

Edit `terraform.tfvars` file. Especially important fields to be edited are:
+ `vm_ssh_private_key_location` - Location of SSH private key that will be used to SSH into VM
+ `vm_image_location` - Location of and image that will be installed on VM
+ `vm_ram` - Amount of RAM that will be available to VM
+ `vm_cpu` - Number of vCPU that will be available to VM

To create VM use the following command where `main.tf` file is located:
<pre>
terraform apply
</pre>

When asked enter `yes` to confirm execution.

After creation `ssh.sh` file will be created for easier access to VM. Use it with command:
<pre>
./ssh.sh
</pre>

To destroy all created resources use command:
<pre>
terraform destroy
</pre>

And when asked enter `yes` to confirm destruction.
