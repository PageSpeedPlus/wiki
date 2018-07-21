# EasyEngine

## Installation von EasyEngine

```bash
wget -qO ee rt.cx/ee && sudo bash ee
ee stack install --nginx
ee system remove nginx
wget -O - https://raw.githubusercontent.com/VirtuBox/nginx-ee/master/nginx-build.sh
# ee site create "EXAMPLE.COM" --wpfc --letsencrypt --php7.0
```

### Installation von PHP 7.1 odr PHP 7.2

```bash
apt-get -y install apt-transport-https lsb-release ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update
```

## [Nginx-EE](https://virtubox.github.io/nginx-ee/)

Kompilieren und installieren Sie die neueste nginx-Version mit EasyEngine

![nginx-ee](https://raw.githubusercontent.com/VirtuBox/nginx-ee/master/nginx-ee.png)

### Features

* Aktualisieren Sie Nginx auf die neueste Hauptversion
* Zusätzliche Module
* Unterstützung für TLS v1.3

### Zusätzliche Modules 

* ngx_cache_purge
* memcached_nginx_module
* headers-more-nginx-module
* ngx_coolkit
* ngx_brotli 
* redis2-nginx-module
* srcache-nginx-module
* ngx_http_substitutions_filter_module
* nginx-dynamic-tls-records-patch_1.13.0+
* Openssl 1.1.1
* ngx_http_auth_pam_module
* ngx_pagespeed (optional)
* naxsi WAF (optional)

### Kompatibilität

* Ubuntu 16.04 LTS
* Debian 8 Jessie 

### Voraussetzung

* Nginx already installed by EasyEngine 

### Custom EasyEngine NGiNX Installation

```bash
bash <(wget -O - https://raw.githubusercontent.com/VirtuBox/nginx-ee/master/nginx-build.sh)
```

### PHP 7.1 oder PHP 7.2 auf EasyEnigen nutzen 

* https://kb.virtubox.net/knowledgebase/install-php71-php72-fpm-easyengine-ubuntu/#vhost



