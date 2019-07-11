#!/bin/bash

##################
#                #
# FULCHIC Gaby   #
# First release  #
#                #
##################

# PLUSIEURS SOLUTIONS > ###############################################################
#                                                                                     #
# 1 virt-install pour créé un .qcow2 configuré avec l'installer de centos (anaconda)  #
# 1 qcow2 existant étant un os fresh installed, et on virt-clone                      #
# 1 virt-install avec un -x "ks=http://sample/kickstart.cfg"                          #
# 1 template en .xml et un cloud-init                                                 #
#                                                                                     #
#######################################################################################

# Cloud-init + virt-install > #
# 
# Example for centos:
#
# cd /usr/local/kvm/img/ && wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2
# yum install qemu-kvm libvirt libvirt-python libguestfs-tools -y
# qemu-img info CentOS-7-x86_64-GenericCloud-1809.qcow2
# qemu-img resize CentOS-7-x86_64-GenericCloud-1809.qcow2 10G
# qemu-img convert -f CentOS-7-x86_64-GenericCloud-1809.qcow2 Centos-base.qcow2
# cat > cloud-init.txt << EOF
# password: toto1234
# hostname: centos1
# EOF
# yum install cloud-utils -y
# cloud-localds centos1.iso cloud-init.txt
# yum install virt-install -y

vm_hostnames=(centos1)
vm_number=${#vm_hostnames[*]}
echo "You are creating $vm_number VMs right now !"

for v in "${vm_hostnames[@]}"
do
    virt-install \
       --name "$v" \
       --memory 512 \
       --disk /usr/local/kvm/img/centos-base.qcow2,device=disk,bus=virtio \
       --disk /usr/local/kvm/img/centos-cloud-init.iso,device=cdrom \
       --os-type linux \
       --os-variant centos7.0 \
       --virt-type kvm \
       --graphics none \
       --network bridge=br01 \
       --import
done

echo "HERE YOU CAN SEE IP ADRESSES GIVEN IN DHCP BY THE BRIDGE >>>\n"
virsh net-dhcp-leases br01 | head -4 | tail -1
virsh net-dhcp-leases br01 | head -4 | tail -2
