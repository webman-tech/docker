# webman docker

[docker hub](https://hub.docker.com/r/krisss/docker-webman)

- krisss/docker-webman:7.4-cli-alpine
- krisss/docker-webman:8.0-cli-alpine
- krisss/docker-webman:8.1-cli-alpine

会通过 github actions 动态更新 php 的小版本，镜像 tag 名不变

## 镜像中的组件

- [php](https://hub.docker.com/_/php): extension 包含：bcmath、event、gd、mysqli、pdo_mysql、opcache、pcntl、redis、sockets、zip
- [composer](https://getcomposer.org/)
- [install-php-extensions](https://github.com/mlocati/docker-php-extension-installer)
- [supervisor](http://supervisord.org/)

## 当开发环境使用：目前代码未建立

启动镜像

```bash
docker run --rm --name webman \
 -v /local/workspace:/app \
 -p 8787:8787 \
 -it \
 --privileged -u root \
 --entrypoint /bin/sh \
 krisss/docker-webman:7.4-cli-alpine
```

创建项目

```bash
composer create-project workerman/webman
```

启动项目

```bash
cd webman
php start.php start
```

访问 http://localhost:8787 即可

## 当开发环境使用：已有 webman 代码

在项目下自建 `docker-compose.yml`，参考例子如下：

```yml
version: "3.7"

services:
  webman:
    image: krisss/docker-webman:${DOCKER_WEBMAN_VERSION:-7.4-cli-alpine}
    ports:
      - "${DOCKER_WEBMAN_PORT:-8787}:8787"
    volumes:
      - .:/app
```

启动：

```bash
docker-compose up
```

访问 http://localhost:8787 即可


## 打包项目成镜像

在项目下自建 `Dockerfile`，参考例子如下：

```Dockerfile
ARG WEBMAN_DOCKER_VERSION=7.4-cli-alpine

# https://github.com/krissss/docker-webman
FROM krisss/docker-webman:$WEBMAN_DOCKER_VERSION

# 增加额外的扩展
#RUN install-php-extensions imagick

# 设置配置文件
# 自定义 php 配置文件，如果需要的话
# 覆盖镜像自带的
#COPY environments/docker/php.ini "$PHP_INI_DIR/conf.d/app.ini"
# 扩展额外的
#COPY environments/docker/my_php.ini "$PHP_INI_DIR/conf.d/my_php.ini"
# 自定义 supervisor 配置，如果需要的话
# 覆盖镜像自带的
#COPY environments/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# 扩展额外的
#COPY environments/docker/my_supervisord.conf /etc/supervisor/conf.d/my_supervisord.conf

# 预先加载 Composer 包依赖，优化 Docker 构建镜像的速度
COPY ./composer.json /app/
COPY ./composer.lock /app/
RUN composer install --no-interaction --no-dev --no-autoloader --no-scripts

# 复制项目代码
COPY . /app

# 执行 Composer 自动加载和相关脚本
RUN composer install --no-interaction --no-dev && composer dump-autoload

```

编译：

```bash
docker build -t {image-name} .
```

运行：

```bash
docker run --rm -p 8787:8787 {image-name}
```

访问 http://localhost:8787 即可