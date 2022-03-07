#!/usr/bin/env bash

# https://github.com/oooldking/script

bash <(
  curl -Lso- https://raw.githubusercontent.com/oooldking/script/master/superbench_git.sh \
  | sed 's/^.*fast\.com.*$/:;/I' \
  | sed 's/^.*[ /]fast_com.*.py.*$/#/I' \
  | sed '/^[ \t]*speed_fast_com$/d'
)
