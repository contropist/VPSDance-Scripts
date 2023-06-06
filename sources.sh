#!/usr/bin/env bash
# bash <(curl -Lso- https://sh.vps.dance/sources.sh) debian11
# bash <(curl -Lso- https://sh.vps.dance/sources.sh) debian12

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

debian12() {
(
echo "deb http://deb.debian.org/debian bookworm main non-free-firmware"
echo "deb-src http://deb.debian.org/debian bookworm main non-free-firmware"
echo "deb http://security.debian.org/debian-security bookworm-security main non-free-firmware"
echo "deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware"
echo "deb http://deb.debian.org/debian bookworm-updates main non-free-firmware"
echo "deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware"
echo "deb http://deb.debian.org/debian bookworm-backports main non-free-firmware"
echo "deb-src http://deb.debian.org/debian bookworm-backports main non-free-firmware"
) > $sources_list
}

tips() {
  echo "Please run:"
  echo "apt update -y && apt upgrade -y && apt autoremove -y && apt autoclean -y"
  echo "cat /etc/os-release"
  # apt full-upgrade -y;
}

main() {
  if [[ "$name" == "debian11" ]]; then
    debian11
    tips
  elif [[ "$name" == "debian12" ]]; then
    debian12
    tips
  else
    echo "Error: not supported."
    exit 1
  fi
  # echo "Done."
}
main
