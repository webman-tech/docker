# webman docker

# 当开发环境使用

启动镜像

```bash
docker run --rm --name webman \
 -v /local/workspace:/app \
 -p 8787:8787 \
 -it \
 --privileged -u root \
 --entrypoint /bin/sh \
 kriss/docker-webman
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
