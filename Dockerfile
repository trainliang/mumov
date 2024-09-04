# 第一阶段：构建 PHP 扩展安装器
FROM php:8.3-fpm-alpine3.18 AS build-tools

RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

# 第二阶段：实际构建
FROM php:8.3-fpm-alpine3.18

COPY --from=build-tools /usr/local/bin/install-php-extensions /usr/local/bin/install-php-extensions

COPY . /opt
VOLUME /data

RUN apk add --no-cache --update tzdata \
        imagemagick-dev freetype-dev  libzip-dev libpng-dev curl-dev  libjpeg-turbo-dev  \
        libwebp-dev libjpeg-turbo-dev libpng-dev  freetype-dev libzip-dev && \
    rm -rf /var/cache/apk/*

RUN install-php-extensions zip gd pdo_mysql pdo_pgsql curl mongodb memcache memcached bcmath

RUN chmod +x /opt/mumov && chown www-data:www-data /opt/mumov && \
    mkdir -p /opt/htdocs/upload && chown www-data:www-data /opt/htdocs/upload && \
    ln -s /data/upload /opt/htdocs/upload && chown -R www-data:www-data /opt/htdocs/upload

RUN ln -s /data/application /opt/htdocs/application && chown -R www-data:www-data /opt/htdocs/application && \
    ln -s /data/template /opt/htdocs/template && chown -R www-data:www-data /opt/htdocs/template&& \
    ln -s /data/extend /opt/htdocs/extend && chown -R www-data:www-data /opt/htdocs/extend

ENV PATH="$PATH:/opt"

WORKDIR /opt/htdocs
EXPOSE 8088

CMD [ "/opt/mumov" ]
