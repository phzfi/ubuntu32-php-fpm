#!/bin/bash

apt-get -y install \
    php7.4 \
    php7.4-fpm \
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
    php-xmlrpc

#Install composer
#Install composer outside WORKDIR since it's not then under shared folder
#and will be packaged to the image instead out of it
echo "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
