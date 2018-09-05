require 'rubygems'
require 'net/ssh'

# Vagrant doesn't like using Posix SSH for Windows.
# Here we implement a poor-man's SSH provisioner
# that let's us dodge this limitation. 

module CustomVagrantPlugins
    module Ssh
        class Config < Vagrant.plugin("2", :config)
            attr_accessor :inline
        end

        class Plugin < Vagrant.plugin("2")
            name "SSH Plugin"

            config("ssh", :provisioner) do
                Config
            end

            provisioner("ssh") do
                Provisioner
            end
        end

        class Provisioner < Vagrant.plugin("2", :provisioner)
            def provision
                ssh_info = @machine.ssh_info
                ssh = Net::SSH.start(ssh_info[:host],
                                     ssh_info[:username], 
                                     :password => ssh_info[:password], 
                                     :port => ssh_info[:port])

                puts @config.inline
                res = ssh.exec!(@config.inline)
            end
        end
    end
end
