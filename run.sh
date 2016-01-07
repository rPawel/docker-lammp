#!/bin/bash
PERSISTENT_CONFIG_FOLDER="/root/.persistent-config"
PERSISTENT_IGNORED_CONFIG_FOLDER=$PERSISTENT_CONFIG_FOLDER/.ignore
VOLATILE_CONFIG_FOLDER="/"

rm -rf /home; ln -s /var/www/app /home

mkdir -p /var/log/php5 /var/log/apache2 /var/www/app/public
chmod 775 /var/log/php5 /var/log/apache2
find /var/log/php5 /var/log/apache2 -type f -exec chmod 644 {} \;
chown -R user:www-data /var/log/php5 /var/log/apache2 /var/www/app

cp -ar ${PERSISTENT_CONFIG_FOLDER}/* ${VOLATILE_CONFIG_FOLDER}

# start container
exec /usr/bin/supervisord -c /etc/supervisord.conf
