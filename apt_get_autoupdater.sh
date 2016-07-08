#!/bin/bash
# +-----------------------------------------------+
# | apt-get updater script for crontab            |
# +-----------------------------------------------+
# | Author: Matjaž <dev@matjaz.it> matjaz.it      |
# | v0.7 2015-05-06                               |
# +-----------------------------------------------+
# | DESCRIPTION AND USAGE                         |
# +-----------------------------------------------+
# This script is a collection of apt-get commands to be performed
# periodically by the root crontab to maintain a simple Debian/Ubuntu
# OS updated. It automatically installs everything, so use at your own
# risk and adapt it to your needs.
#
# Rembember to make this script executable by running:
#   sudo chmod +x /path/to/file/apt-get-autoupdater.sh
# put its execution in the root crontab with:
#   sudo crontab -e
# and adding the following line (or modify it)
#   30 4 * * 3 bash /path/to/file/apt-get-autoupdater.sh \
#              >> /var/log/apt/apt-get-autoupdater.log
#
# +-----------------------------------------------+
# | SOFTWARE LICENCE                              |
# +-----------------------------------------------+
# This Source Code Form is subject to the terms of the BSD 3-Clause License.


echo "\n############################"
echo "Starting apt-get-autoupdater"
date
echo
apt-get update
apt-get --fix-broken install
apt-get --yes upgrade
apt-get autoremove
apt-get clean
apt-get autoclean
exit 0
