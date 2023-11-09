#!/bin/bash
IFS=$'\n\t'
trap ctrl_c 2
host="https://raw.githubusercontent.com/ivam3/alpine-packages/master"
tool=$1

ctrl_c(){ echo "\e[33mW:\e[0m Aborted by user"; exit 3;}

while [[ $# -eq 0 ]]; do
  echo "Usage: bash alpine-pkg.sh [-h/list/packages name]"
  exit
done

[[ $1 = "list" ]] && { curl -q "$host/pkglist";}

! curl -q "$host/pkglist"|grep $tool 2>dev/null && { echo "\e[31mE:\e[0m Unable to locate package $tool";exit 1;}

wget --tries=5 --quiet "$host/$pkg.tar.gz" -O /tmp/$pkg.tar.gz
[[ -e /tmp/$pkg.tar.gz ]] || { echo "\e[31mE:\e[0m Unreachable package $tool";exit 2;}
tar -zcvf /tmp/$pkg.tar.gz -C /opt/

#     @Ivam3
