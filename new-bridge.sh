#!/bin/bash

#              #
# Gaby FULCHIC #
#  03/07/2019  #
#              #

#      For example     #
# ./new-bridge.sh br01 #

# Initialize the Bridge Interface from the
# xml file with virsh (libvirt)

if [ "$1" != "br01" ]
then
    echo "\n"
    echo "An error will pop if your $1.xml file have not been created !"
    echo "\n"
fi

cd dumpxml/
virsh net-define $1.xml
virsh net-start $1
virsh net-autostart $1
virsh net-list --all
