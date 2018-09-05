# Vagrant File (Vagrantfile)
# http://docs.vagrantup.com/v2/vagrantfile/index.html

Vagrant.require_version ">= 2.1.4"

# plugin checks
required_plugins = %w(
  vagrant-reload
)

# bring in provisioner that lets us do Posix SSH on windows
require_relative 'vagranttools/ssh_provisioner.rb'

# msvcs    test , 2010, 2012, 2013 2015, 2017
msvcs = [ 'test',   10,   11,   12,  14,   15 ]

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
                # fortunately the basebox has SSH running
                vmconfig.vm.communicator = "ssh"

                # turn off firewall
                vmconfig.vm.provision "ssh", inline: 'powershell "Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private"'
                vmconfig.vm.provision "ssh", inline: 'powershell "NetSh Advfirewall set allprofiles state off" '

                # turn off UAC
                vmconfig.vm.provision "ssh", inline: 'cmd /c "reg add HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /v EnableLUA /d 0 /t REG_DWORD /f /reg:64"'

                # turn on winrm on startup
                startup_folder = "/cygdrive/c/Users/#{vmconfig.ssh.username}/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
                winrm_config = 'cmd /k C:\\Windows\\System32\\winrm.cmd quickconfig --force -quiet'
                vmconfig.vm.provision "ssh", inline: "echo '#{winrm_config}' > '#{startup_folder}/winrm_config.bat'"

                # shutdown
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
