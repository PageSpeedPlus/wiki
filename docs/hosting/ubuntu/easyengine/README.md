# EasyEngine

## Voraussetzung

### OS Minimal Installation

Ubuntu sollte dem Stand einer Minimalinstallation mit den Standart Systemwerkzeugen und des OpenSSH Servers entsprechen. Bei virtuellen Servern darauf achten das der Hostname gesetzt ist und funktioniert. Ebenfalls sollte ein System Benutzer vorhanden sein der nicht root ist. 

- Ubuntu 18.04
- Non-root User
- Hostname

### Port Requirements:

| Name  | Port Number | Inbound | Outbound  |
|:-----:|:-----------:|:-------:|:---------:|
|SSH    |22           | ✓       |✓          |
|HTTP    |80           | ✓       |✓          |
|HTTPS/SSL    |443           | ✓       |✓          |
|EE Admin    |22222           | ✓       |          |
|GPG Key Server    |11371           |        |✓          |

## Quick Start

### Cheatsheet - Site creation

```bash
sudo ee site create example.com --wp     # Install required packages & setup WordPress on example.com
```

|                    |  Single Site  | 	Multisite w/ Subdir  |	Multisite w/ Subdom     |
|--------------------|---------------|-----------------------|--------------------------|
| **NO Cache**       |  --wp         |	--wpsubdir           |	--wpsubdomain           |
| **WP Super Cache** |	--wpsc       |	--wpsubdir --wpsc    |  --wpsubdomain --wpsc    |
| **W3 Total Cache** |  --w3tc       |	--wpsubdir --w3tc    |  --wpsubdomain --w3tc    |
| **Nginx cache**    |  --wpfc       |  --wpsubdir --wpfc    |  --wpsubdomain --wpfc    |
| **Redis cache**    |  --wpredis    |  --wpsubdir --wpredis |  --wpsubdomain --wpredis |

#### Standard WordPress Sites

```bash
ee site create example.com --wp                  # install wordpress without any page caching
ee site create example.com --w3tc                # install wordpress with w3-total-cache plugin
ee site create example.com --wpsc                # install wordpress with wp-super-cache plugin
ee site create example.com --wpfc                # install wordpress + nginx fastcgi_cache
ee site create example.com --wpredis             # install wordpress + nginx redis_cache
```

#### Non-WordPress Sites

```bash
ee site create example.com --html     # create example.com for static/html sites
ee site create example.com --php      # create example.com with php support
ee site create example.com --mysql    # create example.com with php & mysql support
```

#### HHVM Enabled Sites

```bash
ee site create example.com --wp --hhvm           # create example.com WordPress site with HHVM support
ee site create example.com --php --hhvm          # create example.com php site with HHVM support
```

## Useful Links

- [Documentation](https://easyengine.io/docs/)
- [FAQ](https://easyengine.io/faq/)
- [Conventions used](https://easyengine.io/wordpress-nginx/tutorials/conventions/)
- https://kb.virtubox.net/

## EasyEngine GitHub Repos

### [RTCamp](https://github.com/EasyEngine)

- https://github.com/EasyEngine/easyengine
- https://github.com/EasyEngine/eeadmin

### [VirtuBox](https://github.com/VirtuBox)

- https://github.com/VirtuBox/nginx-ee
- https://github.com/PageSpeedPlus/ubuntu-nginx-web-server
- https://github.com/VirtuBox/easyengine-dashboard
- https://github.com/VirtuBox/ee-acme-sh
- https://github.com/VirtuBox/debian-ubuntu-mariadb-backup
- https://github.com/VirtuBox/wp-optimize
