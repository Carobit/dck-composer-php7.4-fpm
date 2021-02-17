FROM php:7.4-fpm-alpine
ARG COMPOSER_VER=2.0.8

RUN apk add imap-dev yarn openldap-dev krb5-dev zlib-dev wget git fcgi libpng-dev libmemcached-dev sudo libzip-dev \
    icu-dev rabbitmq-c-dev libxml2-dev curl-dev imagemagick imagemagick-libs imagemagick-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure intl \
    && docker-php-ext-install calendar pdo_mysql pdo imap zip ldap mysqli bcmath opcache gd sockets intl \
    && apk add autoconf \
        g++ \
        make \
    && pecl install apcu && docker-php-ext-enable apcu \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install solr && docker-php-ext-enable solr \
    && pecl install imagick && docker-php-ext-enable imagick \
    && pecl install mongodb && docker-php-ext-enable mongodb \
    && apk add ca-certificates \
#cleanup
    && apk del autoconf g++ wget make \
    && rm -rf /tmp/* /var/cache/apk/* \
# composer
    && cd /usr/bin/ && wget -O composer https://getcomposer.org/download/${COMPOSER_VER}/composer.phar && chmod +x /usr/bin/composer \
# fix log path
    && sed -i "s/error_log.*/error_log = \/var\/log\/php7\.4\-fpm\.error.log/g" /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i "s/access.log.*/access.log = \/var\/log\/php7\.4\-fpm\.access.log/g" /usr/local/etc/php-fpm.d/docker.conf \
    && ln -sf /dev/null /var/log/php7.4-fpm.access.log \
    && ln -sf /proc/1/fd/2 /var/log/php7.4-fpm.error.log

# iconv fix
RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# change to www-data user
#RUN rm -rf /var/www/* && chown www-data.www-data -R /var/www

USER www-data
ENV PATH="${PATH}:/home/www-data/.composer/vendor/bin"

USER root

WORKDIR /app