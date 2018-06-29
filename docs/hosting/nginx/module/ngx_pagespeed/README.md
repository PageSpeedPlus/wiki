# ngx_pagespeed

[Zu NGiNX Module zurück](https://wiki.page-speed.ninja/hosting/nginx/module/)

## ngx_pagespeed Konfiguration

Wir verwenden zwei Dateien, um die Seitengeschwindigkeitskonfiguration mit Nginx einzustellen

### Globale Einstellungen

`nano /etc/nginx/conf.d/pagespeed`

```nginx-conf
# disable pagespeed to activate it on each vhost
pagespeed standby;

# admin panel path
pagespeed GlobalStatisticsPath /ngx_pagespeed_global_statistics;
pagespeed MessagesPath /ngx_pagespeed_message;
pagespeed ConsolePath /pagespeed_console;
pagespeed AdminPath /pagespeed_admin;
pagespeed GlobalAdminPath /pagespeed_global_admin;

# hide pagespeed version in header 
pagespeed XHeaderValue "ngx_pagespeed";

# cache path
pagespeed FileCachePath /var/ngx_pagespeed_cache;
# cache with memcached 
#pagespeed MemcachedServers "127.0.0.1:11211";

# statistics and logs
pagespeed Statistics on;
pagespeed StatisticsLogging on;
pagespeed LogDir /var/log/pagespeed;
```

### VHost Einstellungen

Die zweite ist  `/etc/nginx/common/pagespeed-vhost.conf`.
Fügen Sie nun einfach `include common/pagespeed-vhost.conf` in Ihre VHost Konfigdatei.

`nano /etc/nginx/common/pagespeed-vhost.conf`

```nginx-conf
# enable pagespeed
pagespeed on;


# Ensure requests for pagespeed optimized resources go to the pagespeed handler
# and no extraneous headers get set.
location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
  add_header "" "";
}
location ~ "^/pagespeed_static/" { }
location ~ "^/ngx_pagespeed_beacon$" { }

# Filter settings
# filters outlined at http://ngxpagespeed.com/ngx_pagespeed_example/
pagespeed RewriteLevel CoreFilters;
pagespeed EnableFilters collapse_whitespace,remove_comments;

# rewrite_images
# https://developers.google.com/speed/docs/mod_pagespeed/filter-image-optimize
pagespeed EnableFilters rewrite_images;

# inline_google_font_css
# https://developers.google.com/speed/pagespeed/module/filter-css-inline-google-fonts
pagespeed EnableFilters inline_google_font_css;

# Purge nginx pagespeed cache
# https://developers.google.com/speed/pagespeed/module/system#flush_cache
pagespeed EnableCachePurge on;
pagespeed PurgeMethod PURGE;

# Additional settings
pagespeed PreserveUrlRelativity on;
pagespeed MaxCombinedCssBytes -1;
pagespeed AvoidRenamingIntrospectiveJavascript on;

# protect admin panel with ACL
location /ngx_pagespeed_statistics { include common/acl.conf; }
location /ngx_pagespeed_global_statistics { include common/acl.conf; }
location /ngx_pagespeed_message { include common/acl.conf; }
location /pagespeed_console { include common/acl.conf; }
location ~ ^/pagespeed_admin { include common/acl.conf; }
```

![ngx_PageSpeed](https://imgur.com/xxdKxWW)

##  ngx_PageSpeed Modul konfigurieren
[News zur aktuellen Version](https://www.modpagespeed.com/doc/release_notes)
***

Als Teil des NGiNX Servers wird es ebenfalls über die `nginx.conf` konfiguriert.

> `nano /etc/nginx/nginx.conf`

## PageSpeed für Virtual Hosts aktivieren mit folgenden Zeilen:

> `pagespeed on; `

> `pagespeed FileCachePath /var/ngx_pagespeed_cache; `

Stell sicher dass der Cache Pfad existiert und die Nutzerrechte stimmen:

```bash
mkdir /var/ngx_pagespeed_cache
chown -R www-data:www-data /var/ngx_pagespeed_cache
service nginx reload
```

## PageSpeed prüfen

`curl -I -p http://localhost|grep X-Page-Speed`

Folgendes Ergebnis erscheint:

- % Total % Received % Xferd Average Speed Time Time Time Current
- Dload Upload Total Spent Left Speed
- 0 0 0 0 0 0 0 0 --:--:-- --:--:-- --:--:-- 0
- X-Page-Speed: 1.9.32.3-4448`

PageSpeed kann auf den V-Hosts jeweils induviduell angepasst werden.

![VHost Konfig](https://picload.org/view/drcoarca/nginx-vhost-pagespeed.jpg.html)

## PageSpeed Filter

Eine übersicht aller [Filter](https://www.modpagespeed.com/) zu bekommen dürfte schwierig werden. Da es oft für das gleiche Prinzip ähnliches gibt. Als Liste `PageSpeed Filter Referenzen` sehen Sie den Versuche diese etwas zusammen zu fassen.

## PageSpeed Filter Referenzen

> * Add Head
> * Add Instrumentation
> * Async Google AdSense
> * Async Google Analytics
> * Canonicalize JavaScript Libraries
> * Collapse Whitespace
> * Combine CSS
> * Combine JavaScript
> * Combine Heads
> * Convert Meta Tags
> * Deduplicate Inlined Images
> * Defer JavaScript
> * Elide Attributes
> * Extend Cache
> * Extend Cache PDFs
> * Filters and Options for Optimizing Images
> * Flatten CSS @imports
> * Hint Resource Preloading
> * Include JavaScript Source Maps
> * Inline @import to Link
> * Inline CSS
> * Inline Google Fonts API CSS
> * Inline JavaScript
> * Inline Preview Images
> * Insert Google Analytics
> * Lazily Load Images
> * Local Storage Cache
> * Make Images Responsive
> * Minify JavaScript
> * Move CSS Above Scripts
> * Move CSS to Head
> * Optimize Images
> * Outline CSS
> * Outline JavaScript
> * Pedantic
> * Pre-Resolve DNS
> * Prioritize Critical CSS
> * Remove Comments
> * Remove Quotes
> * Rewrite CSS
> * Rewrite Domain
> * Rewrite Style Attributes
> * Run Experiments
> * Sprite Images
> * Trim URLs

## Anleitungen

* [Konfiguration](https://www.modpagespeed.com/doc/configuration)
* [Filter](https://www.modpagespeed.com/doc/config_filters)
* [PageSpeed Admin Pages](https://www.modpagespeed.com/doc/admin)
* [PageSpeed Console](https://www.modpagespeed.com/doc/console)
* [Optimierung auf Bandbreite](https://www.modpagespeed.com/doc/optimize-for-bandwidth)
* [Domain Mapping](https://www.modpagespeed.com/doc/domains)
* [URL Control](https://www.modpagespeed.com/doc/restricting_urls)
* [HTTPS Support](https://www.modpagespeed.com/doc/https_support)
* [System Integration](https://www.modpagespeed.com/doc/system)
* [Experimental](https://www.modpagespeed.com/doc/experiment)
* [Starthilfe Experiment](https://www.modpagespeed.com/doc/module-run-experiment)
* [Konsole (Manuelles Optimieren)](https://www.modpagespeed.com/doc/console)
* [Downstream Caches](https://www.modpagespeed.com/doc/downstream-caching)
* [Image Filter and Option Reference](https://www.modpagespeed.com/doc/reference-image-optimize)

#### Links

- [ngx_pagespeed](https://www.modpagespeed.com/doc/build_ngx_pagespeed_from_source)

[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)
