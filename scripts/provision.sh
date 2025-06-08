#!/bin/sh

# use first argument or fallback to 7.4
php_version=${1:-7.4}
php=php-${php_version}

# FIXME: this installs both $php-version and 8.1 (latest release?)
apt-get update
apt-get -y install software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update
apt-get -y install \
    ssmtp \
    git \
    curl \
    bc \
    "$php" \
    "$php"-fpm \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    "$php"-tidy \
    php-memcache \
    php-apcu \
    php-pear \
    php-imap \
    php-intl \
    php-ssh2 \
    php-zip \
    php-xml \
    php-xmlrpc

# Set default PHP version just in case
update-alternatives --set php "/usr/bin/php${php_version}"
update-alternatives --set phar "/usr/bin/phar${php_version}"
update-alternatives --set phar.phar "/usr/bin/phar.phar${php_version}"
#update-alternatives --set phpize "/usr/bin/phpize${php_version}"
#update-alternatives --set php-config "/usr/bin/php-config${php_version}"

# Install sh2ju, a JUnit compliant test framework for Bash
# See http://manolocarrasco.blogspot.fi/2010/02/hudson-publish-bach.html
git -C /usr/src clone https://github.com/manolo/shell2junit.git

mkdir -p /run/php
chown www-data:www-data /run/php

#hack specific for phz.fi web site compability # TODO useless?
mkdir -p /home/shellp/phz/bedrock-wp/
ln -sf /var/www/html/web/web /home/shellp/phz/bedrock-wp/

#Install composer
#Install composer outside WORKDIR since it's not then under shared folder
#and will be packaged to the image instead out of it
echo "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
