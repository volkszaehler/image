#!/bin/bash -e

install -m 644 files/middleware.service "${ROOTFS_DIR}/etc/systemd/system/middleware.service"

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

# composer update
if [ ! -e /home/pi/volkszaehler/composer.lock ]; then
    composer update --no-dev
fi

cp etc/config.dist.yaml etc/config.yaml
chown -R pi:pi /home/pi/volkszaehler

EOF

on_chroot << EOF
mysqld_safe --log_error=/var/log/mysql/error.log &

sleep 3

echo "create volkszaehler.org database and admin user..."
mysql <<-SQL
	CREATE DATABASE volkszaehler;
	CREATE USER 'vz_admin'@'localhost' IDENTIFIED BY 'admin_demo';
	GRANT ALL ON volkszaehler.* TO 'vz_admin'@'localhost' WITH GRANT OPTION;
SQL

echo "creating database schema..."
php /home/pi/volkszaehler/bin/doctrine orm:schema-tool:create
php /home/pi/volkszaehler/bin/doctrine orm:generate-proxies

echo "create volkszaehler.org database user..."
mysql <<-SQL
	CREATE USER 'vz'@'localhost' IDENTIFIED BY 'demo';
	GRANT USAGE ON volkszaehler.* TO 'vz'@'localhost';
	GRANT SELECT, UPDATE, INSERT ON volkszaehler.* TO 'vz'@'localhost';
	GRANT DELETE ON volkszaehler.entities_in_aggregator TO 'vz'@'localhost';
	GRANT DELETE ON volkszaehler.properties TO 'vz'@'localhost';
	GRANT DELETE ON volkszaehler.aggregate TO 'vz'@'localhost';
	SHUTDOWN;
SQL

sleep 3

EOF
