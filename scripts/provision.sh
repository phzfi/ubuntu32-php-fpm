#!/bin/bash
apt-get update
apt-get -y install \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-tidy \
    php-memcache \
    php-apcu \
    php-pear \
    php-imap \
    php-intl \
    php-ssh2 \
    php-zip \
    php-xml \
    php-xmlrpc \
    nano \
    less \
    curl

mkdir -p /run/php
chown www-data:www-data /run/php

#hack specific for phz.fi web site compability
mkdir -p /home/shellp/phz/bedrock-wp/
ln -sf /var/www/html/web /home/shellp/phz/bedrock-wp

#Install composer
#Install composer outside WORKDIR since it's not then under shared folder
#and will be packaged to the image instead out of it
echo "Install composer"
if [ ! -x /usr/local/bin/composer ]; then
    cd /usr/local/bin
    curl -sS https://getcomposer.org/installer | php
    ln -sf composer.phar composer
fi
