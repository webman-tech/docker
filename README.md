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

## 当开发环境使用

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
