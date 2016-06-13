FROM evild/alpine-php:7.0.7

ARG PIWIK_VERSION=2.16.1

RUN apk add --no-cache \
      jpeg-dev \
      freetype-dev \
      geoip \
      libpng-dev \
      ssmtp \
      zip \
      gnupg \
      curl

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
 && docker-php-ext-install gd mbstring pdo_mysql zip

RUN pecl install APCu geoip



RUN curl -fsSL -o piwik.tar.gz \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz" \
 && curl -fsSL -o piwik.tar.gz.asc \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 814E346FA01A20DBB04B6807B5DBD5925590A237 \
 && gpg --batch --verify piwik.tar.gz.asc piwik.tar.gz \
 && rm -r "$GNUPGHOME" piwik.tar.gz.asc \
 && tar -xzf piwik.tar.gz -C /usr/src/ \
 && rm piwik.tar.gz

COPY php.ini /usr/local/etc/php/php.ini

VOLUME /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
