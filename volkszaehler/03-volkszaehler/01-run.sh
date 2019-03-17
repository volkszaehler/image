#!/bin/bash -e

install -m 644 files/10-buster.list		"${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/10-buster		"${ROOTFS_DIR}/etc/apt/preferences.d/"
install -m 644 files/middleware.service "${ROOTFS_DIR}/etc/systemd/system/middleware.service"

on_chroot << EOF
apt update
apt install -y -t buster php-fpm php-gd php-intl php-mbstring php-mysql php-imap php7.3-opcache php-sqlite3 php-xml php-xmlrpc php-zip php-cli php-apcu
EOF

on_chroot << EOF
if [ -d /home/pi/volkszaehler ]; then
    cd /home/pi/volkszaehler
    git checkout master
    git pull
else
    git clone https://github.com/volkszaehler/volkszaehler.org /home/pi/volkszaehler
    cd /home/pi/volkszaehler
fi

# version 1.0
git reset --hard 4a0bbedf9d097c038f602df36a83f8df7ee5e9ec

if [ ! -e /home/pi/volkszaehler/composer.lock ]; then
    composer update
fi
EOF
