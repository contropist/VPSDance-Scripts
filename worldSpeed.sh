#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://cdn.statically.io/gh/cloudend/scripts/main/worldSpeed.sh)  [-4, -6]
# bash <(curl -Lso- https://cdn.jsdelivr.net/gh/cloudend/scripts@main/worldSpeed.sh)
# bash <(curl -Lso- https://raw.githack.com/cloudend/scripts/main/worldSpeed.sh)
# bash <(curl -Lso- https://gitcdn.link/cdn/cloudend/scripts/main/worldSpeed.sh)
# bash <(curl -Lso- https://raw.fastgit.org/cloudend/scripts/main/worldSpeed.sh)

# References:
# https://github.com/flyzy2005/scripts
# https://github.com/manvari/server-speedtest
# https://cnman.github.io/speedtest.html

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PLAIN='\033[0m'
BOLD="\033[1m"

ipv6=$( [[ "${1}" =~ ^(-6)$ ]] && echo true || echo false )
stack=$( [[ "$ipv6" = true ]] && echo "-6" || echo "-4" )
if [ "`ping -6 2>&1 | grep 'invalid option'`" ]; then
  PING=$( [[ "$ipv6" = true ]] && ([[ -x "`which ping6`" ]] && echo "ping6") || echo "ping" )
else
  PING=$( [[ "$ipv6" = true ]] && echo "ping -6" || echo "ping -4" )
fi

