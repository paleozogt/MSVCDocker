#!/bin/bash

# You must accept the Oracle Binary Code License
# http://www.oracle.com/technetwork/java/javase/terms/license/index.html
# usage: get_jdk.sh <jdk_version> <ext>
# jdk_version: 8(default) or 9
# ext: rpm or tar.gz

jdk_version=${1:-8}
jdk_arch=${2:-x64}
ext=${3:-exe}

readonly url="https://www.oracle.com"
readonly jdk_download_url1="$url/technetwork/java/javase/downloads/index.html"
readonly jdk_download_url2=$(
    curl -s $jdk_download_url1 | \
    egrep -o "\/technetwork\/java/\javase\/downloads\/jdk${jdk_version}-downloads-.+?\.html" | \
    head -1 | \
    cut -d '"' -f 1
)
[[ -z "$jdk_download_url2" ]] && echo "Could not get jdk download url - $jdk_download_url1" >> /dev/stderr

readonly jdk_download_url3="${url}${jdk_download_url2}"
readonly jdk_download_url4=$(
    curl -s $jdk_download_url3 | \
    egrep -o "https\:\/\/download.oracle\.com\/otn-pub\/java\/jdk\/[8-9](u[0-9]+|\+).*\/jdk-${jdk_version}.*(-|_)windows-(${jdk_arch}|${jdk_arch}_bin).$ext"
)

for dl_url in ${jdk_download_url4[@]}; do
    echo downloading $dl_url
    wget --no-cookies \
         --no-check-certificate \
         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
         -N $dl_url
done