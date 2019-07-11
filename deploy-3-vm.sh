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

vm_hostnames=(centos1 centos2) 
img_path="/usr/local/kvm/img"
ssh_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQPqSqgjcGq+6Fs2hFvexDHssJsDeQdyPTQVJC+yqxBEWX1TrnB714QbCAz9ugO5G6lEzqSt0Syf49mrJ52REYy0g5nk/oGu24/jeknjoSLT4ad7WrqZBMFpjf3CDr778Ry0xbcYc5/LrwLxNpJtZwiqhA2T1o4+zVN9RePrBMvBYOLZ0/MmpW9p2sRns0RzpStRf8zkWbndGM8tLj/Qauy51nXKZcmP1CRJ+KCRPmc4n9wikj5mFe5QH1kZIiZjhSy16i3wrA5unbzlVblLDXRA/t7mzCCdkkzFS+XONo1GPz1mGY3uIOJLDUn5WyjvqkHSplvZWUQLRegLagpQ22+SGjJoUozAiUnvRwabMFDjt0JCBWVZdQJup5jI06jkF2VnTCkOOjtiuRkBRsmhTtKguwv6Gm5UPmEsx5WbgwGiS/9nYWldcwMoElz5eLunRdQBSUgwm6/B90YyeGrQv2Yuh6Bue+ZxKegizcnMloDv9ItbUeQSjI5F8gSblSKkSTU8stDXqnULlstx2RAWt8NOqBUyfNIrZLMHXIvzptH9RKO8BQfafgxJ2RNIAnhTDdqzYn3lNa2lN1oZjR0WEUUvN6rVHIWTasrlWRNj1GuiscRsrcEM3kvNQ9d1ju5EyuCLD76xZa67LCxB+r+SZ5860qAPzwiqsuX/RNAF7w+w== Root's Server PublicKey"

getIso () {
    cd $img_path/ && wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2
    yum install qemu-kvm libvirt libvirt-python libguestfs-tools -y
    qemu-img info CentOS-7-x86_64-GenericCloud-1809.qcow2
    # qemu-img resize CentOS-7-x86_64-GenericCloud-1809.qcow2 10G
    # qemu-img convert -f CentOS-7-x86_64-GenericCloud-1809.qcow2 Centos-base.qcow2
}

setCloudInit () {
    yum install cloud-utils -y
    for v in "${vm_hostnames[@]}"
    do
        cat > $img_path/$v.txt << EOF
        password: Passw0rd
        hostname: $vi
	chpassword: { expire: False }
	ssh_pwauth: False
	ssh_authorized_keys:
	  - $ssh_pubkey
EOF
        cloud-localds $img_path/$v.iso $img_path/$v.txt
    done
}

deployVms () {
    yum install virt-install -y
    vm_number=${#vm_hostnames[*]}

    echo "###########################################"
    echo "You are creating $vm_number VMs right now !"
    echo "###########################################"
    
    for v in "${vm_hostnames[@]}"
    do
        virt-install \
           --name "$v" \
           --memory 512 \
           --disk $img_path/centos-base.qcow2,device=disk,bus=virtio \
           --disk $img_path/$v.iso,device=cdrom \
           --os-type linux \
           --os-variant centos7.0 \
           --virt-type kvm \
           --graphics none \
           --network bridge=br01 \
           --import
    done

    echo "                                                              "
    echo "############################################################# "
    echo "HERE YOU CAN SEE IP ADRESSES GIVEN IN DHCP BY THE BRIDGE >>>  "
    echo "############################################################# "
    echo "                                                              "

    virsh net-dhcp-leases br01 | head -4 | tail -1
    virsh net-dhcp-leases br01 | head -3 | tail -1
}
