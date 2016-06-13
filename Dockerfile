FROM evild/alpine-php:7.0.7

ARG PIWIK_VERSION=2.16.1
ARG GPG_KEY=814E346FA01A20DBB04B6807B5DBD5925590A237

RUN apk add --no-cache \
      jpeg-dev \
      freetype-dev \
      libpng-dev \
      ssmtp \
      gnupg \
      curl \
      libtool

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
 && docker-php-ext-install gd mbstring pdo_mysql zip \
 && pecl install APCu \
 && cd /tmp \
 && curl -fsSL -o piwik.tar.gz \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz" \
 && curl -fsSL -o piwik.tar.gz.asc \
      "https://builds.piwik.org/piwik-${PIWIK_VERSION}.tar.gz.asc" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${GPG_KEY}  \
 && gpg --batch --verify piwik.tar.gz.asc piwik.tar.gz \
 && tar -xzf piwik.tar.gz -C /usr/src/ \
 && curl -fsSL -o GeoIPCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && tar xzf /usr/src/piwik/misc/GeoIPCity.dat.gz -C /usr/src/piwik/misc/ \
 && curl -fsSL -o /usr/src/piwik/misc/CountryGeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
 && tar xzf /usr/src/piwik/misc/CountryGeoIP.dat.gz -C /usr/src/piwik/misc/ \
 && rm -rf /tmp

VOLUME /var/www/html

ADD root /
