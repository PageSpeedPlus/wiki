# EasyEngine

**[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)**

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

## Schnell Start

### Cheatsheet - Seite erstellen

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

## Dateisystemlayout

### EasyEngine

* `/var/log/ee/install.log` - Installation Log File
* `/var/log/ee/ee.log` - EasyEngine Error Log

#### Standartkonfig für Websiten

`nano /etc/ee/ee.conf`

| **Konfiguration** | **Beschreibung** |
|-------------------------------|-------------------------------------------------------------------|
| `mysqlhost=rtcamp.com` | MariaDB Host ändern. |
| `db-name = true` | Beim erstellen einer Site einen eigenen Datenbanknamen angeben. |
| `db-user = true` | Beim erstellen einer Site einen eigenen Datenbankuser angeben. |
| `prefix = true` | Beim erstellen einer Site einen eigenen Datenbankuprefix angeben. |
| `user = rtcamp` | WordPress User definieren. |
| `password = mypass` | WordPress Passwort definieren. |
| `email =  yourmail@example.com` | WordPress Email definieren. |

### Nginx

#### Konfigurationsdateien:

* `/etc/nginx/` – all nginx related configuration will be in this folder
* `/etc/nginx/nginx.conf ` – THE (main) nginx configuration file
* `/etc/nginx/sites-available/` – nginx configuration for different sites will be available here
* `/etc/nginx/sites-enables/` – symlinks to nginx configuration files which are “active”

#### Log Files:

* `/var/log/nginx/` – default log directory for nginx. We will use this for logs of all sites we will create.
* `/var/log/nginx/example.com.access.log` – access log file for example.com
* `/var/log/nginx/example.com.error.log` – error log file for example.com
* `/etc/logrotate.d/nginx` – this file control log-rotation policy for nginx related log files

### PHP

#### Konfigurationsdateien:

* `/etc/php5/` – all php related configuration will be in this folder
* `/etc/php5/fpm/php.ini` – THE (main) php configuration file
* `/etc/php5/fpm/php-fpm.conf` – FPM related settings
* `/etc/php5/fpm/conf.d/www.conf` – “www” i.e. default pool related settings

#### Log Files:

Note: You may not find following files by default. They were added in by us.

* `/var/log/php5-fpm/` – php related to logs. you should check this if you feel your site is slow or broken
* `/var/log/php5-fpm/slow.log` – this file will help you find slow php scripts
* `/var/log/php5-fpm/php.log` – this file will help you find slow php scripts
* `/etc/logrotate.d/php5-fpm` – this file control how long php logs will be maintained

### MariaDB

#### Konfigurationsdateien:

* `/etc/mysql/my.cnf` – this is mysql configuration file (not folder)
* `/etc/mysql/conf.d/my.cnf` - MariaDB root User Daten

#### Log Files:

* `/var/log/mysql/mysql.log` – mysql general/error logs
* `/var/log/mysql/mysql-slow.log` – this file will help you find slow mysql queries
* `/etc/logrotate.d/mysql-server` – this file control how long php logs will be maintained

### Website Struktur

Following is the convention we will be using for WordPress as well as non-WordPress sites.

* `/var/www` – all your websites will be here
* `/var/www/example.com` – everything related to example.com will be inside this folder
* `/var/www/example.com/htdocs` – this is web-root for example.com. Its like DocumentRoot in Aapche. You will put WordPress will here.
* `/var/www/example.com/logs` – contains logs for example.com only.
* `/var/www/example.com/logs/access.log` – contains access.logs for example.com only. If you want to use a tool like AWStat then this is the server-log file you will need. This is a symbolic link to /var/log/nginx/example.com.access.log file.
* `/var/www/example.com/logs/error.log` – contains error.logs for example.com only. This will help you in debugging. It captures some PHP related error as well. This is a symbolic link to /var/log/nginx/example.com.error.log file.
* `/var/www/example.com/wp-content` – in case you want to keep wp-content outside web-accessible folder. I will NOT cover this in this tutorial. Consider this is an exercise for yourself!

### Anmerkungen:

#### Einige Anmerkungen zur oben genannten Website-Struktur:

Die folgende Struktur berücksichtigt keine Shared-Hosting-Szenarien, bei denen sich im Allgemeinen alle Websites für einen Benutzer in seinem Home-Verzeichnis befinden. Etwas wie `/home/bill/www` oder `/home/bill/public_html`
Subdomains werden wie Domains behandelt. Sie befinden sich direkt unter `/var/www` mit ihrem eigenen Ordner `htdocs` und logs. z.B. subdomain.example.com verwendet das Verzeichnis `/var/www/subdomain.example.com`

#### Hinweise zu den Dateien `access.log` und `error.log` für Websites:

Sie haben vielleicht bemerkt, dass Sie `access.log` & `error.log` für eine Domain auf zwei Arten überprüfen können - entweder im Log-Ordner unter Domain oder im Log-Ordner von Nginx. Es gibt wenige Gründe für diese Art von Setup:

Wenn Sie alle Log-Dateien unter `/var/log/nginx` location aufbewahren, können Sie Dinge wie die Logrotation und die Datenträgerbereinigung sehr einfach machen. Auch das Überprüfen von Protokollen für alle auf Ihrem nginx-Server gehosteten Sites oder für alle Subdomains für eine Top-Level-Domain ist einfach.

Site-spezifische Protokollordner können das Debuggen vereinfachen. Aus Sicherheitsgründen möchten Sie möglicherweise auch einen Benutzer erstellen und ihm nur Zugriff auf eine bestimmte Site gewähren. In diesem Fall können wir auf Protokolle für diese Site zugreifen (falls erforderlich).

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
