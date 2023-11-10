#!/bin/bash
IFS=$'\n\t'
trap ctrl_c 2
host="https://raw.githubusercontent.com/ivam3/alpine-packages/master"
declare -a tools="${@:1}"

ctrl_c(){ echo -en "\e[33mW:\e[0m Aborted by user"; exit 666;}

usage(){
  echo -en "Usage: bash alpine-pkg.sh [-h/list/del/<package(s) name>]\n\n-h\t\tShow this help\nlist\t\tList all available packages\npackage(s) name\tThe name of package(s) to install\ndel\t\tDelete package(s)\n\nex: bash alpine-pkg.sh kerbrute enum4linux-ng bloodyAD\n"
  exit 0
}

chkEnv(){
  local pkg=$1
  if [[ -d /opt/env-$pkg ]] || [[ -d /opt/$pkg ]]; then
    return 0
  fi
}

[[ $# -eq 0 ]] && { usage;}

[[ $1 = "list" ]] && { 
  echo -en "\e[33m[!]\e[0m Available packages:\n\n"
  curl -s "$host/pkglist.txt" 2>/dev/null
  exit 0
}

[[ $1 = "del" ]] && {
  [[ -z $2 ]] && { usage;}

  for pkg in ${@:2}; do
    chkEnv $pkg && { 
      rm -rf /opt/env-$pkg /opt/$pkg 2>/dev/null
      echo -en "[-] Package $pkg removed"
      exit 0
    } || { 
      echo -en "\e[31mE:\e[0m Package $pkg is not installed"
      exit 0
    }
  done
}

for pkg in ${tools[*]};do
  grep -oE "$pkg" <(curl -sSL "$host/pkglist.txt") &>/dev/null || { 
    echo -en "\e[31mE:\e[0m Unable to locate package $pkg"
    exit 1
  }
  
  chkEnv $pkg || { 
    echo -en "\e[33m[!]\e[0m Package $pkg already exists"
    exit 2
  } 
  wget --tries=5 --quiet "$host/$pkg.tar.gz" -O /tmp/$pkg.tar.gz 2>/dev/null
  
  [[ -e /tmp/$pkg.tar.gz ]] || { 
    echo -en "\e[31mE:\e[0m Missing tar file for package $pkg"
    exit 3
  }
  tar -zcvf /tmp/$pkg.tar.gz -C /opt/ 2>/dev/null
  
  [[ -d /opt/env-$pkg ]] || { 
    echo -en "\e[31mE:\e[0m Decompressing $pkg failure"
    exit 4
  }  
  echo -en "\e[32m[+]\e[0m DONE! Packages $pkg saved in /opt"
  exit 0
done

#     @Ivam3
