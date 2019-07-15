#!/bin/bash

##################
#                #
# FULCHIC Gaby   #
# v1.3           #
#                #
##################

# PLUSIEURS SOLUTIONS > ###############################################################
#                                                                                     #
# 1 virt-install pour créé un .qcow2 configuré avec l'installer de centos (anaconda)  #
# 1 qcow2 existant étant un os fresh installed, et on virt-clone                      #
# 1 virt-install avec un -x "ks=http://sample/kickstart.cfg"                          #
# 1 virt-install avec un cloud-init                                                   #
#                                                                                     #
#######################################################################################

# Cloud-init + virt-install > #
# 
# Example for centos:
#

vm_hostnames=(centos1) 
img_path="/usr/local/kvm/img"
ssh_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQPqSqgjcGq+6Fs2hFvexDHssJsDeQdyPTQVJC+yqxBEWX1TrnB714QbCAz9ugO5G6lEzqSt0Syf49mrJ52REYy0g5nk/oGu24/jeknjoSLT4ad7WrqZBMFpjf3CDr778Ry0xbcYc5/LrwLxNpJtZwiqhA2T1o4+zVN9RePrBMvBYOLZ0/MmpW9p2sRns0RzpStRf8zkWbndGM8tLj/Qauy51nXKZcmP1CRJ+KCRPmc4n9wikj5mFe5QH1kZIiZjhSy16i3wrA5unbzlVblLDXRA/t7mzCCdkkzFS+XONo1GPz1mGY3uIOJLDUn5WyjvqkHSplvZWUQLRegLagpQ22+SGjJoUozAiUnvRwabMFDjt0JCBWVZdQJup5jI06jkF2VnTCkOOjtiuRkBRsmhTtKguwv6Gm5UPmEsx5WbgwGiS/9nYWldcwMoElz5eLunRdQBSUgwm6/B90YyeGrQv2Yuh6Bue+ZxKegizcnMloDv9ItbUeQSjI5F8gSblSKkSTU8stDXqnULlstx2RAWt8NOqBUyfNIrZLMHXIvzptH9RKO8BQfafgxJ2RNIAnhTDdqzYn3lNa2lN1oZjR0WEUUvN6rVHIWTasrlWRNj1GuiscRsrcEM3kvNQ9d1ju5EyuCLD76xZa67LCxB+r+SZ5860qAPzwiqsuX/RNAF7w+w== Root's Server PublicKey"
br="br01"

getIso () {
    cd $img_path/ && wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2
    qemu-img info CentOS-7-x86_64-GenericCloud-1809.qcow2
    # qemu-img resize CentOS-7-x86_64-GenericCloud-1809.qcow2 10G
    # qemu-img convert -f CentOS-7-x86_64-GenericCloud-1809.qcow2 Centos-base.qcow2
}

# Cloud-init syntax samples >
#
# chpassword: { expire: False }
# runcmd:
#   - [ ifup, eth0 ]
#   - [ systemctl, status, networking ]

setCloudInit () {
    for v in "${vm_hostnames[@]}"
    do
        cat > $img_path/user-data-$v << EOF
        password: Passw0rd
        hostname: $v
	ssh_pwauth: True
	ssh_authorized_keys:
	  - $ssh_pubkey
	runcmd:
	  - [ yum, remove, -y, cloud-init ]
	final_message: "The system is finally UP. Success!"
	power_state:
	  delay: "+1"
	  mode: reboot
	  message: Reboot is needed to conf network !!
	  timeout: 120
EOF
        cat > $img_path/meta-data-$v << EOF
	instance-id: 
	local-hostname: $v
EOF
        #genisoimage -output $img_path/$v.iso \
	#	-volid cidata \
	#	-joliet -r user-data-$v meta-data-$v && \
	#	echo "Cloud Image ISO have been generated successfully !"
        cloud-localds $img_path/$v.iso $img_path/$v.txt
    done
}

deployVms () {
    cpu_available=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
    vm_number=${#vm_hostnames[*]}
    
    if [ $cpu_available -lt $vm_number ]
    then
        echo " Error - Can't use more VCPU than there are available !"
    	exit 0
    else
        echo "###########################################"
        echo "You are creating $vm_number VMs right now !"
        echo "###########################################"
    fi
    
    virsh net-list --all | grep "br01" || ./new-bridge.sh br01
    
    for v in "${vm_hostnames[@]}"
    do
        virt-install \
           --virt-type kvm \
           --name "$v" \
           --memory 512 \
           --network bridge=$br,model=virtio \
           --disk $img_path/centos-base.qcow2,format=qcow2,bus=virtio \
           --disk $img_path/$v.iso,device=cdrom \
           --import \
           --os-type linux \
           --os-variant centos7.0 \
           --graphics none \
	   --noautoconsole
    done
    
    virsh list --all

    echo "                                                              "
    echo "############################################################# "
    echo "HERE YOU CAN SEE IP ADRESSES GIVEN IN DHCP BY THE BRIDGE >>>  "
    echo "############################################################# "
    echo "                                                              "
    
    index_leases=$(($vm_number+2))
    virsh net-dhcp-leases br01 | head -$index_leases | tail -$vm_number
}

#getIso
setCloudInit
deployVms
