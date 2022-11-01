#!/usr/bin/env bash

# # bash <(curl -Lso- https://sh.vps.dance/autoBestTrace.sh)
# https://github.com/nyjx/autoBestTrace
# https://github.com/flyzy2005/shell

# besttrace -q1 -T -g cn # 探测数据包数1, TCP, CN

# clean faild file
if [ -f "besttrace2021" ]; then
  if [[ ! $(./besttrace2021 -V) ]]; then
    rm -rf besttrace2021;
  fi
fi

# url="https://raw.githubusercontent.com/nyjx/autoBestTrace/main/autoBestTrace.sh"
# url="https://ghproxy.com/$url" # cdn
# bash <(
#   curl -Lso- $url \
#   | sed "s/https:\/\/github.com/https:\/\/ghproxy.com\/https:\/\/github.com/Ig" \
#   | sed 's/ -q 1 / -q1 -g cn -T /g'
# )


OSARCH=$(uname -m)
case $OSARCH in 
  x86_64)
    BINTAG=""
    ;;
  i*86)
    BINTAG="32"
    ;;
  arm64|aarch64)
    BINTAG="arm"
    ;;
  *)
    echo "unsupported OSARCH: $OSARCH"
    exit 1
    ;;
esac

# install besttrace
if [ ! -f "besttrace2021" ]; then
  wget -O besttrace2021 "https://github.com/nyjx/autoBestTrace/raw/main/besttrace4linux/besttrace${BINTAG}"
  chmod +x besttrace2021
fi

## start to use besttrace

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

clear
next

# 广东电信 gd.189.cn
# 广东联通 221.5.88.88
# 广东移动 211.139.145.129 gd.10086.cn
ip_list=(14.215.116.1 202.96.209.133 117.28.254.129 113.207.25.138 119.6.6.6 120.204.197.126 183.221.253.100 211.139.145.129 202.112.14.151)
ip_addr=(广州电信 上海电信 厦门电信 重庆联通 成都联通 上海移动 成都移动 广东移动 成都教育网)

# ip_len=${#ip_list[@]}

for i in {0..8}; do
    echo ${ip_addr[$i]}
    ./besttrace2021 -q1 -g cn -T ${ip_list[$i]}
    next
done
