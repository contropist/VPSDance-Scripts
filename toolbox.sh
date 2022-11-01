#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://sh.vps.dance/toolbox.sh)
# bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/toolbox.sh)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE="\033[34m"
PURPLE="\033[35m"
BOLD="\033[1m"
NC='\033[0m'

OS=$(uname -s) # Linux, FreeBSD, Darwin
ARCH=$(uname -m) # x86_64, arm64, aarch64
DISTRO=$( ([[ -e "/usr/bin/yum" ]] && echo 'CentOS') || ([[ -e "/usr/bin/apt" ]] && echo 'Debian') || echo 'unknown' )
debug=$( [[ $OS == "Darwin" ]] && echo true || echo false )
cnd=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
SH='https://sh.vps.dance'
GH='https://ghproxy.com'

raw() {
  RAW='https://raw.githubusercontent.com'
  if [[ "$cnd" =~ ^(fastgit)$ ]]; then
    echo "https://raw.fastgit.org"
  elif [[ "$cnd" =~ ^(ghproxy)$ ]]; then
    echo "${GH}/${RAW}"
  elif [[ "${1}" =~ ^(ghproxy)$ ]]; then
    echo "${GH}/${RAW}"
  else
    echo $RAW
  fi
}
# echo $(raw 'ghproxy')
# curl -Ls "$(raw '')/VPSDance/scripts/main/ssh.sh"

check_root() {
  if [[ "$USER" != 'root' ]]; then # [[ "$EUID" -ne 0 ]]
    danger "Please run this script as root!"; exit 1;
    # if [[ "$debug" != true ]]; then exit 1; fi
  fi
}
next() {
  printf "%-37s\n" "-" | sed 's/\s/-/g'
}
success() {
  printf "${GREEN}%s${NC} ${@:2}\n" "$1"
}
info() {
  printf "${BLUE}%s${NC} ${@:2}\n" "$1"
}
danger() {
  printf "${RED}[x] %s${NC}\n" "$@"
}
warn() {
  printf "${YELLOW}%s${NC}\n" "$@"
}
nc() {
  printf "${NC}%s${NC}\n" "$@" # No Color
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
  printf "%s\n" "[VPS ToolBox] 目前支持: Ubuntu/Debian, Centos/Redhat"
  printf "%b\n" "${GREEN}VPS/IPLC测评:${NC} ${YELLOW}https://vps.dance/${NC}"
  printf "%b\n" "${GREEN}Telegram频道:${NC} ${YELLOW}https://t.me/vpsdance${NC}"
  next
}
footer() {
  BLUE="\033[34m"; NC='\033[0m'
  printf "%-37s\n" "-" | sed 's/\s/-/g'
  printf "%b\n" " Supported by: ${BLUE}https://vps.dance${NC}"
  printf "%-37s\n" "-" | sed 's/\s/-/g'
}

install_deps() {
  case "${DISTRO}" in
    Debian*|Ubuntu*)
      apt update -y;
      apt install -y curl wget htop zip unzip xz-utils gzip ca-certificates net-tools dnsutils iputils-ping mtr traceroute telnet tcpdump;
      apt install -y hping3;
      apt install -y python3 python3-pip;
    ;;
    CentOS*|RedHat*)
      yum update -y;
      yum install -y epel-release which openssl curl wget htop zip unzip xz gzip ca-certificates net-tools bind-utils iputils mtr traceroute telnet tcpdump;
      yum install -y hping3; # @epel-release
      yum install -y python3 python3-pip;
    ;;
  esac
}
install_bbr() {
  bash <(curl -Lso- $(raw 'ghproxy')/teddysun/across/master/bbr.sh)
}
ssh_key() {
  bash <(curl -Lso- ${SH}/ssh.sh)
}
bashrc() {
  bash <(curl -Lso- ${SH}/bashrc.sh)
}
tuning() {
  bash <(curl -Lso- ${SH}/tuning.sh)
}
ssh_port() {
  bash <(curl -Lso- ${SH}/ssh.sh) port
}
install_tool() {
  bash <(curl -Lso- ${SH}/tools.sh) "$@"
}
speedtest() {
  bash <(curl -Lso- ${SH}/speedtest.sh)
}
install_xray() {
  bash <(curl -fsSL $(raw 'ghproxy')/XTLS/Xray-install/main/install-release.sh) install
  # 使用增强版的 geosite/geoip 规则
  wget -O /usr/local/share/xray/geoip.dat ${GH}/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
  wget -O /usr/local/share/xray/geosite.dat ${GH}/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
  info "configuration file: /usr/local/etc/xray/config.json"
  info "status: systemctl status xray"
  info "restart: systemctl restart xray"
}
install_wrap() {
  bash <(curl -fsSL $(raw 'ghproxy')/P3TERX/warp.sh/main/warp.sh) menu
}
install_wireguard(){
  curl -Ls $(raw 'ghproxy')/teddysun/across/master/wireguard.sh | bash -s -- -r
  # uninstall_wireguard
  # curl -Ls $(raw 'ghproxy')/teddysun/across/master/wireguard.sh | bash -s -- -n
}
unlock_test() {
  info "bash <(curl -Lso- "$(raw 'ghproxy')/lmc999/RegionRestrictionCheck/main/check.sh")"
  bash <(curl -Lso- ${SH}/unlockTest.sh)
}
# super_bench() {
#   bash <(curl -Lso- ${SH}/superBench.sh)
# }
bench() {
  bash <(curl -Lso- ${SH}/bench.sh)
}
super_speed() {
  bash <(curl -Lso- $(raw 'ghproxy')/flyzy2005/superspeed/master/superspeed.sh)
}
lemon_bench() {
  curl -fsSL http://ilemonra.in/LemonBenchIntl | bash -s fast
}
yabs() {
  info "curl -sL yabs.sh | bash -s -- -dir"
  curl -sL yabs.sh | bash -s -- -dir
}
besttrace() {
  bash <(curl -Lso- ${SH}/autoBestTrace.sh)
}
nexttrace() {
  bash <(curl -Lso- ${SH}/autoNexttrace.sh)
}
unix_bench() {
  bash <(curl -Lso- $(raw 'ghproxy')/teddysun/across/master/unixbench.sh)
}
reinstall() {
  bash <(curl -Lso- $(raw 'ghproxy')/hiCasper/Shell/master/AutoReinstall.sh)
}

