#!/bin/bash -e

install -m 644 files/vzlogger.service "${ROOTFS_DIR}/etc/systemd/system/vzlogger.service"
install -m 644 files/vzlogger "${ROOTFS_DIR}/etc/logrotate.d/vzlogger"

on_chroot << EOF
if [ -d /home/pi/vzlogger ]; then
    cd /home/pi/vzlogger
    git pull
else
    git clone https://github.com/volkszaehler/vzlogger /home/pi/vzlogger
    cd /home/pi/vzlogger
fi

if [ ! -e /usr/local/bin/vzlogger ]; then
    ./install.sh
fi
EOF
