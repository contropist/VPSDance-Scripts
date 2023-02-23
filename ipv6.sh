#!/usr/bin/env bash
# curl https://sh.vps.dance/ipv6.sh | bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE="\033[34m"
PURPLE="\033[35m"
BOLD="\033[1m"
NC='\033[0m'

success() { printf "${GREEN}%s${NC} ${@:2}\n" "$1"; }
info() { printf "${BLUE}%s${NC} ${@:2}\n" "$1"; }
danger() { printf "${RED}[x] %s${NC}\n" "$@"; }

sysctl_conf="/etc/sysctl.conf"

reload_sysctl() { sysctl -q -p && sysctl --system; }
restart_service() {
  info "[*] 可能要重启后生效"
  # systemctl restart NetworkManager # latest version Debian/Ubuntu/CentOS
  # systemctl restart networking # Debian/Ubuntu
  # systemctl restart network # CentOS
}
check_sysctl() {
  if [ ! -f "$sysctl_conf" ]; then touch "$sysctl_conf"; fi
}

toggle_v6() {
  val="$@"
  echo "disable= $val";
  sed -i '/net.ipv6.conf.\(all\|default\).disable_ipv6/d' "$sysctl_conf"
  echo "net.ipv6.conf.all.disable_ipv6=$val" >> "$sysctl_conf"
  echo "net.ipv6.conf.default.disable_ipv6=$val" >> "$sysctl_conf"
}

main() {
  check_sysctl
  if [[ "$num" == "1" ]]; then toggle_v6 0
  elif [[ "$num" == "2" ]]; then toggle_v6 1
  else exit
  fi
  reload_sysctl
  restart_service
}

menu() {
  clear;
  info "启用/禁用 IPV6, 请选择: "
  local AR=(
    [1]='启用'
    [2]='禁用'
  )
  for i in "${!AR[@]}"; do
    success "$i." "${AR[i]}"
  done
  while :; do
    read -p "输入数字以选择: " num
    [[ -n "${AR[num]}" ]] || { danger "invalid number"; continue; }
    break
  done
  main
}

# check_sysctl
menu