menu() {
  header
  info "请选择要使用的功能"
  success "1." "[推荐] 配置SSH Public Key (SSH免密登录)"
  success "2." "[推荐] 终端优化 (颜色美化/上下键查找历史)"
  success "3." "[推荐] 安装并开启 BBR"
  success "4." "[推荐] 安装常用软件 (curl/wget/ping/traceroute)"
  success "5." "[推荐] 系统优化 (TCP网络优化/资源限制优化)"
  success "6." "[推荐] 修改默认SSH端口 (防止被攻击)"
  success "10." "安装 xray"
  success "11." "安装 shadowsocks"
  success "12." "安装 snell"
  success "13." "安装 realm (端口转发工具)"
  success "14." "安装 gost (隧道/端口转发工具)"
  success "15." "安装 nali (IP查询工具)"
  success "16." "安装 ddns-go (DDNS工具)"
  # success "17." "安装 warp"
  # success "18." "安装 wireguard"
  # success "19." "安装 wtrace (路由追踪工具 WorstTrace)"
  success "21." "检测 VPS流媒体解锁 (RegionRestrictionCheck)"
  success "22." "检测 VPS信息/IO/网速 (Bench.sh)"
  success "23." "检测 VPS到国内网速"
  # success "23." "检测 VPS到国内网速 (Superspeed)"
  success "24." "性能测试 (YABS)"
  success "25." "检测 回程路由 (BestTrace)"
  success "26." "检测 回程路由 (NextTrace)"
  # success "25." "检测 VPS信息/IO/路由 (LemonBench)"
  # success "29." "性能测试 (UnixBench)"
  # success "31." "DD重装Linux系统"
  while :; do
    read -p "输入数字以选择:" num
    [[ $num =~ ^[0-9]+$ ]] || { danger "请输入正确的数字"; continue; }
    break
    # if ((num >= 1 && num <= 5)); then
    #   break
    # else
    #   danger "请输入正确的数字";
    # fi
  done
}

main() {
  clear
  header
  if [[ "$num" == "1" ]]; then ssh_key
  elif [[ "$num" == "2" ]]; then bashrc
  elif [[ "$num" == "3" ]]; then install_bbr
  elif [[ "$num" == "4" ]]; then install_deps
  elif [[ "$num" == "5" ]]; then tuning
  elif [[ "$num" == "6" ]]; then ssh_port
  elif [[ "$num" == "10" ]]; then install_xray
  elif [[ "$num" == "11" ]]; then install_tool "ss"
  elif [[ "$num" == "12" ]]; then install_tool "snell"
  elif [[ "$num" == "13" ]]; then install_tool "realm"
  elif [[ "$num" == "14" ]]; then install_tool "gost"
  elif [[ "$num" == "15" ]]; then install_tool "nali"
  elif [[ "$num" == "16" ]]; then install_tool "ddns-go"
  # elif [[ "$num" == "17" ]]; then install_tool "nexttrace"
  # elif [[ "$num" == "17" ]]; then install_wrap
  # elif [[ "$num" == "18" ]]; then install_wireguard
  # elif [[ "$num" == "19" ]]; then install_tool "wtrace"
  elif [[ "$num" == "21" ]]; then unlock_test
  elif [[ "$num" == "22" ]]; then bench
  elif [[ "$num" == "23" ]]; then speedtest
  elif [[ "$num" == "24" ]]; then yabs
  elif [[ "$num" == "25" ]]; then besttrace
  elif [[ "$num" == "26" ]]; then nexttrace
  # elif [[ "$num" == "29" ]]; then unix_bench
  # elif [[ "$num" == "31" ]]; then reinstall
  else exit
  fi
}

check_root
menu
main
