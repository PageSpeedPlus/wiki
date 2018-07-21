`Imagine` - Simple Image Resizing API

#### Requirements
* [ngx_http_image_filter_module](http://nginx.org/en/docs/http/ngx_http_image_filter_module.html)

#### Usage
* http://localhost/imagine/picture.jpg?w=1024&q=75
* http://localhost/imagine/picture.jpg?h=500&q=30

Parameter | Description
--- | ---
`w` | Resized width in pixels
`h` | Resized height in pixels
`q` | Compression percentage

All parameters are optional.

#### Protection
Please secure the `Imagine` from attacks by using
* filters
* parameter restrictions/ranges
* [ngx_http_secure_link_module](http://nginx.org/en/docs/http/ngx_http_secure_link_module.html)


#### nginx.conf
```nginx
## LOAD MODULE
load_module modules/ngx_http_image_filter_module.so;

## PROXY CACHE
proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=resized:10m max_size=256m inactive=1h use_temp_path=off;

server {
    ## LISTEN
    listen 80 default_server;
    listen [::]:80 default_server;

    ## SERVER
    server_name _;

    ## CACHING
    location /imagine {
        proxy_cache resized;
        proxy_cache_min_uses 2;
        proxy_cache_lock on;
        proxy_cache_valid 200 1d;
        proxy_cache_valid any 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;

        proxy_set_body none;
        proxy_redirect off;

        proxy_pass http://127.0.0.1:9001;
        proxy_pass_request_headers off;

        add_header X-Proxy-Cache $upstream_cache_status;
    }
}

server {
    ## LISTEN
    listen 9001;

    ## SECURITY
    allow 127.0.0.1;
    deny all;

    ## METHOD LIMIT
    limit_except GET {
        deny all;
    }

    ## ROOT
    root /var/www/imagine;

    ## RESIZE
    location / {
        set $w "-";
        set $h "-";
        set $q "85";

        if ( $arg_w ) {
            set $w $arg_w;
        }
        if ( $arg_h ) {
            set $h $arg_h;
        }
        if ( $arg_q ) {
            set $q $arg_q;
        }

        image_filter                resize $w $h;
        image_filter_jpeg_quality   $q;
        image_filter_buffer         10M;
        image_filter_interlace      on;
    }
}
```