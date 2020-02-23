#!/usr/bin/env bash

source `dirname $0`/box_env
set -e

mkdir -p build
wget "$box_url" -O "$box_zip"
unzip -d build "$box_zip"
test -f "$box_file" && rm "$box_zip"
