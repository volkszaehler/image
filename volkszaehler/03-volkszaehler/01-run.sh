#!/bin/bash -e

install -m 644 files/10-buster.list		"${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/10-buster		"${ROOTFS_DIR}/etc/apt/preferences.d/"
install -m 644 files/middleware.service "${ROOTFS_DIR}/etc/systemd/system/middleware.service"

on_chroot << EOF
apt update
apt install -y -t buster php-fpm php-gd php-intl php-mbstring php-mysql php-imap php7.3-opcache php-sqlite3 php-xml php-xmlrpc php-zip php-cli php-apcu
EOF

on_chroot << EOF
if [ ! -e /usr/local/bin/composer ]; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    # php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer
fi
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

# composer update
if [ ! -e /home/pi/volkszaehler/composer.lock ]; then
    composer update
fi
EOF
