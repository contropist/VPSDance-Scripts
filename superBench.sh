#!/usr/bin/env bash

# https://github.com/oooldking/script

bash <(
  curl -Lso- https://raw.githubusercontent.com/oooldking/script/master/superbench_git.sh \
  | sed 's/^.*fast\.com.*$/:;/I' \
  | sed 's/^.*[ /]fast_com.*.py.*$/#/I' \
  | sed "s/27377' 'Beijing/34115' 'TianJin/Ig" \
  | sed "s/27154' 'TianJin/4870' 'Changsha/Ig" \
  | sed "s/26678' 'Guangzhou 5G/13704' 'Nanjing/Ig" \
  | sed "s/17184' 'Tianjin/26404' 'Hefei/Ig" \
  | sed "/.*26850' 'Wuxi/Id" \
  | sed "s/27249' 'Nanjing 5G/15863' 'Nanning/Ig" \
  | sed "/.*28491' 'Changsha/Id" \
  | sed '/^[ \t]*speed_fast_com$/d'
)

# https://www.speedtest.net/api/js/servers?search=China%20Telecom
# https://www.speedtest.net/api/js/servers?search=电信
# https://www.speedtest.net/api/js/servers?search=China%20Unicom
# https://www.speedtest.net/api/js/servers?search=联通
# https://www.speedtest.net/api/js/servers?search=China%20Mobile
# https://www.speedtest.net/api/js/servers?search=移动
