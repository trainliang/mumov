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
#时区扩展
RUN apk add tzdata \
  && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo "${TIMEZONE}" > /etc/timezone \

RUN install-php-extensions zip gd pdo_mysql pdo_pgsql curl mongodb memcache memcached bcmath

RUN chmod +x /opt/mumov && chown www-data:www-data /opt/mumov && \
    mkdir -p /opt/data/upload && chown www-data:www-data /opt/data/upload && \
    ln -s /data/upload /opt/htdocs/upload && chown -R www-data:www-data /opt/htdocs/upload && \

RUN sed -i "s|ROOT_PATH . '..'/'|'/'|g" /opt/htdocs/application/database.php && \
    mv /opt/htdocs/application/extra /opt/data && \
    ln -s /data/extra /opt/htdocs/application/extra && chown -R www-data:www-data /opt/htdocs/application/extra && \
    mv /opt/htdocs/static/player /opt/data && \
    ln -s /data/player /opt/htdocs/static/player && chown -R www-data:www-data /opt/htdocs/static/player

ENV PATH="$PATH:/opt"

WORKDIR /opt/htdocs
EXPOSE 8088

CMD [ "/opt/mumov" ]
