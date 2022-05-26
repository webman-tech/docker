ARG PHP_CLI_VERSION=7.4.29-cli-alpine
ARG PHP_EXTENSION_INSTALL_VERSION=1.5.17
ARG COMPOSER_VERSION=2.3.5

FROM mlocati/php-extension-installer:$PHP_EXTENSION_INSTALL_VERSION AS php-extension-installer

# https://hub.docker.com/_/php
FROM php:$PHP_CLI_VERSION

# 系统依赖安装
RUN apk add --no-cache supervisor unzip

# PHP 扩展安装
# install-php-extensions https://github.com/mlocati/docker-php-extension-installer
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
# https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
RUN install-php-extensions \
    bcmath \
    event \
    gd \
    mysqli \
    pdo_mysql \
    opcache \
    pcntl \
    redis \
    sockets \
    zip \
    @composer-$COMPOSER_VERSION

# 展示各组件
RUN php -v
RUN php -m
RUN composer
RUN install-php-extensions

# 设置配置文件
# php
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY config/php.ini "$PHP_INI_DIR/conf.d/app.ini"
# supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 设置项目目录
RUN mkdir -p /app
WORKDIR /app

# 暴露端口
EXPOSE 8787

# 启动脚本
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
