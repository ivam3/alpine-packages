#!/bin/ash
IFS=$'\n\t'
trap ctrl_c 2
host="https://raw.githubusercontent.com/ivam3/alpine-packages/master"
tools="$@"

ctrl_c(){ echo -en "\e[33mW:\e[0m Aborted by user\n"; exit 666;}

usage(){
  echo -en "Usage: ash alpine-pkg.sh [-h/list/del/<package(s) name>]\n\n-h\t\tShow this help\nlist\t\tList all available packages\npackage(s) name\tThe name of package(s) to install\ndel\t\tDelete package(s)\n\nex: ash alpine-pkg.sh kerbrute enum4linux-ng bloodyAD\n"
  exit 0
}

chkEnv(){
  local pkg=$1
  if [[ -d /opt/env-$pkg ]] || [[ -d /opt/$pkg ]]; then
    return 0
  fi
}

[[ $# -eq 0 ]] && { usage;}

if [[ $1 = "list" ]]; then
  echo -en "\e[33m[!]\e[0m Available packages:\n\n"
  curl -s "$host/pkglist.txt" 2>/dev/null
  exit 0

elif [[ $1 = "del" ]]; then
  [[ -z $2 ]] && { usage;}

  shift 1
  pkgs="$@"

  for pkg in $pkgs; do
    echo $pkg
    if ! chkEnv $pkg; then
      rm -rf /opt/env-$pkg /opt/$pkg 2>/dev/null
      echo -en "[-] Package $pkg removed\n"
      exit 0
    else
      echo -en "\e[31mE:\e[0m Package $pkg is not installed\n"
      exit 0
    fi
  done

else
  for pkg in $tools;do
    grep -oE "$pkg" <(curl -sSL "$host/pkglist.txt") &>/dev/null || { 
      echo -en "\e[31mE:\e[0m Unable to locate package $pkg\n"
      exit 1
    }
    
    chkEnv $pkg || { 
      echo -en "\e[33m[!]\e[0m Package $pkg already exists\n"
      exit 2
    } 
    wget --tries=5 --quiet "$host/$pkg.tar.gz" -O /tmp/$pkg.tar.gz 2>/dev/null
    
    if [[ ! -e /tmp/$pkg.tar.gz ]] || [[ ! -s /tmp/$pkg.tar.gz ]]; then 
      echo -en "\e[31mE:\e[0m Missing tar file for package $pkg\n"
      exit 3
    fi
    tar -zcvf /tmp/$pkg.tar.gz -C /opt/ 2>/dev/null
    
    if [[ -d /opt/env-$pkg ]] || [[ -d /opt/$pkg ]]; then
      echo -en "\e[32m[+]\e[0m DONE! Packages $pkg saved in /opt\n"
      exit 0
    else
      echo -en "\e[31mE:\e[0m Decompressing $pkg failure\n"
      exit 4
    fi
  done
fi
#     @Ivam3
