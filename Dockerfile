FROM phzfi/ubuntu32:bionic-20200806

WORKDIR /var/www/html/web
ADD ./scripts/provision.sh ./provision.sh
ADD ./etc /etc/

RUN ./provision.sh

CMD ["/usr/sbin/php-fpm7.2", "--fpm-config", "/etc/php/7.2/fpm/php-fpm.conf"]
