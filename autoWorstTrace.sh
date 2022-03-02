#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://cdn.statically.io/gh/cloudend/scripts/main/autoWorstTrace.sh)
# bash <(curl -Lso- https://cdn.jsdelivr.net/gh/cloudend/scripts@main/autoWorstTrace.sh)

# install worsttrace
if [ ! -f "/usr/bin/worsttrace" ]; then
  bash <(curl -Lso- https://cdn.jsdelivr.net/gh/cloudend/scripts@main/tools.sh) wtrace -p
fi

## start to use besttrace

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
	worsttrace ${ip_list[$i]} | sed ':a;N;s/.*WorstTrace.*\n//g;ta' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed '/^$/d'
	next
done
# worsttrace 202.112.14.151 | sed ':a;N;s/.*WorstTrace.*\n//g;ta' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed '/^$/d'
