#!/bin/bash

# 启动: nohup bash ./checkNf.sh > /dev/null 2>&1 &
# 停止: ps aux | grep checkNf.sh | grep -v grep | awk '{print $2}' | xargs kill -9

interval=2 # 检测间隔(分钟)
IPv="4" # IPv4 或 IPv6
UA_Browser="Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/116.0"
check_nf() { curl -${IPv}fsL -A "${UA_Browser}" -w %{http_code} -o /dev/null -m 10 "https://www.netflix.com/title/70143836" 2>&1; }
# echo $(check_nf) # 200: unblock, 404: block

log="/root/ip.txt"
while true; do
  code=$(check_nf);
  # echo $code;
  if [ "$code" = "404" ]; then
    date +"%Y-%m-%d %H:%M:%S" >>$log
    # 调用API自动更换IP
    # curl http://xxx.com/change_ip >>$log
  fi
  sleep $((60 * $interval)) # xx秒
done
