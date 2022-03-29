#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://cdn.statically.io/gh/cloudend/scripts/main/autoNaliTrace.sh)
# bash <(curl -Lso- https://cdn.jsdelivr.net/gh/cloudend/scripts@main/autoNaliTrace.sh)

# install nali
if [ ! -f "/usr/bin/nali" ]; then
  bash <(curl -Lso- https://cdn.jsdelivr.net/gh/VPSDance/scripts@main/tools.sh) nali -p
fi

## start to use nali
nali update;

next() {
  printf "%-70s\n" "-" | sed 's/\s/-/g'
}

clear
next

ip_list=(14.215.116.1 202.96.209.133 117.28.254.129 113.207.25.138 119.6.6.6 120.204.197.126 183.221.253.100 202.112.14.151)
ip_addr=(广州电信 上海电信 厦门电信 重庆联通 成都联通 上海移动 成都移动 成都教育网)
# ip_len=${#ip_list[@]}

for i in {0..7}
do
	echo ${ip_addr[$i]}
	traceroute -AT4 -m30 -q1 ${ip_list[$i]} 30 | nali \
  | sed 's/ 对方和您在同一内部网//g; s/\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\ *\[.*\]\) *([0-9\.]\+ [^)]\+)/\1/g; s/ \[\(as.*\/as.*\)\]/ [*]/Ig'
	next
done
# echo '2  172.30.83.68 [局域网 对方和您在同一内部网]  (172.30.83.68 [局域网 对方和您在同一内部网] ) [*]  2.847 ms' | sed 's/ 对方和您在同一内部网//g'
# echo '2  172.30.83.68 [局域网]  (172.30.83.68 [局域网] ) [*]  1.956 ms' | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\ *\[.*\]\) *([0-9\.]\+ [^)]\+)/#\1#/g'
# echo '2  172.30.83.68 [局域网]  (172.30.83.68 [局域网] ) [*]  1.956 ms' | sed 's/ *([0-9\.]\+ [^)]\+)/#\0#/g'
# echo '8  104.254.115.46 [北美地区] [AS199524/AS133731/as21859/AS134671/AS40676/AS21859]  1.972 ms' | sed 's/ \[\(as.*\/as.*\)\]/ [*]/Ig'

