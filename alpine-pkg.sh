#!/bin/bash
IFS=$'\n\t'
trap ctrl_c 2
host="https://raw.githubusercontent.com/ivam3/alpine-packages/master"
declare -a tools="${@:1}"

ctrl_c(){ echo -en "\e[33mW:\e[0m Aborted by user"; exit 666;}

while [[ $# -eq 0 ]]; do
  echo -en "Usage: bash alpine-pkg.sh [-h/list/<package(s) name>]\n\n-h\t\tShow this help\nlist\t\tList all available packages\npackage(s) name\tThe name of package(s) to install\n\nex: bash alpine-pkg.sh kerbrute enum4linux-ng bloodyAD\n"
  exit
done

[[ $1 = "list" ]] && { echo -en "\e[33m[!]\e[0m Available packages:\n\n";curl -s "$host/pkglist.txt" 2>/dev/null;exit 0;}


for pkg in ${tools[*]};do
  
  ! curl -s "$host/pkglist.txt"|grep $pkg 2>/dev/null && { echo -en "\e[31mE:\e[0m Unable to locate package $pkg";exit 1;}
  wget --tries=5 --quiet "$host/$pkg.tar.gz" -O /tmp/$pkg.tar.gz
  [[ -e /tmp/$pkg.tar.gz ]] || { echo -en "\e[31mE:\e[0m Unreachable package $pkg";exit 2;}
  tar -zcvf /tmp/$pkg.tar.gz -C /opt/
  [[ -d /opt/env-$pkg ]] || { echo -en "\e[31mE:\e[0m Decompressing $pkg failure";exit 3;}
  echo -en "\e[32m[+]\e[0m DONE! Packages $pkg saved in /opt";exit 0

done

#     @Ivam3
