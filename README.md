# KVM

### LAUNCH THE PROJECT  
### It will create 2 Centos7 Vm by default in a Bridged Network  

```ruby
git clone https://github.com/gabyfulchic/kvm-infos.git
cd kvm-infos/
chmod +x deploy-vm.sh \
    destroy-vm.sh \
    new-bridge.sh
./deploy-vm.sh
```  
  
**Requirements >>**  
> yum install virt-install -y  
> yum install qemu-kvm libvirt libvirt-python libguestfs-tools -y  
> yum install cloud-utils -y  

```ruby
> VM SysInfos  
----------------------  
> {OS} : Centos7.0   -  
> {Name} : centos    -  
> {Mem} : 512 MB     -  
> {Vcpu} : 1 vcpu    -  
> {Net} : br01       -  
> {Graphics} : none  -  
----------------------  
```  
  
```ruby
> **Number of virtual cores per VM** 
  
KVM allows the user to set the number of virtual cores used by each   
virtual machine. The best practices for virtual cores on each virtual machine are:  
  
Always use only one core per VM. Do not configure more than one virtual core on a   
virtual machine unless the application you will use on it absolutely requires more   
than one core. In network simulators, running only one core per VM results in the   
best performance.  
  
Never configure a higher number of virtual cores on each VM than the number of real   
cores available on the host computer. For example, most laptop computers have dual-core  
processors so, if you need more than one core on a VM, you can configure the VM to use   
no more than two virtual cores.  
```
