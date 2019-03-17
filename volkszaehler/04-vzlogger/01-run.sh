#!/bin/bash -e

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
