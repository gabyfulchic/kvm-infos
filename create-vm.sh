#!/bin/bash

#~~~~~~~~~~~~~~#
# Gaby FULCHIC #
#  03/07/2019  #
#     v1.2     #
#   Aborted..  #
#~~~~~~~~~~~~~~#

if [ $# -eq "0" ]
then
    echo "
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    # Help for the script >                                       #
    # (ln -s /path/to/script.sh /usr/bin/deploy)                  #
    #                                                             #
    # ./deploy-vm.sh \$vmname \$vcpu \$mem \$cdr \$disk \$os \$br #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
fi

localDir="/usr/local/kvm"
mkdir -p $localDir/boot $localDir/img
chown gaby:gaby -R $localDir

[ -z "$1" ] && vmname="centos"
[ -z "$2" ] && vcpu="1"
[ -z "$3" ] && mem="512"
[ -z "$4" ] && cdr="/var/lib/libvirt/boot/centos-7-x86_64-minimal-1810.iso"
[ -z "$5" ] && disk="$localDir/img/centos.qcow2,size=5,bus=virtio,format=qcow2"
[ -z "$6" ] && os="centos7.0"
[ -z "$7" ] && br="br01"

# create bridge interface for the vm network
./new-bridge.sh $br

# create the disk for the vm
qemu-img create -f qcow2 $localDir/img/centos.qcow2 5G

# provision the new virtual machine
virt-install --virt-type=kvm \
	--os-type linux \
	--network bridge=$br \
	--name=$vmname \
	--vcpu=$vcpu \
	--memory=$mem \
	--location=$cdr \
	--disk path=$disk \
	--os-variant=$os \
	--graphics none \
        --extra-args='console=ttyS0'
#	--noautoconsole
