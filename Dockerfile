FROM phzfi/ubuntu32:bionic-20200806
RUN apt-get -y install \
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
php-xml \
php-xmlrpc
