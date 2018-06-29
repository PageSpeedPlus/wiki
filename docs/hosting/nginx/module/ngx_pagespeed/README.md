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

#### Links

- [ngx_pagespeed](https://www.modpagespeed.com/doc/build_ngx_pagespeed_from_source)

[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)
