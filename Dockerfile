FROM php:7.2-apache
LABEL maintainer="malantoa@lafayette.edu"

ARG VERSION="latest"

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
    libmagickwand-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd intl zip exif
RUN pecl install mcrypt-1.0.2 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick

COPY --chown=1 scripts/ /scripts

RUN /scripts/install-scalar.sh

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
