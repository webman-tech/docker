# https://hub.docker.com/_/php
ARG PHP_CLI_VERSION=7.4-cli-alpine
# https://hub.docker.com/r/mlocati/php-extension-installer
ARG PHP_EXTENSION_INSTALL_VERSION=latest
# https://hub.docker.com/r/composer/composer
ARG COMPOSER_VERSION=latest

# install-php-extensions
FROM mlocati/php-extension-installer:$PHP_EXTENSION_INSTALL_VERSION AS php-extension-installer
# composer
FROM composer/composer:$COMPOSER_VERSION AS composer

# 开始构建
FROM php:$PHP_CLI_VERSION

# 系统依赖安装
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN apk add --no-cache supervisor unzip

# 处理 PEAR 版本问题：https://github.com/webman-tech/docker/actions/runs/39712721745
# 将 PEAR 升级到最新版
# 仅 PHP < 8.2 需要：7.4/8.0/8.1 这些 EOL 镜像冻结的旧 PEAR（<1.10.17）不支持 HTTP chunked，
# 而 pecl.php.net（BunnyCDN）对条件请求返回 chunked 响应，旧 PEAR 把 chunked 流当 XML
ARG PHP_CLI_VERSION
RUN set -eux; \
    case "${PHP_CLI_VERSION%%-*}" in \
        7*|8.0*|8.1*) \
            latest="$(curl -sSI -o /dev/null -w '%{redirect_url}' https://github.com/pear/pear-core/releases/latest)"; \
            ver="${latest##*/}"; \
            ver="${ver#v}"; \
            curl -sSLf "https://pear.php.net/get/PEAR-${ver}.tgz" -o /tmp/PEAR.tgz; \
            tar xzf /tmp/PEAR.tgz -C /tmp; \
            cp "/tmp/PEAR-${ver}/PEAR.php" /usr/local/lib/php/PEAR.php; \
            cp -r "/tmp/PEAR-${ver}/PEAR/." /usr/local/lib/php/PEAR/; \
            rm -rf "/tmp/PEAR-${ver}" /tmp/PEAR.tgz \
            ;; \
        *) \
            echo "PEAR upgrade skipped: PHP >= 8.2 ships PEAR 1.10.18 (chunked support)" \
            ;; \
    esac

# PHP 扩展安装
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
    zip

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
