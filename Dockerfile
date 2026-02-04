FROM php:8.4-fpm-alpine

# System deps + build deps
RUN apk add --no-cache \
    bash git unzip icu-dev libzip-dev postgresql-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
  && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) \
    intl \
    pdo_pgsql \
    zip \
    gd \
    opcache \
  && apk del .build-deps

# PHP settings
RUN { \
    echo "memory_limit=512M"; \
    echo "upload_max_filesize=50M"; \
    echo "post_max_size=50M"; \
  } > /usr/local/etc/php/conf.d/app.ini

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Keep container alive + run as www-data
RUN addgroup -g 1000 app && adduser -G app -g app -s /bin/sh -D -u 1000 app
USER app