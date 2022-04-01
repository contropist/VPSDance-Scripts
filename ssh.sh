#!/usr/bin/env bash

# Set up SSH public key authentication
# bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/ssh.sh)

# mkdir -m 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys >> ~/.ssh/authorized_keys


for home in /root /home/*; # do { if [[ ! -e "$home" ]]; then continue; fi; echo $home; }; done
do
  if [[ ! -e "$home" ]]; then continue; fi;
  mkdir -p "${home}/.ssh"; chmod 700 "${home}/.ssh";
  if [[ ! -f "${home}/.ssh/authorized_keys" ]]; then echo '' >> ~/.ssh/authorized_keys; fi
  chmod 600 "${home}/.ssh/authorized_keys"
done

main () {
  echo "Paste your SSH public key (~/.ssh/id_rsa.pub):"
  IFS= read -d '' -n 1 text
  while IFS= read -d '' -n 1 -t 2 c
  do
    text+=$c
  done
  text=$(echo "$text" | sed '/^$/d')
  # echo "public key=$text"
  # echo "$text" >> "${HOME}/.ssh/authorized_keys"

  # for line in $text; do echo "$line"; sed -i "/$line/d" test; done
  # echo "$text" >> test

  for home in /root /home/*;
  do
    if [[ ! -e "$home" ]]; then continue; fi;
    # echo $home;
    echo "$text" >> "${home}/.ssh/authorized_keys"
    # remove-duplicates
    # sed -nr 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}'
    # awk '!seen[$0]++'
    sed -i "/^$/d" "${home}/.ssh/authorized_keys"
    sed -i -nr 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}' "${home}/.ssh/authorized_keys"
  done
}
main
