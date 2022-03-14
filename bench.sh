#!/usr/bin/env bash

# https://github.com/teddysun/across/blob/master/bench.sh

bash <(
  curl -Lso- https://raw.githubusercontent.com/teddysun/across/master/bench.sh \
  | sed "/Los Angeles/Ii speed_test '34115' 'TianJin, CT CN'" \
  | sed "/Los Angeles/Ii speed_test '27594' 'Guangzhou, CT CN'" \
  | sed "/Los Angeles/Ii speed_test '4870' 'Changsha, CU CN'" \
  | sed "/Los Angeles/Ii speed_test '13704' 'Nanjing, CU CN'" \
  | sed "/Los Angeles/Ii speed_test '26404' 'Hefei, CM CN'" \
  | sed "/Los Angeles/Ii speed_test '15863' 'Nanning, CM CN'" \
  | sed "/.*, CN/Id"
)

# https://www.speedtest.net/api/js/servers?search=China%20Telecom
# https://www.speedtest.net/api/js/servers?search=电信
# https://www.speedtest.net/api/js/servers?search=China%20Unicom
# https://www.speedtest.net/api/js/servers?search=联通
# https://www.speedtest.net/api/js/servers?search=China%20Mobile
# https://www.speedtest.net/api/js/servers?search=移动
