#!/usr/bin/env bash
 
# Microsoft's "Microsoft/EdgeOnWindows10" vagrant cloud image is out of date, so we have to jump through hoops
# see https://github.com/MicrosoftEdge/dev.microsoftedge.com-vms/issues/22

baseboxinfo=`vagrant box list -i | grep Microsoft/EdgeOnWindows10 | grep ' 0)'`
echo $baseboxinfo

# make sure we successful execute commands
set -e

if [ -z "$baseboxinfo" ]
then
    mkdir -p build

    if [ ! -f "build/MSEdge - Win10.box" ]; then
        wget https://az792536.vo.msecnd.net/vms/VMBuild_20180425/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip -O build/MSEdge.Win10.Vagrant.zip
        unzip -d build build/MSEdge.Win10.Vagrant.zip
    fi

    vagrant box add --force "build/MSEdge - Win10.box" --name "Microsoft/EdgeOnWindows10"
    vagrant box list
fi
