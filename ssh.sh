#!/usr/bin/env bash

# Set up SSH public key authentication
# bash <(curl -Lso- https://raw.githubusercontent.com/VPSDance/scripts/main/ssh.sh)

# mkdir -m 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys >> ~/.ssh/authorized_keys

mkdir -p "${HOME}/.ssh"; chmod 700 "${HOME}/.ssh";
if [[ ! -f "${HOME}/.ssh/authorized_keys" ]]; then echo '' >> ~/.ssh/authorized_keys; fi
chmod 600 "${HOME}/.ssh/authorized_keys"

main () {
  echo "Paste your SSH public key (~/.ssh/id_rsa.pub):"
  IFS= read -d '' -n 1 text
  while IFS= read -d '' -n 1 -t 2 c
  do
    text+=$c
  done
  echo "public key=$text"
}
main
