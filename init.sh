#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://cdn.statically.io/gh/VPSDance/scripts/main/init.sh) [snell|realm|gost|ss|nali|wtrace|ddns-go]
# bash <(curl -Lso- https://cdn.jsdelivr.net/gh/VPSDance/scripts@main/init.sh)
# bash <(curl -Lso- https://raw.githack.com/VPSDance/scripts/main/init.sh)
# bash <(curl -Lso- https://raw.fastgit.org/VPSDance/scripts/main/init.sh)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE="\033[34m"
PURPLE="\033[35m"
SKYBLUE="\033[36m"
BOLD="\033[1m"
NC='\033[0m'

OS=$(uname -s) # Linux, FreeBSD, Darwin
ARCH=$(uname -m) # x86_64, arm64, aarch64
DISTRO=$( ([[ -e "/usr/bin/yum" ]] && echo 'CentOS') || ([[ -e "/usr/bin/apt" ]] && echo 'Debian') || echo 'unknown' )
# name=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
debug=$( [[ $OS == "Darwin" ]] && echo true || echo false )

check_root() {
  if [[ "$USER" != 'root' ]]; then # [[ "$EUID" -ne 0 ]]
    error "Please run this script as root!"; exit 1;
    # if [[ "$debug" != true ]]; then exit 1; fi
  fi
}
next() {
  printf "%-37s\n" "-" | sed 's/\s/-/g'
}
error() {
  printf "${RED}[x] %s${NC}\n" "$@"
}
info() {
  printf "${SKYBLUE}%s${NC}\n" "$@"
}
warn() {
  printf "${YELLOW}%s${NC}\n" "$@"
}
# if (ver_lte 3 3.0); then echo 3; else echo 2; fi # ver_lte 2.5.7 3 && echo "yes" || echo "no"
ver_lte() { # <=
  [  "$(printf '%s\n' "$@" | sort -V | head -n 1)" = "$1" ] && return 0 || return 1
}
# if (ver_lt 2.9 3); then echo 2; else echo 3; fi
ver_lt() { # <
  [ "$1" = "$2" ] && return 1 || ver_lte "$1" "$2"
}
python_version() {
  python -V 2>&1 | awk '{print $2}' # | awk -F '.' '{print $1}'
}

header() {
  next
  printf "%s\n" "[VPS Tool box]"
  printf "%b\n" "${GREEN}VPS/IPLC测评:${NC} ${YELLOW}https://vps.dance/${NC}"
  printf "%b\n" "目前支持: Ubuntu/Debian, Centos/Redhat"
  next
}
footer() {
  next
  printf "%b\n" "Supported by: https://vps.dance"
  next
}

install_deps() {
  case "${DISTRO}" in
    Debian*|Ubuntu*)
      apt update -y;
      apt install -y curl wget htop zip unzip xz-utils gzip ca-certificates net-tools dnsutils iputils-ping mtr traceroute telnet tcpdump;
      bash <(curl -s https://install.speedtest.net/app/cli/install.deb.sh);
      apt install  -y speedtest;
    ;;
    CentOS*|RedHat*)
      yum update -y;
      yum install -y epel-release which openssl curl wget htop zip unzip xz gzip ca-certificates net-tools bind-utils iputils mtr traceroute telnet tcpdump;
      curl -s https://install.speedtest.net/app/cli/install.rpm.sh | sudo bash
      yum install -y speedtest
    ;;
  esac
}
install_bbr() {
  bash <(curl -Lso- https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
}
install_tool() {
  bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/tools.sh) "$@"
}
install_wireguard(){
  curl -Ls https://raw.githubusercontent.com/teddysun/across/master/wireguard.sh | bash -s -- -r
  # uninstall_wireguard
  # curl -Ls https://raw.githubusercontent.com/teddysun/across/master/wireguard.sh | bash -s -- -n
}
unlock_test() {
  bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/unlockTest.sh)
}
super_bench() {
  bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/superBench.sh)
  curl -sL https://raw.githubusercontent.com/VPSDance/scripts/main/superBench.sh | bash -s io
}
bench() {
  bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/bench.sh)
}
super_speed() {
  bash <(curl -Lso- https://raw.githubusercontent.com/flyzy2005/superspeed/master/superspeed.sh)
}
yabs() {
  info "curl -sL yabs.sh | bash -s -- -dir"
  curl -sL yabs.sh | bash -s -- -dir
}
unix_bench() {
  bash <(curl -Lso- https://raw.githubusercontent.com/teddysun/across/master/unixbench.sh)
}
reinstall() {
  bash <(curl -Lso- https://raw.githubusercontent.com/hiCasper/Shell/master/AutoReinstall.sh)
}

start() {
  header
  echo -e "${BLUE}请选择要使用的功能${NC}"
  info "1. [推荐] 安装常用软件 (curl/wget/ping/traceroute...)"
  info "2. [推荐] 安装并开启 BBR"
  # info "3. [推荐] 系统配置优化"
  info "11. 安装 shadowsocks"
  info "12. 安装 snell"
  info "13. 安装 realm (端口转发工具)"
  info "14. 安装 gost (隧道/端口转发工具)"
  info "15. 安装 nali (IP查询工具)"
  info "16. 安装 wtrace (路由追踪工具 WorstTrace)"
  info "17. 安装 ddns-go (DDNS工具)"
  # info "19. 安装 wireguard"
  info "21. 检测 VPS流媒体解锁 (RegionRestrictionCheck)"
  info "22. 检测 VPS系统/IO/到国内网速 (SuperBench)"
  info "23. 检测 VPS系统/IO/到国际网速 (Bench.sh)"
  info "24. 性能测试 (YABS)"
  # info "25. 检测 到国内网速(电信/移动/联通) (Superspeed)"
  # info "29. 性能测试 (UnixBench)"
  # info "31. DD重装Linux系统"
  while :; do
    read -p "输入数字以选择:" num
    [[ $num =~ ^[0-9]+$ ]] || { error "请输入正确的数字"; continue; }
    break
    # if ((num >= 1 && num <= 5)); then
    #   break
    # else
    #   error "请输入正确的数字";
    # fi
  done
}

main() {
  clear
  header
  if [[ "$num" == "1" ]]; then install_deps
	elif [[ "$num" == "2" ]]; then install_bbr
	elif [[ "$num" == "3" ]]; then tcpx
	elif [[ "$num" == "11" ]]; then install_tool "ss"
	elif [[ "$num" == "12" ]]; then install_tool "snell"
	elif [[ "$num" == "13" ]]; then install_tool "realm"
	elif [[ "$num" == "14" ]]; then install_tool "gost"
	elif [[ "$num" == "15" ]]; then install_tool "nali"
	elif [[ "$num" == "16" ]]; then install_tool "wtrace"
	elif [[ "$num" == "17" ]]; then install_tool "ddns-go"
	# elif [[ "$num" == "19" ]]; then install_wireguard
	elif [[ "$num" == "21" ]]; then unlock_test
	elif [[ "$num" == "22" ]]; then super_bench
	elif [[ "$num" == "23" ]]; then bench
	elif [[ "$num" == "24" ]]; then yabs
	# elif [[ "$num" == "25" ]]; then super_speed
	# elif [[ "$num" == "29" ]]; then unix_bench
	# elif [[ "$num" == "31" ]]; then reinstall
  else exit
	fi
}

check_root
start
main
