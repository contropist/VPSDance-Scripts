#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://sh.vps.dance/tools.sh) [snell|snell4|realm|gost|ss|nali|wtrace|ddns-go|nexttrace]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD="\033[1m"
NC='\033[0m'

OS=$(uname -s) # Linux, FreeBSD, Darwin
ARCH=$(uname -m) # x86_64, arm64/aarch64, i386, 
# DISTRO=$( [[ -e $(which lsb_release) ]] && (lsb_release -si) || echo 'unknown' ) which/lsb_release command not found
DISTRO=$( ([[ -e "/usr/bin/yum" ]] && echo 'CentOS') || ([[ -e "/usr/bin/apt" ]] && echo 'Debian') || echo 'unknown' )
name=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
# prerelease=$( [[ "${2}" =~ ^(-p|prerelease)$ ]] && echo true || echo false )
prerelease=true
debug=$( [[ $OS == "Darwin" ]] && echo true || echo false )

check_root () {
  if [[ "$USER" != 'root' ]]; then # [[ "$EUID" -ne 0 ]]
    printf "${RED}[x] Please run this script as root! \n${NC}"; exit 1;
    # if [[ "$debug" != true ]]; then exit 1; fi
  fi
}
prompt_yn () {
  while true; do
    read -p "$1 (y/N)" yn
    case "${yn:-${2:-N}}" in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes(y) or no(n).";;
    esac
  done
}
init () {
  case "$name" in
    snell | snell4)
      app="$name"
      config="/root/$app.conf"
      # repo="surge-networks/snell"
      case $ARCH in
        aarch64 | armv8)
          match="linux-aarch64"
        ;;
        armv7 | armv6l)
          match="linux-armv7l"
        ;;
        *) #x86_64
         match="linux-amd64"
        ;;
      esac
    ;;
    realm)
      app="realm"
      config="/root/realm.toml"
      repo="zhboner/realm"
      # repo="zephyrchien/realm"
      # match=""
      case $ARCH in
        aarch64)
          match="aarch64.*linux-gnu.*.gz"
        ;;
        *) #x86_64
         match="x86_64.*linux-gnu.*.gz"
        ;;
      esac
    ;;
    gost)
      app="gost"
      config="/root/gost.json"
      repo="ginuerzh/gost"
      case $ARCH in
        aarch64)
          match="linux-armv8"
        ;;
        *) #x86_64
         match="linux-amd64"
        ;;
      esac
    ;;
    ss | shadowsocks)
      app="ss"
      config="/root/ss.json"
      repo="shadowsocks/shadowsocks-rust"
      case $ARCH in
        aarch64)
          match="aarch64.*linux-gnu"
        ;;
        *)
         match="x86_64.*linux-gnu"
        ;;
      esac
    ;;
    nali)
      app="nali"
      repo="zu1k/nali"
      case $ARCH in
        aarch64)
          match="linux-armv8"
        ;;
        *)
         match="linux-amd64"
        ;;
      esac
    ;;
    wtrace | worsttrace)
      app="wtrace"
    ;;
    ddns-go)
      app="ddns-go"
      config="/root/ddns-go.yaml"
      repo="jeessy2/ddns-go"
      case $ARCH in
        aarch64)
          match="linux_.*arm64"
        ;;
        *)
         match="linux_.*x86_64"
        ;;
      esac
    ;;
    nexttrace)
      app="nexttrace"
      repo="nxtrace/Ntrace-core"
      case $ARCH in
        aarch64)
          match="linux_arm64"
        ;;
        *)
         match="linux_amd64"
        ;;
      esac
    ;;
    *)
      printf "${YELLOW}Please specify app_name (snell|realm|gost|ss|nali|wtrace|ddns-go|nexttrace)\n\n${NC}";
      exit
    ;;
  esac
}
install_deps () {
    case "${DISTRO}" in
    Debian*|Ubuntu*)
      apt install -y curl wget zip unzip tar xz-utils gzip;
    ;;
    CentOS*|RedHat*)
      yum install -y curl wget zip unzip tar xz gzip;
    ;;
    *)
    ;;
  esac
}
download () {
  suffix=$( [[ "$prerelease" = true ]] && echo "releases" || echo "releases/latest" )
  if [[ -n "$repo" ]]; then
    api="https://api.github.com/repos/$repo/$suffix"
    # echo "curl -s $api | grep \"browser_download_url.*$match\" | head -1"; exit;
    url=$( curl -s $api | grep "browser_download_url.*$match" | head -1 | cut -d : -f 2,3 | xargs echo ) # xargs wget
    # url=${url/"https://github.com"/"https://hub.fastgit.org"} # cdn
    url="https://ghproxy.com/$url" # cdn
  fi
  echo $app
  case "$app" in
    snell)
      version="v3.0.1"
      url="https://raw.githubusercontent.com/VPSDance/files/main/snell/${version}/snell-server-${version}-${match}.zip"
      url="https://ghproxy.com/$url" # cdn
    ;;
    snell4)
      # https://manual.nssurge.com/others/snell.html
      version="v4.0.1"
      # url="https://raw.githubusercontent.com/VPSDance/files/main/snell/${version}/snell-server-${version}-${match}.zip"
      # url="https://ghproxy.com/$url" # cdn
      url="https://dl.nssurge.com/snell/snell-server-${version}-${match}.zip"
    ;;
    realm)
      if [[ "$debug" != true ]]; then
        rm -rf /usr/bin/realm ./realm;
      fi
    ;;
    wtrace)
      case $ARCH in
        aarch64)
          printf "${RED}[x] $ARCH not supported ${PLAIN}\n${NC}"; exit 1;
        ;;
        *)
         url="https://pkg.wtrace.app/linux/worsttrace"
        ;;
      esac
    ;;
  esac
  echo -e "${GREEN}\n[Download]${NC} $url"
  if [[ "$debug" != true ]]; then
    wget $url
  fi
  # echo -e "\n[Extract files]"
  # tar xJvf .tar.xz/.txz # apt install -y xz-utils
  # tar xzvf .tar.gz
  # tar xvf .tar 
  # unzip -o .zip # apt install -y unzip
  # gzip -d .gz
  if [[ "$debug" = true ]]; then return; fi
  case "$app" in
    snell)
      unzip -o snell*.zip; rm -rf snell-server-*.zip*;
      mv ./snell-server /usr/bin/;
    ;;
    snell4)
      unzip -o snell*.zip; rm -rf snell-server-*.zip*;
      mv ./snell-server /usr/bin/snell4-server;
    ;;
    realm)
      # curl -s https://api.github.com/repos/zhboner/realm/releases/latest | grep "browser_download_url.*" | cut -d : -f 2,3 | xargs wget -O ./realm {}; chmod +x realm
      if [[ `compgen -G "realm*.tar.gz"` ]]; then tar xzvf realm*.tar.gz; rm -rf realm*.tar.gz; fi
      mv ./realm /usr/bin/realm; chmod +x /usr/bin/realm;
    ;;
    gost)
      gzip -d gost-*.gz; mv ./gost-* /usr/bin/gost; chmod +x /usr/bin/gost;
    ;;
    ss)
      tar xJf shadowsocks-*.xz && rm -rf shadowsocks-*.xz*; mv ./ssserver ./sslocal ./ssurl ./ssmanager ./ssservice /usr/bin/;
    ;;
    nali)
      gzip -d nali-*.gz; mv ./nali-* /usr/bin/nali; chmod +x /usr/bin/nali;
      nali update;
    ;;
    wtrace)
      mv ./worsttrace /usr/bin/worsttrace; chmod +x /usr/bin/worsttrace;
    ;;
    ddns-go)
      tar xzf ddns-go_*tar.gz; mv ./ddns-go /usr/bin/; rm -rf ddns-go_*tar.gz* LICENSE README.md;
    ;;
    nexttrace)
      mv ./nexttrace_* /usr/bin/nexttrace; chmod +x /usr/bin/nexttrace;
    ;;
    *);;
  esac
}
gen_service () {
  case "$app" in
    snell)
      service='[Unit]\nDescription=Snell Service\nAfter=network.target\n[Service]\nType=simple\nLimitNOFILE=32768\nRestart=on-failure\nExecStart=/usr/bin/snell-server -c /root/snell.conf\nStandardOutput=syslog\nStandardError=syslog\nSyslogIdentifier=snell-server\n[Install]\nWantedBy=multi-user.target\n'
    ;;
    snell4)
      service='[Unit]\nDescription=Snell Service\nAfter=network.target\n[Service]\nType=simple\nLimitNOFILE=32768\nRestart=on-failure\nExecStart=/usr/bin/snell4-server -c /root/snell4.conf\nStandardOutput=syslog\nStandardError=syslog\nSyslogIdentifier=snell-server\n[Install]\nWantedBy=multi-user.target\n'
    ;;
    realm)
      service='[Unit]\nDescription=realm\nAfter=network-online.target\nWants=network-online.target systemd-networkd-wait-online.service\n[Service]\nType=simple\nUser=root\nRestart=on-failure\nRestartSec=5s\nExecStart=/usr/bin/realm -c /root/realm.toml\n[Install]\nWantedBy=multi-user.target'
    ;;
    gost)
      service='[Unit]\nDescription=gost\nAfter=network-online.target\nWants=network-online.target systemd-networkd-wait-online.service\n[Service]\nType=simple\nUser=root\nRestart=on-failure\nRestartSec=5s\nExecStart=/usr/bin/gost -C /root/gost.json\n[Install]\nWantedBy=multi-user.target'
    ;;
    ss)
      service='[Unit]\nDescription=Shadowsocks\nAfter=network.target\n[Service]\nType=simple\nRestart=on-failure\nExecStart=/usr/bin/ssserver -c /root/ss.json\n[Install]\nWantedBy=multi-user.target\n'
    ;;
    ddns-go)
      service='[Unit]\nDescription=ddns-go\n[Service]\nExecStart=/usr/bin/ddns-go "-l" ":9876" "-f" "120" "-c" "/root/ddns-go.yaml"\nStartLimitInterval=5\nStartLimitBurst=10\nRestart=always\nRestartSec=120\n[Install]\nWantedBy=multi-user.target\n'
    ;;
  esac
  if ! [[ -n "$service" ]]; then return; fi
  echo -e "${GREEN}\n[Generate service]${NC}"
  if [[ "$debug" = true ]]; then
    echo -e $service
  else
    echo -e $service > "/etc/systemd/system/$app.service";
    systemctl daemon-reload;
    systemctl enable "$app";
  fi
}
gen_config () {
  if ! [[ -n "$config" ]]; then return; fi # no config path
  # if [[ -f "$config" ]]; then
  #   if ! prompt_yn "\"$config\" already exists, do you want to overwrite it?"; then return; fi
  # else
  #   if ! prompt_yn "Do you want to create \"$config\"?"; then return; fi
  # fi
  # read -p "Specify port number: " port
  # while [[ ! ${port} =~ ^[0-9]+$ ]]; do
  #   echo "Please enter number of port:"
  #   read port
  # done
  # port=$(( ${RANDOM:0:4} + 10000 )) # random 10000-20000
  port="${port:-1234}"
  pass=$(openssl rand -base64 32 | tr -dc A-Za-z0-9 | cut -b1-16)
  # conf=('{'
  # '}')
  # conf="$(printf "%s\n" "${conf[@]}")"
  # conf="$(
  #   echo '{'
  #   echo '}'
  # )"
  case "$app" in
    snell)
      conf="[snell-server]\nlisten = 0.0.0.0:$port\nipv6 = false\npsk = $pass\nobfs = tls"
    ;;
    snell4)
      conf="[snell-server]\nlisten = 0.0.0.0:$port\nipv6 = false\npsk = $pass" #v4
    ;;
    realm)
      conf=(''
        '[log]'
        'level = "warn"'
        ''
        '[dns]'
        '# mode = "ipv6_then_ipv4" # ipv4_then_ipv6, ipv6_then_ipv4'
        ''
        '[network]'
        'no_tcp = false'
        'use_udp = true'
        ''
        '[[endpoints]]'
        'listen = "0.0.0.0:10001"'
        'remote = "test.com:80"'
        ''
        '[[endpoints]]'
        'listen = "0.0.0.0:10002"'
        'remote = "1.1.1.1:443"'
      '')

      conf="$(printf "%s\n" "${conf[@]}")"
    ;;
    gost)
      conf=('{'
        ' "Debug": true,'
        ' "Retries": 0,'
        ' "ServeNodes": ['
        '   "tcp://:10002/1.1.1.1:443"'
        ' ],'
        ' "ChainNodes": ['
        ' ],'
        ' "Routes": ['
        ' ]'
      '}')
      conf="$(printf "%s\n" "${conf[@]}")"
    ;;
    ss)
      conf=('{'
      '"mode": "tcp_and_udp",'
      '"fast_open": false,'
      '"ipv6_first": true,'
      '"servers": ['
      '{'
        ' "address": "::",'
        ' "port": '$port','
        ' "password": "'$pass'",'
        ' "method": "chacha20-ietf-poly1305",'
        ' "timeout": 300'
      '}'
      ']}')
      conf="$(printf "%s\n" "${conf[@]}")"
    ;;
  esac
  if [[ -n "$config" && -n "$conf" ]]; then
    echo -e "${GREEN}\n[Create config file]${NC} \"$config\", for example:"
    echo -e "$conf"
  fi
  if [[ -f "/root/realm.json" && "$app" == "realm" ]]; then
    printf "\n%b\n" "${YELLOW}Convert Realm1 to Realm2 config${NC}: realm convert realm.json > realm.toml";
  fi
}
finally () {
  # echo "Port:       $port"
  # echo "Password:   $pass"
  local ip=`curl -Ls ip.sb || echo 'localhost'`;
  if [[ -n "$service" ]]; then
    echo -e "${GREEN}\n[Enable and start service]${NC}"
    if [[ -n "$config" && -n "$conf" ]]; then
      echo -e "- Please make sure \"$config\" exists.\n- Run the following commands:"
    fi
  else
    echo -e "${GREEN}\n[Usage]${NC}"
  fi
  case "$app" in
    nali)
      tips="nali update;\nping g.cn | nali;\ntraceroute 189.cn | nali"
    ;;
    wtrace)
      tips="worsttrace g.cn;"
    ;;
    ddns-go)
      systemctl restart $app;
      tips="\nOpen http://$ip:9876 for configuration."
      tips="$tips\n\n [Auto-generated] \"$config\"\n"
    ;;
    nexttrace)
      tips="nexttrace -T -f"
    ;;
    *)
      tips="systemctl restart $app; systemctl status $app;"
    ;;
  esac
  if [[ -n "$tips" ]]; then
    echo -e "$tips\n"
  fi
}

# echo "name: $name; repo=$repo; prerelease=$prerelease"
init
check_root
install_deps
download
gen_service
gen_config
finally
