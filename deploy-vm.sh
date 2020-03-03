#!/bin/bash

##################
#                #
# FULCHIC Gaby   #
#     v1.3       #
#                #
##################

## PLUSIEURS SOLUTIONS > ###############################################################
##                                                                                     #
## 1 virt-install pour créé un .qcow2 configuré avec l'installer de centos (anaconda)  #
## 1 qcow2 existant étant un os fresh installed, et on virt-clone                      #
## 1 virt-install avec un -x "ks=http://sample/kickstart.cfg"                          #
## 1 virt-install avec un cloud-init                                                   #
##                                                                                     #
########################################################################################

##  Cloud-init + virt-install >
## 
##      Example for centos:
##       
##           | | |
##           v v v

##
## Pour que tout se passe sans erreur il faut :
##
# -> renseigner dans $vm_hostnames le nom des vms
# -> renseigner le bridge(dhcp) à utiliser
# -> renseigner l'url de la cloud image de l'os voulu sur les VMs
# -> le path où vous stockerez les .qcow2, .img, .iso...
# -> une pubkey pour vous connecter aux VMs en ssh plus tard
# -> remplir le user-data/meta-data file à votre convenance
## 



## To pop 3 vms
# vm_hostname=(centos1 centos2 centos3)

os_variant="centos7.0"
vm_hostnames=(centos1) 
br="br01"
img_path="/usr/local/kvm/img"
iso_url="https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2"
ssh_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQPqSqgjcGq+6Fs2hFvexDHssJsDeQdyPTQVJC+yqxBEWX1TrnB714QbCAz9ugO5G6lEzqSt0Syf49mrJ52REYy0g5nk/oGu24/jeknjoSLT4ad7WrqZBMFpjf3CDr778Ry0xbcYc5/LrwLxNpJtZwiqhA2T1o4+zVN9RePrBMvBYOLZ0/MmpW9p2sRns0RzpStRf8zkWbndGM8tLj/Qauy51nXKZcmP1CRJ+KCRPmc4n9wikj5mFe5QH1kZIiZjhSy16i3wrA5unbzlVblLDXRA/t7mzCCdkkzFS+XONo1GPz1mGY3uIOJLDUn5WyjvqkHSplvZWUQLRegLagpQ22+SGjJoUozAiUnvRwabMFDjt0JCBWVZdQJup5jI06jkF2VnTCkOOjtiuRkBRsmhTtKguwv6Gm5UPmEsx5WbgwGiS/9nYWldcwMoElz5eLunRdQBSUgwm6/B90YyeGrQv2Yuh6Bue+ZxKegizcnMloDv9ItbUeQSjI5F8gSblSKkSTU8stDXqnULlstx2RAWt8NOqBUyfNIrZLMHXIvzptH9RKO8BQfafgxJ2RNIAnhTDdqzYn3lNa2lN1oZjR0WEUUvN6rVHIWTasrlWRNj1GuiscRsrcEM3kvNQ9d1ju5EyuCLD76xZa67LCxB+r+SZ5860qAPzwiqsuX/RNAF7w+w== Root's Server PublicKey"

getIso () {
    iso_name=`basename $iso_url`
    [ -a $img_path/$iso_name ] && rm $img_path/$iso_name
    [ -d $img_path ] || \
	    { printf "\n- Error : The img directory not exist ($img_path), \
		    edit the script to adapt it for your environment !"; exit 1; }
    cd $img_path/ && wget $iso_url
    qemu-img info $iso_name
    # qemu-img resize CentOS-7-x86_64-GenericCloud-1809.qcow2 10G
    # qemu-img convert -f CentOS-7-x86_64-GenericCloud-1809.qcow2 Centos-base.qcow2
}

## Cloud-init syntax samples >
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
	final_message: "The system is finally UP. Success!"
	power_state:
	  delay: "+1"
	  mode: reboot
	  message: Reboot is needed to conf network !!
	  timeout: 120
	runcmd:
	  - [ yum, remove, -y, cloud-init ]
EOF
        cat > $img_path/meta-data-$v << EOF
	instance-id: $v
	local-hostname: $v
EOF
        genisoimage -output $img_path/$v.iso \
		-volid cidata \
		-joliet -r $img_path/user-data-$v $img_path/meta-data-$v && \
		printf "\n- Cloud Image ISO have been generated successfully !"
        #cloud-localds $img_path/$v.iso $img_path/$v.txt
    done
}

deployVms () {
    cpu_available=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
    vm_number=${#vm_hostnames[*]}
     
    if [ $cpu_available -lt $vm_number ]
    then
        printf "\n- Error - Can't use more VCPU than there are available !"
    	exit 0
    else
        printf "\n###########################################"
        printf "\nYou are creating $vm_number VMs right now !"
        printf "\n###########################################"
    fi
     
    virsh net-list --all | grep "$br" 
    br_state="$?"

    if [ $br_state -ne "0" ]
    then
	printf "\n- You should run ./new-bridge.sh $br before to run the deploy-vm.sh !"
        exit 1
    else
        printf "\n- Success ! $br seems to be already created !"
    fi	
        
    ##  Don't create Bridge while poping VMS !
    #
    # ./new-bridge.sh $br && \
    #	    echo "##### Like You are creating your bridge at the same time than the\
    #	    vms, they may dont take any ip. Check by using \
    #	    | virsh net-dhcp-leases $br | #####"
    
    log_path="/usr/local/kvm/logs"
    [ -d $log_path ] || \
	    { printf "\n- Error : The log path is not created ($log_path) ! \
		    Come to edit the path as you want !"; exit 1; }
    for v in "${vm_hostnames[@]}"
    do
        virt-install \
           --virt-type kvm \
           --name "$v" \
           --memory 512 \
           --network bridge=$br,model=virtio \
           --disk $img_path/$iso_name,format=qcow2,bus=virtio \
           --disk $img_path/$v.iso,device=cdrom \
           --import \
           --os-type linux \
           --os-variant $os_variant \
           --graphics none \
	   --noautoconsole >> $log_path/$v-$(date +%F_%R).log 2>&1
    done
    
    virsh list --all
    
    printf "\n#############################################################"
    printf "\nHERE YOU CAN SEE IP ADRESSES GIVEN IN DHCP BY THE BRIDGE >>> "
    printf "\n#############################################################\n\n"
    
    index_leases=$(($vm_number+2))
    printf "-> "
    virsh net-dhcp-leases br01 | head -$index_leases | tail -$vm_number
}

getIso
setCloudInit
deployVms
