# -*- mode: ruby -*-
# vi: set ft=ruby :

# Uncomment the next line to force use of VirtualBox provider when Fusion provider is present
# ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# Nodes: logging 	192.168.100.9
#        controller-01 	192.168.100.10
#        controller-02 	192.168.100.11 # DISABLED
#        controller-03 	192.168.100.12 # DISABLED
#        compute-01 	192.168.100.13
#        compute-02 	192.168.100.14 # DISABLED

# Interfaces
# eth0 - nat (used by VMware/VirtualBox)
# eth1 - br-mgmt (Container) 172.29.236.0/24
# eth2 - br-vlan (Neutron VLAN network) 0.0.0.0/0
# eth3 - host / API 192.168.100.0/24
# eth4 - br-vxlan (Neutron VXLAN Tunnel network) 172.29.240.0/24

nodes = {
    'compute'  => [1, 13],
    'controller' => [1, 10]
}

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
    
  # Defaults (VirtualBox)
  #config.vm.box = "bunchc/trusty-x64"
  config.vm.box = "velocity42/xenial64"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider :vmware_workstation do |vmware, override|
    # If we're running Workstation (i.e. Linux)
    if Vagrant.has_plugin?("vagrant-triggers")
      override.trigger.before :up do
        puts "[+] INFO: Ensuring /dev/vmnet* are correct to allow promiscuous mode."
        puts "[+]       Needed for access to containers on different VMs."
        run "./fix_vmnet.sh"
      end
    else
      puts "[-] WARN: Please ensure /dev/vmnet* is group owned and writeable by you" 
      puts "[-]          sudo chmod chgrp <gid> /dev/vmnet*"
      puts "[-]          sudo chmod g+rw /dev/vmnet*"
    end
  end

  # VMware Fusion / Workstation
  config.vm.provider :vmware_fusion or config.vm.provider :vmware_workstation do |vmware, override|
    #override.vm.box = "bunchc/trusty-x64"
    override.vm.box = "velocity42/xenial64"
    override.vm.synced_folder ".", "/vagrant", type: "nfs"

    # Fusion Performance Hacks
    vmware.vmx["logging"] = "FALSE"
    vmware.vmx["MemTrimRate"] = "0"
    vmware.vmx["MemAllowAutoScaleDown"] = "FALSE"
    vmware.vmx["mainMem.backing"] = "swap"
    vmware.vmx["sched.mem.pshare.enable"] = "FALSE"
    vmware.vmx["snapshot.disabled"] = "TRUE"
    vmware.vmx["isolation.tools.unity.disable"] = "TRUE"
    vmware.vmx["unity.allowCompostingInGuest"] = "FALSE"
    vmware.vmx["unity.enableLaunchMenu"] = "FALSE"
    vmware.vmx["unity.showBadges"] = "FALSE"
    vmware.vmx["unity.showBorders"] = "FALSE"
    vmware.vmx["unity.wasCapable"] = "FALSE"
    vmware.vmx["vhv.enable"] = "TRUE"
  end

  #Default is 2200..something, but port 2200 is used by forescout NAC agent.
  config.vm.usable_port_range= 2800..2900 

  #if Vagrant.has_plugin?("vagrant-cachier")
  #  config.cache.scope = :machine
  #  config.cache.enable :apt
  #  config.cache.synced_folder_opts = {
  #    type: :nfs,
  #    mount_options: ['rw', 'vers=3', 'nolock', 'async']
  #  }
  #else
  #  puts "[-] WARN: This would be much faster if you ran vagrant plugin install vagrant-cachier first"
  #end


  nodes.each do |prefix, (count, ip_start)|
    count.times do |i|
      if prefix == "compute" or prefix == "controller" or prefix == "logging"
        hostname = "%s-%02d" % [prefix, (i+1)]
      else
        hostname = "%s" % [prefix, (i+1)]
      end

      config.ssh.insert_key = false

      config.vm.define "#{hostname}" do |box|
        box.vm.hostname = "#{hostname}.cook.book"
        box.vm.network :private_network, ip: "172.29.236.#{ip_start+i}", :netmask => "255.255.255.0"
        box.vm.network :private_network, ip: "10.10.0.#{ip_start+i}", :netmask => "255.255.255.0" 
      	box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0" 
      	box.vm.network :private_network, ip: "172.29.240.#{ip_start+i}", :netmask => "255.255.255.0" 

	# Logging host is also the deployment server, so this will have the master SSH key which then gets copied
	# Also the first to boot, so get that to set the keys to be used.
	if hostname == "compute-01"
	  box.vm.provision :shell, :path => "masterkey.sh"
	else
	  box.vm.provision :shell, :path => "clientkey.sh"
	end

	box.vm.provision :shell, :path => "hosts.sh"

	# Order is important - this is the last "prefix" (vm) to load up, so execute last
        if hostname == "controller-01"
          box.vm.provision :ansible do |ansible|
            # Disable default limit to connect to all the machines
            ansible.limit = "all"
            ansible.playbook = "install-openstack.yml"
            ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
            ansible.sudo = true
          end
	  #box.vm.provision :shell, :path => "bootstrap-install.sh"
        end 

        #box.vm.provision :shell, :path => "hosts.sh"
        #box.vm.provision :shell, :path => "install-prereqs.sh"
        #box.vm.provision :shell, :path => "networking.sh"

	# Assumption is that compute-01 will run last, change to suit
	# This will shell into logging to kickstart the install from it
	#if hostname == "compute-01"
	#  box.vm.provision :shell, :path => "bootstrap-install.sh"
	#end

        # box.vm.provision :shell, :path => "#{prefix}.sh"

        # If using Fusion
        box.vm.provider "vmware_fusion" do |v|
	  v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
          v.vmx["memsize"] = 3172
          if prefix == "controller"
            v.vmx["memsize"] = 4096
            v.vmx["numvcpus"] = "1"
          end
          if prefix == "compute"
            v.vmx["memsize"] = 4096
            v.vmx["numvcpus"] = "1"
            v.vmx["vhv.enable"] = "TRUE"
          end
        end

        # If using Workstation
        box.vm.provider "vmware_workstation" do |v|
	  v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
          v.vmx["memsize"] = 1024
          if prefix == "logging"
            v.vmx["memsize"] = 3172
            v.vmx["numvcpus"] = "1"
          end
          if prefix == "controller"
            v.vmx["memsize"] = 3172
            v.vmx["numvcpus"] = "1"
          end
          if prefix == "compute"
            v.vmx["memsize"] = 3172
            v.vmx["numvcpus"] = "1"
            v.vmx["vhv.enable"] = "TRUE"
          end
        end

        # Otherwise using VirtualBox
        box.vm.provider :virtualbox do |vbox|
          # Defaults
	  vbox.linked_clone = true if Vagrant::VERSION =~ /^1.8/
          vbox.customize ["modifyvm", :id, "--memory", 2048]
          vbox.customize ["modifyvm", :id, "--cpus", 1]
          if prefix == "controller"
            vbox.customize ["modifyvm", :id, "--memory", 6144]
            vbox.customize ["modifyvm", :id, "--cpus", 2]
          end
          if prefix == "compute"
            vbox.customize ["modifyvm", :id, "--memory", 4096]
            vbox.customize ["modifyvm", :id, "--cpus", 1]
          end
          vbox.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
        end
      end
    end
  end
end
