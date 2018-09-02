# Vagrant File (Vagrantfile)
# http://docs.vagrantup.com/v2/vagrantfile/index.html

Vagrant.require_version ">= 2.1.4"

# plugin checks
required_plugins = %w(
  vagrant-reload
)

# bring in provisioner that lets us do Posix SSH on windows
require_relative 'vagranttools/ssh_provisioner.rb'

# msvcs    test , 2012, 2013 2015, 2017
msvcs = [ 'test',   11,   12,  14,   15 ]

Vagrant.configure("2") do |config|
    # provision a box for each MSVC
    msvcs.each do |msvc|
        vmname = "win-msvc%s" % [ msvc ]

        config.vm.define vmname do |vmconfig|
            vmconfig.vm.box = "Microsoft/EdgeOnWindows10"
            vmconfig.vm.guest = :windows
            vmconfig.vm.synced_folder "build", "/vagrant"

            vmconfig.winrm.username = vmconfig.ssh.username = "IEUser"
            vmconfig.winrm.password = vmconfig.ssh.password = "Passw0rd!"
            vmconfig.ssh.insert_key = false

            vmconfig.vm.boot_timeout = ENV['TIMEOUT'].to_i if ENV['TIMEOUT']

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

            if ENV['FIRSTBOOT']
                vmconfig.vm.communicator = "ssh"

                # make the network private so that WinRM isn't blocked by the firewall
                # (fortunately the basebox has SSH running)
                vmconfig.vm.provision "ssh", inline: 'powershell "Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private"'
                vmconfig.vm.provision "ssh", inline: 'powershell "winrm quickconfig -quiet -force"'
                vmconfig.vm.provision "ssh", inline: 'shutdown -t 0 -s -f'
            else
                vmconfig.vm.communicator = "winrm"

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
end
