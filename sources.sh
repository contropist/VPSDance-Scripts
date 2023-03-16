#!/usr/bin/env bash
# bash <(curl -Lso- https://sh.vps.dance/sources.sh) debian11

sources_list="/etc/apt/sources.list"
name=$( tr '[:upper:]' '[:lower:]' <<<"$1" )

debian11() {
(
echo "deb http://deb.debian.org/debian bullseye main"
echo "deb-src http://deb.debian.org/debian bullseye main"
echo "deb http://security.debian.org/debian-security bullseye-security main"
echo "deb-src http://security.debian.org/debian-security bullseye-security main"
echo "deb http://deb.debian.org/debian bullseye-updates main"
echo "deb-src http://deb.debian.org/debian bullseye-updates main"
echo "deb http://deb.debian.org/debian bullseye-backports main"
echo "deb-src http://deb.debian.org/debian bullseye-backports main"
) > $sources_list
}

main() {
  if [[ "$name" == "debian11" ]]; then
    debian11
  else
    echo "Error: not supported."
    exit 1
  fi
  echo "Done."
}
main
