#!/usr/bin/env bash
 
source `dirname $0`/box_env

baseboxinfo=`vagrant box list -i | grep $box_name | grep ' 0)'`
echo $baseboxinfo

set -e

if [ -z "$baseboxinfo" ]
then
    if [ ! -f "$box_file" ]; then
        `dirname $0`/downloadbasebox.sh
    fi

    vagrant box add --force "$box_file" --name "$box_name"
    vagrant box list
    test -f "$box_file" && rm "$box_file"
fi
