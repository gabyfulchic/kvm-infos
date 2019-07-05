#!/bin/bash 

## Script pour faire mes tests
## et pouvoir relancer le script
## deploy-vm.sh sans erreurs.


# To use default : (comment below 2 lines)
echo "Tu veux kill quel VM ?"
read vmname

# default vmname : (uncomment below)
# vmname=centos

# Bye VM
virsh destroy $vmname
virsh undefine $vmname
rm -f /usr/local/kvm/img/$vmname.qcow2
virsh list --all


# To use default : (comment below 2 lines)
echo "Tu veux kill que Network ?"
read netname

# default network : (uncomment below)
# netname=br01

# Bye Bridge
virsh net-destroy $netname
virsh net-undefine $netname
virsh net-list --all
