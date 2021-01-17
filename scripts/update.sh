#!/bin/bash -eux

# Disable the release upgrader
echo "==> Disabling the release upgrader"
sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

echo "==> Checking version of Ubuntu"
. /etc/lsb-release

if [[ $DISTRIB_RELEASE == 18.04 ]]; then
  systemctl disable apt-daily.service # disable run when system boot
  systemctl disable apt-daily.timer   # disable timer run
fi 

if [[ $DISTRIB_RELEASE == 20.04 ]]; then
  systemctl disable apt-daily-upgrade.service
  systemctl disable apt-daily-upgrade.timer
fi

echo "==> Updating list of repositories"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" update

echo "==> Upgrading all packages"
export DEBIAN_FRONTEND=noninteractive
apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
