#!/usr/bin/env bash

# https://github.com/nyjx/autoBestTrace
# https://github.com/flyzy2005/shell

# besttrace -q1 -T -g cn # 探测数据包数1, TCP, CN
url="https://raw.githubusercontent.com/nyjx/autoBestTrace/main/autoBestTrace.sh"
url="https://ghproxy.com/$url" # cdn
bash <(
  curl -Lso- $url \
  | sed "s/https:\/\/github.com/https:\/\/ghproxy.com\/https:\/\/github.com/Ig" \
  | sed 's/ -q 1 / -q1 -g cn -T /g'
)
