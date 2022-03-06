#!/usr/bin/env bash

# bash <(curl -L -s check.unlock.media)
# https://github.com/lmc999/RegionRestrictionCheck

bash <(
  curl -L -s check.unlock.media \
  | sed '/^[ \t]*echo\( -e\)\? "[-]*"\(.*\)\?$/d' \
  | sed '/^[ \t]*echo\( -e\)\? "[=]*"\(.*\)\?$/d' \
  | sed 's/ CheckV6().*$/&\n printf "%-39s\\n" \| sed "s\/\\s\/-\/g"/' \
  | sed 's/ Goodbye().*$/&\n printf "%-39s\\n" \| sed "s\/\\s\/-\/g"/' \
  | sed '/echo\( -e\)\? ""\(.*\)\?$/d'
)

