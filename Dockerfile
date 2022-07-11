FROM php:7.3-apache

# system dependencies
# TODO: audit these to be sure we need all of them + they need to be installed individually
RUN apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install \
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

# Setup PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd intl zip exif \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && a2enmod rewrite

# Copy over the application code (core/), custom settings, and scripts
# TODO: I'm not entirely sure the APACHE_RUN_USER/GROUP variables exist on the container?
COPY --chown=${APACHE_RUN_USER:-www-data}:${APACHE_RUN_GROUP:-www-data} core/ /var/www/html
COPY --chown=${APACHE_RUN_USER:-www-data}:${APACHE_RUN_GROUP:-www-data} ./config/local_settings_custom.php /var/www/html/system/application/config
COPY --chown=1 scripts/ /scripts

WORKDIR /var/www/html
VOLUME /var/www/html/uploads

# Putting ENV values down here so we can still use the cache after changing the defaults.
# For now, we'll keep the build arguments in the interest of backwards compatability.
ARG PHP_MAX_UPLOAD_SIZE="100M"
ARG PHP_MEMORY_LIMIT="256M"
ENV PHP_MAX_UPLOAD_SIZE=$PHP_MAX_UPLOAD_SIZE
ENV PHP_MEMORY_LIMIT=$PHP_MEMORY_LIMIT

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
