![NGINX-logo](https://wiki.page-speed.ninja/assets/img/nginx-logo.png)

NGINX ist ein kostenloser, Open-Source-, Hochleistungs-HTTP-Server und Reverse-Proxy sowie ein IMAP / POP3-Proxy-Server. NGINX ist bekannt für seine hohe Leistung, Stabilität, umfangreiche Funktionen, einfache Konfiguration und geringen Ressourcenverbrauch.

NGINX ist einer der wenigen Server, die geschrieben wurden, um das C10K-Problem zu lösen. Im Gegensatz zu herkömmlichen Servern verlässt sich NGINX nicht auf Threads, um Anfragen zu bearbeiten. Stattdessen verwendet es eine viel besser skalierbare ereignisgesteuerte (asynchrone) Architektur. Diese Architektur verwendet kleine, aber viel wichtigere, vorhersehbare Speichermengen unter Last. Selbst wenn Sie nicht erwarten, Tausende von gleichzeitigen Anfragen zu bearbeiten, können Sie dennoch von der hohen Leistung und dem geringen Speicherbedarf von NGINX profitieren. NGINX skaliert in alle Richtungen: vom kleinsten VPS bis hin zu großen Serverclustern.

NGINX betreibt mehrere Websites mit hoher Sichtbarkeit, darunter Netflix, Hulu, Pinterest, CloudFlare, Airbnb, WordPress.com, GitHub, SoundCloud, Zynga, Eventbrite, Zappos, Medientempel, Heroku, RightScale, Engine Yard, MaxCDN und viele andere.

## Installieren & Kompilieren

- [Compiling and Installing from Source](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#compiling-and-installing-from-source)
- [Installing NGINX Dependencies](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#installing-nginx-dependencies)
- [NGiNX Auto Install](https://github.com/Angristan/nginx-autoinstall)

## Konfiguration

Globale Konfigdatei: 

`/etc/nginx/nginx.conf`

vHost Konfigdatei: 

`/etc/nginx/sites-available/`

### Symlinks (sites-enabled)

Um eine **VHost Konfigurationsdatei** aus `/etc/nginx/sites-available/` zu aktivieren muss ein **Symlink** unter `/etc/nginx/sites-enabled/` erstellt werden. Ihr könnt unter `/etc/nginx/sites-available/ `also eine ganze Sammlung von vHosts anlegen und dann bei bedarf mit einem Symlink aktivieren. Es empfiehlt sich den Symlink gleich zu bennen wie den vHost für eine gute Übersicht zu behalten.


Um beispielsweise einen Symlink für eine RoundCube vHost Konfiguration zu erstellen, wird folgender Befehl genutzt:
> **ln -s /etc/nginx/sites-available/roundcube.vhost /etc/nginx/sites-enabled/roundcube.vhost**

Danach muss Nginx seine Konfiguration neu laden:
> **service nginx restart**

![sd](https://imgur.com/bLCU8MW)

### keepalive_timeout, sendfile, tcp_nopush, tcp_nodelay

Setzen Sie `keepalive_timeout` auf einen sinnvollen Wert, wie z.B. zwei Sekunden. Erlauben Sie `sendfile`, `tcp_nopush` und `tcp_nodelay`:

```bash
nano /etc/nginx/nginx.conf
```

**Ergebnis:**

```nginx-conf
sendfile on;
tcp_nopush on;
tcp_nodelay on;
keepalive_timeout 2;
types_hash_max_size 2048;
server_tokens off;
```

### File Cache

Erlauben Sie den Nginx File Cache:

```nginx-conf
open_file_cache max=5000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
open_file_cache_errors on;
```

### Erlauben der Gzip Kompression

Hier können Sie mehr über Gzip Kompression erfahren: How To Save Traffic With nginx's HttpGzipModule (Debian Squeeze)

```nginx-conf
gzip on;
gzip_static on;
gzip_disable "msie6";
gzip_http_version 1.1;
gzip_vary on;
gzip_comp_level 6;
gzip_proxied any;
gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript text/x-js;
gzip_buffers 16 8k;
```
### Erlauben des SSL Session Caches

Falls Sie https Webseiten ausliefern, sollten Sie den SSL Session Cache aktivieren:

```nginx-conf
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
```

### Benutzen des FastCGI Caches

Haben Sie cachebaren PHP Inhalt, so können Sie den Nginx FastCGI Cache benutzen um diesen zu cachen. Fügen Sie dazu in Ihrer `nginx.conf` eine Zeile ähnlich dieser ein:

```nginx-conf
fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=microcache:10m max_size=1000m inactive=60m;
```

Das Cacheverzeichnis `/var/cache/nginx` muss existieren und von Nginx beschreibbar sein:

```nginx-conf
mkdir /var/cache/nginx
chown www-data:www-data /var/cache/nginx
```

(Druch Benutzung von tmpfs können Sie das Verzeichnis sogar direkt im Speicher Ihres Servers platzieren, was einen weiteren Geschwindigkeitsvorteil erbringt - schauen Sie sich dazu dieses Howto an: Storing Files/Directories In Memory With `tmpfs`).

Fügen Sie in Ihrer vHost Konfiguration folgenden Block zur location `~ .php$ {}` Sektion hinzu (wann Inhalte gecached werden und wann nicht können Sie hier einstellen):

```nginx-conf
set $no_cache "";
# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
if ($request_method !~ ^(GET|HEAD)$) {
set $no_cache "1";
}
# Drop no cache cookie if need be
# (for some reason, add_header fails if included in prior if-block)
if ($no_cache = "1") {
add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
add_header X-Microcachable "0";
}
# Bypass cache if no-cache cookie is set
if ($http_cookie ~* "_mcnc") {
set $no_cache "1";
}
# Bypass cache if flag is set
fastcgi_no_cache $no_cache;
fastcgi_cache_bypass $no_cache;
fastcgi_cache microcache;
fastcgi_cache_key $scheme$host$request_uri$request_method;
fastcgi_cache_valid 200 301 302 10m;
fastcgi_cache_use_stale updating error timeout invalid_header http_500;
fastcgi_pass_header Set-Cookie;
fastcgi_pass_header Cookie;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
```

Der komplette location `~ .php$ {}` Block sähe also folgendermaßen aus:

```nginx-conf
location ~ .php$ {

# Setup var defaults
set $no_cache "";
# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
if ($request_method !~ ^(GET|HEAD)$) {
set $no_cache "1";
}
# Drop no cache cookie if need be
# (for some reason, add_header fails if included in prior if-block)
if ($no_cache = "1") {
add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
add_header X-Microcachable "0";
}
# Bypass cache if no-cache cookie is set
if ($http_cookie ~* "_mcnc") {
set $no_cache "1";
}
# Bypass cache if flag is set
fastcgi_no_cache $no_cache;
fastcgi_cache_bypass $no_cache;
fastcgi_cache microcache;
fastcgi_cache_key $scheme$host$request_uri$request_method;
fastcgi_cache_valid 200 301 302 10m;
fastcgi_cache_use_stale updating error timeout invalid_header http_500;
fastcgi_pass_header Set-Cookie;
fastcgi_pass_header Cookie;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;

try_files $uri =404;
include /etc/nginx/fastcgi_params;
fastcgi_pass unix:/var/lib/php5-fpm/web1.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO $fastcgi_script_name;
fastcgi_intercept_errors on;
}
```

Dieser Block cached Seiten mit den Ausgabecodes 200, 301 und 302 für zehn Minuten.

Hier können Sie mehr zu diesem Thema nachlesen: Why You Should Always Use Nginx With Microcaching

### Benutzung von FastCGI Buffern

Sie können in Ihrer vHost Konfiguration folgende Zeilen zur location `~ .php$ {}` Sektion hinzufügen:

```nginx-conf
[...]
fastcgi_buffer_size 128k;
fastcgi_buffers 256 16k;
fastcgi_busy_buffers_size 256k;
fastcgi_temp_file_write_size 256k;
fastcgi_read_timeout 240;
[...]
```

Die ganze location `~ .php$ {}` Sektion könnte wie folgt aussehen:

```
[...]
location ~ .php$ {
try_files $uri =404;
include /etc/nginx/fastcgi_params;
fastcgi_pass unix:/var/lib/php5-fpm/web1.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO $fastcgi_script_name;
fastcgi_intercept_errors on;

fastcgi_buffer_size 128k;
fastcgi_buffers 256 16k;
fastcgi_busy_buffers_size 256k;
fastcgi_temp_file_write_size 256k;
fastcgi_read_timeout 240;
}
[...]
```

### Benutzung von Memcached

nginx kann ganze Seiten direkt aus Memcached auslesen. Ist Ihre Webanwendung also dazu fähig, ganze Seiten in Memcached zu speichern, kann NGiNX diese Seiten auslesen. Eine Beispielkonfiguration (in Ihrem vHost) könnte folgendermaßen aussehen:

```
[...]
location ~ .php$ {
set $no_cache "";
if ($query_string ~ ".+") {
set $no_cache "1";
}
if ($request_method !~ ^(GET|HEAD)$ ) {
set $no_cache "1";
}
if ($request_uri ~ "nocache") {
set $no_cache "1";
}
if ($no_cache = "1") {
return 405;
}

set $memcached_key $host$request_uri;
memcached_pass 127.0.0.1:11211;
default_type text/html;
error_page 404 405 502 = @php;
expires epoch;
}

location @php {
try_files $uri =404;
include /etc/nginx/fastcgi_params;
fastcgi_pass unix:/var/lib/php5-fpm/web1.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO $fastcgi_script_name;
fastcgi_intercept_errors on;
}
[...]
```

Es ist wichtig, dass Ihre Webanwendung zum Speichern der Seiten den selben Schlüssel benutzt wie nginx um Sie von memcached abzuholen (in diesem Beispiel ist es `$host$request_uri`), andernfalls wird es nicht funktionieren.

Speichern Sie viele Daten in memcached müssen Sie sicherstellen, dass Sie memcached ausreichend RAM zugewiesen haben, zum Beispiel:

`nano /etc/memcached.conf`

```
[...]
# Start with a cap of 64 megs of memory. It's reasonable, and the daemon default
# Note that the daemon will grow to this size, but does not start out holding this much
# memory
-m 512
[...]
```

#### 2.9 Browser statische Daten mit der expires Direktive cachen lassen

Dateien, die nicht oft geändert werden (wie Bilder, CSS, JS, etc.), können vom Browser des Besuchers mit Hilfe der expires Direktive gecached werden (siehe http://wiki.nginx.org/HttpHeadersModule#expires):

```
[...]
location ~* .(jpg|jpeg|png|gif|ico)$ {
expires 365d;
}
[...]
`````

### Logging bei statischen Dateien deaktivieren

Normalerweise macht es keinen Sinn Zugriffe auf Bilder oder CSS im Zugriffslog zu protokollieren. Um Disk I/O zu minimieren können Sie deren Protokollierung deaktivieren, zum Beispiel folgendermaßen:

```
[...]
location ~* .(jpg|jpeg|png|gif|ico)$ {
log_not_found off;
access_log off;
}
[...]
```

### PHP-FPM Notfalleinstellungen

Dies ist eher eine Vorsorgeeinstellung als eine, die die Leistung betrifft: PHP-FPM kann sich selbst neustarten, wenn es aufhört zu funktionieren:

`nano /etc/php5/fpm/php-fpm.conf`

```
[...]
; If this number of child processes exit with SIGSEGV or SIGBUS within the time
; interval set by emergency_restart_interval then FPM will restart. A value
; of '0' means 'Off'.
; Default Value: 0
emergency_restart_threshold = 10

; Interval of time used by emergency_restart_interval to determine when
; a graceful restart will be initiated. This can be useful to work around
; accidental corruptions in an accelerator's shared memory.
; Available Units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
emergency_restart_interval = 1m

; Time limit for child processes to wait for a reaction on signals from master.
; Available units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
process_control_timeout = 10s
[...]
```

### Benutzung des ondemand Prozessmanagers bei PHP >= 5.3.9

Benutzen Sie PHP >= 5.3.9 so können Sie den ondemand Prozessmanager in einem PHP-FPM Pool anstatt von static oder dynamic benutzen, dies wird einigen Arbeitsspeicher einsparen:

```
[...]
pm = ondemand
pm.max_children = 100
pm.process_idle_timeout = 5s
[...]
```

### Benutzung von Unix Sockets anstatt von TCP Sockets

Um Netzwerkoverhead zu reduzieren sollten Sie Ihre Pools anweisen, Unix Sockets anstatt von TCP Sockets zu benutzen:

```
[...]
;listen = 127.0.0.1:9000
listen = /var/lib/php5-fpm/www.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
[...]
```

Ändern Sie dies, müssen Sie natürlich die location `~ .php$ {}` Sektion in Ihrem nginx vHost anpassen, sodass der Socket benutzt wird (fastcgi_pass unix:/var/lib/php5-fpm/www.sock; anstatt von fastcgi_pass 127.0.0.1:9000;):

```
[...]
location ~ .php$ {
try_files $uri =404;
include /etc/nginx/fastcgi_params;
##fastcgi_pass 127.0.0.1:9000;
fastcgi_pass unix:/var/lib/php5-fpm/www.sock;
fastcgi_index index.php;```
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_param PATH_INFO $fastcgi_script_name;
fastcgi_intercept_errors on;
}
[...]
```

### Vermeiden Sie `502 Bad Gateway` Fehler mit Sockets auf geschäftigen Seiten

Benutzen Sie Unix Sockets mit PHP-FPM, so könnten Sie `502 Bad Gateway` Fehlern auf oft besuchten Seiten begegnen. Um dies zu vermeiden, erhöhen Sie die maximale Anzahl an erlaubten Verbindungen mit einem Socket. Öffnen Sie `/etc/sysctl.conf`...

`nano /etc/sysctl.conf`

... und setzen Sie:

```
[...]
net.core.somaxconn = 4096
[...]
```

Benutzen Sie danach `sysctl -p` um die Änderungen geltend zu machen.

### SVG & WebP in NGiNX

Make sure you have svg in your mime types (should be there by default)

```bash
nano /etc/nginx/mime.types
```

Find the image line or add it if it is missing

```nginx-conf
image/svg+xml svg svgz;
image/webp;
```

#### WebP Support

Um WebP mit Nginx zu unterstützen und WebP-Bilder automatisch mit einem kompatiblen Webbrowser anzuzeigen, müssen Sie die map-Direktive in der globalen nginx-Konfiguration mit einer location-Direktive in jedem Vhost verwenden.

`nano /etc/nginx/conf.d/webp.conf`

```nginx-conf
map $http_accept $webp_suffix {
   default "";
   "~*webp" ".webp";
}
```

Sie können es direkt mit dem folgenden Befehl herunterladen:

```bash
wget -O /etc/nginx/conf.d/webp.conf https://raw.githubusercontent.com/VirtuBox/nginx-ee/master/etc/nginx/conf.d/webp.conf
```

##### Dann müssen Sie in normalen NGiNX VHosts folgende Konfiguration hinzufügen:

```nginx-conf
location ~ (.+)\.(png|jpe?g)$ {
	if ( $http_accept ~* webp ) {
		set $webp "A";
	}
	if ( $request_filename ~ (.+)\.(png|jpe?g)$ ) {
		set $file_without_ext $1;
	}
	if ( -f $file_without_ext.webp ) {
		set $webp "${webp}E";
	}
 
	if ( $webp = AE ) {
		add_header Vary Accept;
		rewrite (.+)\.(png|jpe?g)$ $1.webp break;
	}
}
```

##### Für WordPress VHosts nutzen Sie dieses Konfigurationsschnippsel

```nginx-conf
location ~* ^/wp-content/.+\.(png|jpg)$ {
  add_header Vary Accept;
  add_header "Access-Control-Allow-Origin" "*";
  access_log off;
  log_not_found off;
  expires max;
  try_files $uri$webp_suffix $uri =404;
}
```

Mit **EasyEngine **können Sie es direkt in `/etc/nginx/common/wpcommon-php7.conf` und `/etc/nginx/common/wpcommon-php72.conf` hinzufügen, um die WebP-Unterstützung für alle Wordpress-Websites zu aktivieren.

Überprüfen Sie mit `nginx -t` Ihre Konfiguration. Wenn Sie korrekt ist müssen wir NGiNX neuladen.

```bash
nginx reload
```

### Add gzip to SVG

open `nano /etc/nginx/nginx.conf` and add **`image/svg+xml`** to `gzip_types` 

Please gzip only dynamic files like scripts. WebP is to compressed for gzip. High CPU for little results by staatic files like images.
                                                              `
-`text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript **image/svg+xml**; `


***

### WordPress Nginx Conf

```nginx-conf
# wp-config.php von Zugriffen schützen
location = /wp-config.php {
	deny all;
		access_log off;
		log_not_found off;
}

# user.ini von Ninja Firewall schützen
location ~ \.ini$ {
	return 444;
}

# XML-RPC Zugriff verweigern
location = /xmlrpc.php {
	deny all;
}

# User ID Link deaktivieren
if ($args ~ "^/?author=([0-9]*)"){
set $rule_0 1$rule_0;
}
if ($rule_0 = "1"){
	return 403;
}

# Block PHP files in uploads, content, and includes directory.
location ~* /(?:uploads|files|wp-content|wp-includes)/.*\.php$ {
	deny all;
}

# ReadMe, Lizenz und Example Files for Zugriffen schützen
if ($uri ~* "^.+(readme|license|example)\.(txt|html)$") {
	return 403;
}

# Block PHP files in uploads directory.
location ~* /(?:uploads|files)/.*\.php$ {
	deny all;
}

# Block PHP files in content directory.
location ~* /wp-content/.*\.php$ {
	deny all;
}

# Block PHP files in includes directory.
location ~* /wp-includes/.*\.php$ {
	deny all;
}
```

***

## TLS - A-Rating SSL Zertifikate

Ich überschreibe alle nginx ssl-Tags in ISPconfig-Templates, da dies unseren Websites eine A + Bewertung bei Qualys SSL-Labs gibt.

Wichtig: 

* https://bjornjohansen.no/optimizing-https-nginx
* [NGINX – sichere SSL/TLS Konfiguration mit Perfect Forward Secrecy (PFS) und A+ Wertung von Qualys SSL Labs](https://der-linux-admin.de/2015/01/nginx-sichere-ssltls-konfiguration-mit-perfect-forward-secrecy-pfs-und-wertung-von-qualys-ssl-labs/)

```nginx-conf
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/ssl/dh4096.pem;
resolver 208.67.222.222 208.67.220.220 valid=300s;
resolver_timeout 18s;
ssl_stapling on;
ssl_stapling_verify off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 2h;
ssl_buffer_size 4k;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Frame-Options SAMEORIGIN;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;             
```



### Verbindungs-Credentials

Fast der gesamte Overhead mit SSL / TLS ist während des anfänglichen Verbindungsaufbaus, durch Zwischenspeichern der Verbindungsparameter für die Sitzung, wird die nachfolgenden Anforderungen drastisch verbessern (oder im Fall von SPDY, Anfragen nach der Verbindung geschlossen - wie eine neue Seite) Belastung).

Alles, was wir brauchen, sind diese zwei Zeilen:

```nginx-conf
ssl_session_cache shared:SSL:20m;
ssl_session_timeout 180m;
```

Dadurch wird ein Cache erstellt, der für alle Arbeitsprozesse freigegeben ist. Die Cachegröße wird in Bytes angegeben (in diesem Beispiel: 20 MB). Laut der Nginx-Dokumentation kann 1MB ungefähr 4000 Sitzungen speichern, also können wir für dieses Beispiel ungefähr 80000 Sitzungen speichern, und wir werden sie für 180 Minuten speichern. Wenn Sie mehr Traffic erwarten, erhöhen Sie die Cache-Größe entsprechend.

Ich empfehle normalerweise nicht, die ssl_session_timeout auf weniger als 10 Minuten zu reduzieren, aber wenn Ihre Ressourcen spärlich sind und Ihre Analyse Ihnen etwas anderes sagt, machen Sie weiter. Nginx ist angeblich schlau genug, um nicht all Ihren RAM im Session-Cache zu verbrauchen, selbst wenn Sie diesen Wert sowieso zu hoch setzen.

### Deaktivieren Sie SSL
- Sag was?

Techischerweise wird SSL (Secure Sockets Layer) durch TLS (Transport Layer Security) abgelöst. Ich denke, es ist nur aus alter Gewohnheit und Konventionen, wir reden immer noch über SSL.

SSL enthält mehrere Schwachstellen, es gab verschiedene Angriffe auf Implementierungen und es ist anfällig für bestimmte Protokoll-Downgrade-Angriffe.

Der einzige Browser oder eine Bibliothek, die noch immer der Menschheit bekannt ist und TLS nicht unterstützt, ist natürlich IE 6. Da dieser Browser tot ist (sollte es keine einzige Entschuldigung auf der Welt geben), können wir SSL sicher deaktivieren.

Die neueste Version von TLS ist 1.2, aber es gibt immer noch moderne Browser und Bibliotheken, die TLS 1.0 verwenden.

Also fügen wir diese Zeile dann zu unserer Konfiguration hinzu:

`ssl_protocols TLSv1.2 TLSv1.3;`

Das war einfach, jetzt zu etwas komplizierterem (was ich dir leicht gemacht habe):

### Optimieren der Cipher Suites

Die Cipher Suites sind der harte Kern von SSL / TLS. Hier findet die Verschlüsselung statt, und darauf werde ich hier wirklich nicht eingehen. Alles, was Sie wissen müssen, ist, dass es sehr sichere Anzüge gibt, es gibt unsichere Suites und wenn Sie der Ansicht sind, dass die Browserkompatibilität im Frontend groß ist, dann ist dies ein ganz neues Ballspiel. Recherchieren, welche Cipher-Suites zu verwenden sind, was nicht und in welcher Reihenfolge zu verwenden ist, erfordert viel Zeit für die Recherche. Zum Glück für dich, ich habe es getan.

Zuerst müssen Sie Nginx konfigurieren, um dem Client mitzuteilen, dass wir eine bevorzugte Reihenfolge der verfügbaren Cipher Suites haben:

`ssl_prefer_server_ciphers on;`

Als nächstes müssen wir die tatsächliche Liste der Chiffren bereitstellen:

`ssl_ciphers 'TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-256-GCM-SHA384:TLS13-AES-128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';`

Alle diese Suiten verwenden Forward Secrecy, und die schnelle Chiffre AES ist die bevorzugte. Sie verlieren die Unterstützung für alle Versionen von Internet Explorer unter Windows XP. Wen interessiert das?

### Generiere DH-Parameter

Wenn Sie eine Erklärung benötigen, lesen Sie den DHE Handshake und Dhparam Teil auf dem Mozilla Wiki. Ich mache das hier nicht.

Erstellen Sie die DH-Parameterdatei mit 2048 Bit langen sicheren Primes:

`openssl dhparam 2048 -out /etc/nginx/cert/dhparam.pem`

Und füge es deiner Nginx-Konfiguration hinzu:

`ssl_dhparam /etc/nginx/cert/dhparam.pem;`

Beachten Sie, dass Java 6 DHParams mit Primzahlen von mehr als 1024 Bit nicht unterstützt. Wenn dir das wirklich wichtig ist, ist irgendwo etwas falsch.

### Aktivieren Sie OCSP stapling

Das Online Certificate Status Protocol (OCSP) ist ein Protokoll zur Überprüfung des Sperrstatus des vorgelegten Zertifikats. Wenn einem richtigen Browser ein Zertifikat vorgelegt wird, wird er den Aussteller dieses Zertifikats kontaktieren, um zu überprüfen, dass es nicht widerrufen wurde. Dies fügt natürlich einen Overhead für die Verbindungsinitialisierung hinzu und stellt auch ein Datenschutzproblem dar, an dem eine dritte Partei beteiligt ist.

Geben Sie OCSP-Heftung ein:

Der Webserver kann in regelmäßigen Abständen den OCSP-Server der Zertifizierungsstelle kontaktieren, um eine signierte Antwort zu erhalten und ihn beim Verbindungsaufbau an den Handshake zu heften. Dies sorgt für eine viel effizientere Verbindungsinitialisierung und hält die dritte Partei aus dem Weg.

Um sicherzustellen, dass die Antwort von der CA nicht manipuliert wird, richten wir Nginx ein, um die Antwort unter Verwendung des CA-Stamms und der Zwischenzertifikate zu überprüfen, ähnlich wie bei der Aktivierung von HTTPS auf Nginx (beachten Sie, dass die Reihenfolge hier wichtig ist) ):

`cat PositiveSSLCA2.crt AddTrustExternalCARoot.crt> trustchain.crt`

Ich verwende ein positives SSL-Zertifikat, daher ist AddTrustExternalCARoot.crt das Stammzertifikat und PositiveSSLCA2.crt ist das Zwischenzertifikat. Ersetzen Sie die Zertifikate Ihres Ausstellers entsprechend. Wenn Sie das Stammzertifikat Ihrer Zertifizierungsstelle nicht besitzen, sollte es auf ihrer Website verfügbar sein oder Sie müssen sie kontaktieren.

Aktivieren Sie als Nächstes Heften und Verifizieren:

```nginx-conf
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/nginx/cert/trustchain.crt;
Resolver 8.8.8.8 8.8.4.4;
```
### Strict Transport Security

Sie müssen auch einen oder mehrere DNS-Server für Nginx bereitstellen. Hier verwende ich die öffentlichen DNS-Server von Google, aber Sie können das für Sie passende verwenden (wenn Sie Google nicht mögen oder Bedenken wegen des Datenschutzes haben, ist OpenDNS möglicherweise eine gute Option für Sie). Die Resolver werden in einem Round-Robin-Modus verwendet, also stellen Sie sicher, dass sie alle gut sind.

Auch wenn Sie bereits alle regulären HTTP-Anforderungen an HTTPS umleiten sollten, wenn Sie SPDY aktiviert haben, sollten Sie Strict-Transport-Sicherheit (STS oder HSTS) aktivieren, um diese Umleitungen zu vermeiden. STS ist eine raffinierte kleine Funktion in modernen Browsern. Der Server legt nur den Antwort-Header Strict-Transport-Security mit einem maximalen Alter fest.

Wenn der Browser diese Kopfzeile gesehen hat, versucht er nicht, den Server für den angegebenen Zeitraum über normales HTTP erneut zu kontaktieren. Es interpretiert alle Anfragen an diesen Hostnamen tatsächlich als HTTPS, egal was passiert. Sie können den Browser sogar anweisen, das gleiche Verhalten für alle Subdomains zu aktivieren. Es wird MITM-Angriffe mit SSLstrip schwieriger machen.

Alles was du brauchst ist diese kleine Zeile in deiner Config:

`add_header Strict-Transport-Security "max-age=31536000" always;`

Das maximale Alter ist in Sekunden festgelegt. 31536000 Sekunden entspricht 365 Tagen.

Wenn Sie möchten, dass HSTS auf alle Subdomains angewendet wird, verwenden Sie stattdessen diese Konfiguration:

`add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;`

Das ist es.


## Aktivere HTTP/2 für das Dashbord von ISPConfig

> **nano /etc/nginx/sites-available/ispconfig.vhost**

**Ersetze nun `listen 8080;` durch `listen 8080 http2;`**

> **service nginx - restart**

## Ajenti - Minimal NGiNX GUI

![Ajenti Dashboard Screenshot](https://wiki.page-speed.ninja/assets/img/ajenti.jpg)

Ein Admin-Tool für ein zivilisierteres Zeitalter, das Ihnen eine schnelle und sichere Möglichkeit bietet, eine entfernte Linux-Box jederzeit mit alltäglichen Tools wie einem Web-Terminal, Texteditor, Dateimanager und anderen zu verwalten.

**Unterstützte Betriebssysteme:**

* **Debian 6** oder neuer
* **Ubuntu 12** oder neuer
* **CentOS 6** oder neuer
* **RHEL 6** oder neuer

**Referenzen:**

* http://ajenti.org/
* [Dokumentation](http://docs.ajenti.org/en/latest/man/install.html)
* https://github.com/ajenti

### Feature-Highlights

Sozusagen das `Webmin` wie es sein sollte für NGiNX.

* **Bestehende Konfiguration**

Nimmt Ihre aktuelle Konfiguration auf und bearbeitet Ihr vorhandenes System ohne Vorbereitung. Überschreibt nicht Ihre Konfigurationsdateien, Optionen und Kommentare. Alle Änderungen sind nicht-destruktiv.

* **Schnelles Leichtgewicht**

Geringer Speicherbedarf und CPU-Auslastung Läuft auf Low-End-Maschinen, Dübeln, Routern und so weiter.

* **Erweiterbar**

Enthält viele Plugins für System- und Softwarekonfiguration, Überwachung und Verwaltung.

* **Responsive UI**

Kann auch auf Tablets und Handys bedient werden.

* **Updates**

Schnelle Update. Funktionen kommem im wöchentlichen Veröffentlichungszyklus hinzu.

### Ajenti Installation 

```nginx-conf
curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh | sudo bash -s -
```

### Ajenti Dashboard Login

* Url: localhost:8000
* User: root
* PW: {Dein root passwd}

***

[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/hosting/nginx/)
