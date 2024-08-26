FROM php:8.3-apache
#FROM php:7-alpine

COPY . /opt
VOLUME /data

## 安装所需的依赖
RUN apt-get update \
    && apt-get install -y \
        libzip-dev \
        zip \
        unzip

## 安装扩展
RUN docker-php-ext-install zip gd pdo_mysql
RUN docker-php-ext-install curl mongodb pgsql
RUN chmod +x /opt/mumov
RUN mv /opt/htdocs/upload /opt/data
RUN ln -s /data/upload /opt/htdocs/upload

RUN sed -i "s/ROOT_PATH . \'..\//'\//g" /opt/htdocs/application/database.php
RUN mv /opt/htdocs/application/extra /opt/data
RUN ln -s /data/extra /opt/htdocs/application/extra
RUN mv /opt/htdocs/static/player /opt/data
RUN ln -s /data/player /opt/htdocs/static/player

WORKDIR /opt/htdocs
EXPOSE 8088

CMD [ "mumov" ]
