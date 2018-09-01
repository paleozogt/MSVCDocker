# Vagrant File (Vagrantfile)
# http://docs.vagrantup.com/v2/vagrantfile/index.html

Vagrant.require_version ">= 2.0.0"

# plugin checks
required_plugins = %w(
  vagrant-reload
)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    raise Vagrant::Errors::VagrantError.new, "Plugin missing: " + plugin
  end
end

# msvcs   test, 2013 2015, 2017
msvcs = [ 'test', 12,  14,   15 ]

Vagrant.configure("2") do |config|
    # provision a box for each MSVC
    msvcs.each do |msvc|
        vmname = "win-msvc%s" % [ msvc ]

        config.vm.define vmname do |vmconfig|
            vmconfig.vm.box = "jhakonen/windows-10-n-pro-en-x86_64"

            vmconfig.vm.guest = :windows
            vmconfig.winrm.username = "vagrant"
            vmconfig.winrm.password = "vagrant"
            vmconfig.vm.communicator = "winrm"
            vmconfig.vbguest.auto_update = false

            vmconfig.vm.provider :virtualbox do |v, override|
                v.name = vmname
                v.linked_clone = true
                v.customize ['modifyvm', :id, 
                             '--clipboard', 'bidirectional', 
                             '--cpuexecutioncap', '100'
                            ]

                v.memory = 4096

                # set the vm's cpus to the number of host cpus
                if RUBY_PLATFORM.downcase.include? "darwin"
                    v.cpus = `sysctl -n hw.physicalcpu`
                elsif RUBY_PLATFORM.downcase.include? "linux"
                    v.cpus = `nproc`
                end
            end

            vmconfig.vm.synced_folder "build", "/vagrant"

            vmconfig.vm.provision "shell", path: "vagranttools/setup_basic.ps1"

            outputdir = "\\\\vboxsvr\\vagrant\\msvc#{msvc}\\snapshots"
            snapshot1dir= "#{outputdir}\\SNAPSHOT-01"
            snapshot2dir= "#{outputdir}\\SNAPSHOT-02"
            cmpdir= "#{outputdir}\\CMP"

            vmconfig.vm.provision "shell", path: "vagranttools/snapshot.bat", args: [ snapshot1dir ]

            if msvc == "test"
                vmconfig.vm.provision "shell", inline: "choco install -y firefox"
            else
                vmconfig.vm.provision "shell", path: "vagranttools/setup_msvc.ps1", 
                                               args: [ "-msvc_ver", msvc, "-output_dir", snapshot2dir ]
            end
            vmconfig.vm.provision :reload

            vmconfig.vm.provision "shell", path: "vagranttools/snapshot.bat", args: [ snapshot2dir ]

            vmconfig.vm.provision "shell", path: "vagranttools/compare-snapshots.bat", 
                                           args: [ snapshot1dir, snapshot2dir, cmpdir ]
        end
    end
end
