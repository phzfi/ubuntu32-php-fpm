FROM phzfi/ubuntu32:bionic-latest

WORKDIR /var/www/html/web
ADD ./scripts/provision.sh ./provision.sh
ADD ./etc /etc/
ADD ./tests/* /opt/

RUN ./provision.sh

CMD ["/usr/sbin/php-fpm8.0", "--fpm-config", "/etc/php/8.0/fpm/php-fpm.conf"]
