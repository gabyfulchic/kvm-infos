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
# cloud-localds centos.iso cloud-init.txt
# yum install virt-install -y

virt-install \
       --name centos1 \
       --memory 512 \
       --disk /usr/local/kvm/img/Centos-base.qcow2,device=disk,bus=virtio \
       --disk /usr/local/kvm/img/centos.iso,device=cdrom \
       --os-type linux \
       --os-variant centos7.0 \
       --virt-type kvm \
       --graphics none \
       --network bridge=br01 \
       --import

