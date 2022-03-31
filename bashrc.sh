#!/usr/bin/env bash

# Usage:
# bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/bashrc.sh)


# allusers=$( cat /etc/passwd | grep -vE "(/bin/false|/sbin/nologin|/bin/sync|guest-)" | cut -d: -f1 )
# allusers=$(awk -F':' '$2 ~ "\\$" {print $1}' /etc/shadow)
for file in /root/.bashrc /home/*/.bashrc; do
  # echo $file;
  if [[ ! -f "$file" ]]; then continue; fi;
  # delete lines between two patterns
  sed -i '/^# => vps.dance/,/^# <= vps.dance/d' $file;
  # insert lines
  printf "%s\n" "# => vps.dance" >> $file;
  printf "%s\n" "$(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/files/bashrc)" >> $file;
  printf "%s\n" "# <= vps.dance" >>$file;
done
# source ~/.bashrc
# fix: source bashrc not working
exec bash
