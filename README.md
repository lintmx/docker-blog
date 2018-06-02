# Docker Blog

Docker 化 Hexo 博客，并同步 GitHub 文章仓库。

# Usage

- 修改 `docker-compose.yml` 文件

```
环境变量（environment）
- TOKEN=GitHub Webhooks 密钥

挂载（volumes）
- ./hook/:项目位置/hook
```

- 修改 `hexo/entrypoint.sh` 文件

```
文章仓库与主题仓库
```

- 自定义

```
Hexo 配置文件
/hexo/conf.d/_config.yml

Themes 目录
/themes
```

- Blog 页面输出文件夹

```
/blog
```

- 文章仓库 WebHooks

```
https://developer.github.com/webhooks/
```

- ~~初号机出动~~

```
docker-compose up
```

# Warn

宿主机需要配置 nginx 与 php-fpm 通信以监听 GitHub Webhooks。

nginx 配置示例：

```
server {
    listen 80;

    server_name webhooks.com;

    index index.php index.html index.htm;

    root 项目位置/hook;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

# License

MIT