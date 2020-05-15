<network connections='1'>
  <name>${network_name}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr11' stp='on' delay='0'/>
  <mac address='52:54:00:4f:e3:aa'/>
  <ip address='${network_gateway}' netmask='${network_mask}'>
    <dhcp>
      <range start='${network_dhcp_start}' end='${network_dhcp_end}'/>
    </dhcp>
  </ip>
</network>

