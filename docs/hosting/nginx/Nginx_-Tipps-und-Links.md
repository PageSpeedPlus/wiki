## Nginx-Tipps


### 1. Nginx zuverlässig reloaden

Vor einem Reload/Restart des Webservers stets die Nginx-Konfiguration validieren lassen. Der nachfolgende Befehl prüft vorhandene Konfigurationsdateien auf ihre Richtigkeit, erst im Erfolgsfall wird Nginx reloaded.

```bash
nginx -t && service nginx reload
```

Übrigens verursacht `reload` im Vergleich zu einem `restart` keine Downtime.


### 2. Nginx Debugging-Log nutzen

Ist die Nginx-Installation mit `--with-debug` kompiliert, können Error-Logs mit sogenanntem `debug` Level versehen werden. Einmal aktiviert, protokoliert Nginx alle Prozesse, die der Erledigung von Todos beigetragen haben. [A debugging log](http://nginx.org/en/docs/debugging_log.html).

```bash
error_log /path/to/log debug;
```

Somit lassen sich alle Regel, Definitionen und Konfigurationen als Arbeitsschritte nachvollziehen, die Nginx für die Ermittlung, Generierung und Ausgabe der Daten unternommen hat. Perfektes Instrument für Profiling unter Nginx.


### 3. Filterung für Nginx Access-Log

Seit Nginx 1.7.0 ist es möglich, bestimmte Requests nicht ins Access-Log zu schreiben. Das kann beispielsweise dann sehr praktisch sein, wenn ein Monitoring-Tool die Website alle X Minuten aufruft. Aufrufe solcher Art sollten im Access-Log nicht auftauchen, da sie sonst die Log-Datei „zumüllen“ würden. Die eingeführte `if` Direktive dient als Filter für Log-Einträge. [access_log Dokumentation](http://nginx.org/en/docs/http/ngx_http_log_module.html#access_log).

```bash
access_log /path/to/log if=$is_not_wemonit;
```

Das nachfolgende Gist zeigt anhand von WeMonit (Monitoring Service) eine Lösung, wie Erreichbarkeitsanfragen fern vom Access-Log gehalten werden: [NGINX: Keine WeMonit-Requests im Access-Log](https://gist.github.com/sergejmueller/8feabb2684a431db2f0c)


##### Hinweise
* Je nach Servereinstellung ist es notwendig, `sudo` voranzustellen.



## Links

### Mehr Tipps

* https://www.scalescale.com/tips/nginx/
* https://bugs.launchpad.net/nginx/+bug/1450770

### Nginx.conf

* [nginx Redirect 404 Errors to Homepage WordPress](https://guides.wp-bullet.com/nginx-redirect-404-errors-to-homepage-wordpress/)
* [Configure fail2ban to Ban nginx 403 Forbidden Requests](https://guides.wp-bullet.com/configure-fail2ban-to-ban-nginx-403-forbidden-requests/)
* [Protect WordPress wp-login with nginx HTTP Auth + fail2ban](https://guides.wp-bullet.com/protect-wordpress-wp-login-nginx-http-auth-fail2ban/)
* [Protect WordPress wp-login with Apache HTTP Auth + fail2ban
](https://guides.wp-bullet.com/protect-wordpress-wp-login-apache-http-auth-fail2ban/)
* [Install Redis Object Cache for WordPress PHP 7 on Ubuntu 16.04](https://guides.wp-bullet.com/install-redis-object-cache-for-wordpress-php-7-on-ubuntu-16-04/)
* [Automatically Whitelist ManageWP IPs on Cloudflare bash Script
](https://guides.wp-bullet.com/automatically-whitelist-managewp-ips-cloudflare-bash-script/)
