# How to use virsh  

## GabyFULCHIC Virsh MAN.
## Je vais essayer de contribuer 
## à https://tldr.sh pour virsh.

```ruby
> ## Act on Node/Host ##
>
> virsh nodeinfo (display node info)
> virsh list (display vm on host)
> virsh list --all (display all vm on host)

> ## Act on vnet/network ##
>
> virsh net-list (display all net conf'ed on host)
> virsh net-create net1.xml (create a vnet from xml file AND starts it)
> virsh net-define net1.xml (create a vnet from xml file.)
> virsh net-start net1 (start an innactive vnet)
> virsh net-autostart net1 (enable a vnet)

> ## Act on VMs ##
>  
> virsh console $vmname (to exit : ctrl + 5)
> virsh help console (for more infos)  
> virsh dominfo $vmname (display vm infos)
> virsh dumpxml $vmname > guest.xml (output vm conf in .xml)
> virsh edit $vmname (edit .xml to change conf while running)
> virsh create $guest.xml (create a vm from .xml file)
> virsh shutdown $vmname (stop a vm)
> virsh start $vmname (start a vm)
> virsh save $vmname backupfile (backup a vm)
> virsh restore backupfile (restore vm from saved file)
> virsh reboot $vmname (restart a vm)
> virsh suspend $vmname (pause a vm)
> virsh resume $vmname (stop pause for a vm)
> virsh destroy $vmname (force a shutdown)
```  