speed_test () {
  local stacks=$3
  if [[ $stacks != *"${stack:1}"* ]]; then
    # echo '- skip -'
    return
  fi
  local speedtest=$(curl $stack -m 12 -Lo /dev/null -skw "%{speed_download}\n" "$1" )
  local host=$((awk '{gsub(/^.*@/,"", $0); print $0}' | awk -F':' '{print $1}')  <<< `awk -F'/' '{print $3}' <<< $1`)
  local ipaddress=$($PING -c1 -n ${host} | awk -F'[()]' '{print $2;exit}')
  local nodeName=$2
  # printf "%-32s%-24s%-14s\n" "${nodeName}" "${ipaddress}" "$(FormatBytes $speedtest)"
  printf "${YELLOW}%-32s${GREEN}%-24s${RED}%-14s${PLAIN}\n" "${nodeName}" "${ipaddress}" "$(FormatBytes $speedtest)"
}
region () {
  printf "${CYAN}${BOLD}%-35s${PLAIN}\n" "----- $1 -----"
}
next () {
  printf "%-70s\n" "-" | sed 's/\s/-/g'
}
promptYn () {
  while true; do
    read -p "$1 (y/n)" yn
    case "${yn:-Y}" in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes(y) or no(n).";;
    esac
  done
}
pastebin () {
  text="$( sed "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" <<< "${1}" )"
  # echo "$text"
  curl -w "URL: %{redirect_url}\n" -o /dev/null -s "https://paste.ubuntu.com" --data-urlencode "content=$text" -d "poster=speed_test" -d "syntax=bash"
}
FormatBytes () {
  bytes=${1%.*}
  local Mbps=$( printf "%s" "$bytes" | awk '{ printf "%.2f", $0 / 1024 / 1024 * 8 } END { if (NR == 0) { print "error" } }' )
  if [[ $bytes -lt 1000 ]]; then
    printf "%8i B/s |      N/A     "  $bytes
  elif [[ $bytes -lt 1000000 ]]; then
    local KiBs=$( printf "%s" "$bytes" | awk '{ printf "%.2f", $0 / 1024 } END { if (NR == 0) { print "error" } }' )
    printf "%7s KiB/s | %7s Mbps" "$KiBs" "$Mbps"
  else
    # awk way for accuracy
    local MiBs=$( printf "%s" "$bytes" | awk '{ printf "%.2f", $0 / 1024 / 1024 } END { if (NR == 0) { print "error" } }' )
    printf "%7s MiB/s | %7s Mbps" "$MiBs" "$Mbps"
    # bash way
    # printf "%4s MiB/s | %4s Mbps""$(( bytes / 1024 / 1024 ))" "$(( bytes / 1024 / 1024 * 8 ))"
  fi
}
# wget -O /dev/null http://www2.unicomtest.com:8080/download?size=100000000
test () {
  printf "%-32s%-31s%-14s\n" "Node Name" "IP address" "Download Speed"

  region "Global (CDN)"
  speed_test 'http://cachefly.cachefly.net/100mb.test' 'CacheFly, CDN' '4'
  speed_test 'https://speed.cloudflare.com/__down?bytes=100001000' 'Cloudflare, CDN' '4,6'

  region "Asia"
  speed_test 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN' '4,6'
  speed_test 'http://mirror.hk.leaseweb.net/speedtest/100mb.bin' 'Leaseweb, HongKong, CN' '4,6'
  # speed_test 'https://hk.edis.at/100MB.test' 'EDIS, HongKong, CN' '4,6'
  # speed_test 'http://hkg-speedtest.lg.bluevps.com/100MB.bin' 'BlueVPS, HongKong, CN' '4'
  # speed_test 'http://hk4.lg.starrydns.com/100MB.test' 'StarryDNS, HongKong, CN' '4'
  # speed_test 'http://tpdb.speed2.hinet.net/test_100m.zip' 'Hinet, Taiwan' '4,6' # http (QoS)
  speed_test 'ftp://ftp:ftp@ftp.speed.hinet.net/test_100m.zip' 'Hinet, Taiwan' '4,6' # ftp
  speed_test 'http://ftp1.apol.com.tw/test_100m.dat' 'APOL, Taiwan' '4'
  speed_test 'http://speedtest.tokyo2.linode.com/100MB-tokyo2.bin' 'Linode, Tokyo, JP' '4,6'
  speed_test 'http://speedtest.tok02.softlayer.com/downloads/test100.zip' 'Softlayer, Tokyo, JP' '4,6'
  speed_test 'http://speedtest.sng01.softlayer.com/downloads/test100.zip' 'Softlayer, Seoul, KR' '4,6'
  speed_test 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG' '4,6'
  speed_test 'http://speedtest.sng01.softlayer.com/downloads/test100.zip' 'Softlayer, Singapore, SG' '4,6'
  # speed_test 'http://mirror.sg.leaseweb.net/speedtest/100mb.bin' 'Leaseweb, Singapore, SG' '4,6'

  # Northern America
  region "Western US"
  # speed_test 'http://speedtest.sjc01.softlayer.com/downloads/test100.zip' 'Softlayer, San Jose, US' '4,6'
  speed_test 'http://speedtest.fremont.linode.com/100MB-fremont.bin' 'Linode, Fremont, US' '4,6'
  speed_test 'http://mirror.sfo12.us.leaseweb.net/speedtest/100mb.bin' 'Leaseweb, San Francisco, US' '4,6'
  region "Central US"
  speed_test 'http://speedtest.dal13.softlayer.com/downloads/test100.zip' 'Softlayer, Dallas, US' '4,6'
  speed_test 'https://il-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr, Chicago, US' '4'
  # speed_test 'http://lg.den2-c.fdcservers.net/100MBtest.zip' 'FDC, Denver, US' '4'
  region "Eastern US"
  # speed_test 'http://speedtest.newark.linode.com/100MB-newark.bin' 'Linode, Newark, NJ, US' '4,6'
  speed_test 'http://speedtest-nyc1.digitalocean.com/100mb.test' 'Digital Ocean, New York, US' '4,6'
  speed_test 'http://mirror.wdc1.us.leaseweb.net/speedtest/100mb.bin' 'Softlayer, Washington, US' '4,6'
  region "Canada"
  speed_test 'http://speedtest-tor1.digitalocean.com/100mb.test' 'DO, Toronto, CA' '4,6'
  speed_test 'http://speedtest.mon01.softlayer.com/downloads/test100.zip' 'Softlayer, Montreal, CA' '4,6'

  # Europe
  region "Western & Southern Europe"
  speed_test 'http://speedtest.london.linode.com/100MB-london.bin' 'Linode, London, UK' '4,6'
  speed_test 'http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin' 'Linode, Frankfurt, DE' '4,6'
  speed_test 'http://speedtest.fra02.softlayer.com/downloads/test100.zip' 'Softlayer, Frankfurt, DE' '4,6'
  speed_test 'http://speedtest.par01.softlayer.com/downloads/test100.zip' 'Softlayer, Paris, FR' '4,6'
  speed_test 'http://mirror.nl.leaseweb.net/speedtest/100mb.bin' 'Leaseweb, Amsterdam, NL' '4,6'
  region "Central & Eastern Europe"
  speed_test 'http://ru.edis.at/100MB.test' 'EDIS, Moscow, RU' '4,6'
  speed_test 'http://pl.edis.at/100MB.test' 'EDIS, Warsaw, PL' '4,6'
  speed_test 'http://ro.edis.at/100MB.test' 'EDIS, Bucharest, RO' '4,6'
  # speed_test 'http://hosthink.org/100mb.test' 'Hosthink, Istanbul, TR' '4'
  speed_test 'http://lg.ist.binaryracks.com/100MB.test' 'Binaryracks, Istanbul, TR' '4'
  # speed_test 'https://bg.edis.at/100MB.test' 'EDIS, Sofia, BG' '4,6'
  next
}
# test

tmp=$(mktemp)
test | tee $tmp
results="$(cat $tmp)"
rm -rf $tmp;

if promptYn "Upload your results to to a \"PasteBin\" site?"; then
  pastebin "$results"
fi
