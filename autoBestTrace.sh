#!/usr/bin/env bash

# https://github.com/nyjx/autoBestTrace
# https://github.com/flyzy2005/shell

# besttrace -q1 -T -g cn # 探测数据包数1, TCP, CN
bash <(
  curl -Lso- https://raw.githubusercontent.com/nyjx/autoBestTrace/main/autoBestTrace.sh \
  | sed 's/ -q 1 / -q1 -g cn -T /g'
)
