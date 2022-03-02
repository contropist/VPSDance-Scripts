#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://cdn.statically.io/gh/cloudend/scripts/main/tools.sh) [snell|realm|gost|ss|nali|wtrace|ddns-go] -p
# bash <(curl -Lso- https://cdn.jsdelivr.net/gh/cloudend/scripts@main/tools.sh)
# bash <(curl -Lso- https://raw.githack.com/cloudend/scripts/main/tools.sh)
# bash <(curl -Lso- https://gitcdn.link/cdn/cloudend/scripts/main/tools.sh)
# bash <(curl -Lso- https://raw.fastgit.org/cloudend/scripts/main/tools.sh)


OS=$(uname -s)
# DISTRO=$( [[ -e $(which lsb_release) ]] && (lsb_release -si) || echo 'unknown' ) which/lsb_release command not found
DISTRO=$( ([[ -e "/usr/bin/yum" ]] && echo 'CentOS') || ([[ -e "/usr/bin/apt" ]] && echo 'Debian') || echo 'unknown' )
name=$( tr '[:upper:]' '[:lower:]' <<<"$1" )
prerelease=$( [[ "${2}" =~ ^(-p|prerelease)$ ]] && echo true || echo false )
debug=$( [[ $OS == "Darwin" ]] && echo true || echo false )

check_root () {
  if [[ "$USER" != 'root' ]]; then
    echo 'Please run this script as root!'
    if [[ "$debug" != true ]]; then exit 1; fi
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

  case "$name" in
    snell)
      app="snell"
      repo="surge-networks/snell"
      match="linux-amd64"
      config="/root/snell.conf"
    ;;
    realm)
      app="realm"
      repo="zhboner/realm"
      match=""
      config="/root/realm.json"
    ;;
    gost)
      app="gost"
      repo="ginuerzh/gost"
      match="linux-amd64"
      config="/root/gost.json"
    ;;
    ss | shadowsocks)
      app="ss"
      repo="shadowsocks/shadowsocks-rust"
      match="x86_64.*linux-gnu"
      config="/root/ss.json"
    ;;
    nali)
      app="nali"
      repo="zu1k/nali"
      match="linux-amd64"
    ;;
    wtrace | worsttrace)
      app="wtrace"
    ;;
    ddns-go)
      app="ddns-go"
      repo="jeessy2/ddns-go"
      match="Linux_*x86_64"
      autogen="/root/ddns-go.yaml"
    ;;
    *)
      echo "Please specify app_name (snell|realm|gost|ss|nali|wtrace|ddns-go)"
      exit
    ;;
  esac
}
download () {
  suffix=$( [[ "$prerelease" = true ]] && echo "releases" || echo "releases/latest" )
  if [[ -n "$repo" ]]; then
    api="https://api.github.com/repos/$repo/$suffix"
    url=$( curl -s $api | grep "browser_download_url.*$match" | head -1 | cut -d : -f 2,3 | xargs echo ) # xargs wget
    # url=${url/"https://github.com"/"https://hub.fastgit.org"} # cdn
    url="https://ghproxy.com/$url" # cdn
  fi
  case "$app" in
    realm)
      if [[ "$debug" != true ]]; then
        rm -rf /usr/bin/realm ./realm;
      fi
    ;;
    wtrace)
      url="https://pkg.wtrace.app/linux/worsttrace"
    ;;
  esac
  echo -e "\n[Download] $url"
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
    realm)
      # curl -s https://api.github.com/repos/zhboner/realm/releases/latest | grep "browser_download_url.*" | cut -d : -f 2,3 | xargs wget -O ./realm {}; chmod +x realm
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
    ;;
    wtrace)
      mv ./worsttrace /usr/bin/worsttrace; chmod +x /usr/bin/worsttrace;
    ;;
    ddns-go)
      tar xzf ddns-go_*tar.gz; mv ./ddns-go /usr/bin/; rm -rf ddns-go_*tar.gz* LICENSE README.md;
    ;;
    *);;
  esac
}
gen_service () {
  case "$app" in
    snell)
      service='[Unit]\nDescription=Snell Service\nAfter=network.target\n[Service]\nType=simple\nLimitNOFILE=32768\nRestart=on-failure\nExecStart=/usr/bin/snell-server -c /root/snell.conf\nStandardOutput=syslog\nStandardError=syslog\nSyslogIdentifier=snell-server\n[Install]\nWantedBy=multi-user.target\n'
    ;;
    realm)
      service='[Unit]\nDescription=realm\nAfter=network-online.target\nWants=network-online.target systemd-networkd-wait-online.service\n[Service]\nType=simple\nUser=root\nRestart=on-failure\nRestartSec=5s\nExecStart=/usr/bin/realm -c /root/realm.json\n[Install]\nWantedBy=multi-user.target'
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
  echo -e "\n[Generate service]"
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
  echo -e "\n[Create config file] \"$config\", for example:"
  # conf=('{'
  # '}')
  # conf="$(printf "%s\n" "${conf[@]}")"
  # conf="$(
  #   echo '{'
  #   echo '}'
  # )"
  case "$app" in
    snell)
      conf="[snell-server]\nlisten = 0.0.0.0:$port\npsk = $pass\nobfs = tls"
    ;;
    realm)
      conf=('{'
        ' "listening_addresses": ["0.0.0.0"],'
        ' "listening_ports": ["10001-10002"],'
        ' "remote_addresses": ['
        '  "1.1.1.1",'
        '  "1.1.1.2"'
        ' ],'
        ' "remote_ports": ['
        '  "80",'
        '  "443"'
        ' ]'
      '}')
      conf="$(printf "%s\n" "${conf[@]}")"
    ;;
    gost)
      conf=('{'
        ' "Debug": true,'
        ' "Retries": 0,'
        ' "ServeNodes": ['
        '   "tcp://:24000/ipv6.itiioulet.dinghaojc.com:24000"'
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
        ' "server": "0.0.0.0",'
        ' "server_port": '$port','
        ' "method": "chacha20-ietf-poly1305",'
        ' "password": "'$pass'",'
        ' "mode": "tcp_only",'
        ' "fast_open": false,'
        ' "timeout": 300'
      '}')
      conf="$(printf "%s\n" "${conf[@]}")"
    ;;
  esac
  if [[ -n "$config" ]]; then
    echo -e "$conf"
  fi
}
finally () {
  # echo "Port:       $port"
  # echo "Password:   $pass"
  if [[ -n "$service" ]]; then
    echo -e "\n[Enable and start service]"
    if [[ -n "$config" ]]; then
      echo -e "- Please make sure \"$config\" exists.\n- Run the following commands:"
    fi
  else
    echo -e "\n[Usage]"
  fi
  case "$app" in
    nali)
      tips="nali update;\nping g.cn | nali;\ntraceroute 189.cn | nali"
    ;;
    wtrace)
      tips="worsttrace g.cn;"
    ;;
    ddns-go)
      tips="systemctl restart $app;\n\nOpen http://127.0.0.1:9876 for configuration."
    ;;
    *)
      tips="systemctl restart $app; systemctl status $app;"
    ;;
  esac
  if [[ -n "$tips" ]]; then
    echo -e "$tips\n"
  fi
  if [[ -n "$autogen" ]]; then
    echo -e "\n[Auto Generate file] \"$autogen\"\n"
  fi
}

# echo "name: $name; repo=$repo; prerelease=$prerelease"
init
check_root
download
gen_service
gen_config
finally
