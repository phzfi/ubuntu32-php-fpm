FROM phzfi/ubuntu32:bionic-20200806

ADD ./scripts/provision.sh ./provision.sh

RUN ./provision.sh

#Run all commands with user www-data
USER www-data:www-data
CMD ["/usr/sbin/php-fpm7.2", "--fpm-config", "/etc/php/7.2/fpm/php-fpm.conf"]
