ARG PHP_VERSION="7.2"
FROM php:${PHP_VERSION}-apache

ARG CUSTOM_SETTINGS_FILE="./config/local_settings_custom.php"
ARG PHP_MAX_UPLOAD_SIZE="100M"
ARG PHP_MEMORY_LIMIT="256M"

# enable rewrites early
RUN a2enmod rewrite

# system dependencies
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq -y --no-install-recommends install \
    git \
    # from dodeeric/omeka-s-docker
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libzip-dev \
    libmagickwand-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd intl zip exif
RUN pecl install mcrypt-1.0.2 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick

# Add the ability to override the PHP's upload limits via build argument
RUN echo "upload_max_filesize = ${PHP_MAX_UPLOAD_SIZE} \
post_max_size = ${PHP_MAX_UPLOAD_SIZE} \
memory_limit = ${PHP_MEMORY_LIMIT}" >> /usr/local/etc/php/conf.d/uploads.ini

COPY --chown=1 scripts/ /scripts
COPY core/ /var/www/html
RUN /scripts/install-scalar.sh

# need to copy custom config _after_ installing scalar
COPY --chown=${APACHE_RUN_USER:-www-data}:${APACHE_RUN_GROUP:-www-data} ${CUSTOM_SETTINGS_FILE} /var/www/html/system/application/config/local_settings_custom.php

VOLUME /var/www/html/uploads

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
