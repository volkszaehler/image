#!/bin/bash -e

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

if [ !-e /home/pi/volkszaehler/composer.lock ]; then
    composer update
fi
EOF
