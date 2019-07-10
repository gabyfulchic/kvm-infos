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


