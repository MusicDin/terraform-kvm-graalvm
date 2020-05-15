#cloud-config
users:
  - name: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    lock_passwd: true
    shell: /bin/bash
    ssh_authorized_keys:
      - ${public_key}
# Install required packages
packages:
  - qemu-guest-agent
  - git
  - wget
# Run commands at boot (only first time)
runcmd:
  - mkdir /usr/lib/jvm
  - cd /usr/lib/jvm
  - [wget, "${graalvm_link}"]
  - tar -xvf graalvm-*.tar.gz
  - rm graalvm-*.tar.gz
  - mv graalvm-*/ graalvm/
  - echo 'export PATH=$PATH:/usr/lib/jvm/graalvm/bin' >> /home/${user}/.bashrc
  - echo 'export JAVA_HOME=$PATH:/usr/lib/jvm/graalvm' >> /home/${user}/.bashrc
  - /usr/lib/jvm/graalvm/lib/installer/bin/gu install native-image
