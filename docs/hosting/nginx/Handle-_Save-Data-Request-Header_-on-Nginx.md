When the user has enabled the `Data Saver` feature in their Browser (Chrome 49+, Yandex 16.2+, Opera 35+), the browser will add a `Save-Data:on` header to each HTTP request. Developers can identify the `Save-Data` header and respond with optimized content (images, stylesheets, fonts, etc.).

As an example, we work with images and return optimized pictures (smaller or more compressed) when the `Save-Data:on` header have been sent.

|                      | Naming convention     |
| -------------------- |:---------------------:|
| Regular image file   | `image.jpg`           |
| Optimized image file | `image.optimized.jpg` |

Solution #1: Good, but not perfect
-----
The following Nginx configuration works fine, but useless: The necessary `Vary:Save-Data` response header can not be set correctly, because it is always returned.

```bash
http {
    
    ## ...
    
    map $http_save_data $save_data_ext_prefix {
        default "";

        on ".optimized";
    }
    
    server {
        
        ## ...
        
        location ~* ^(.+)(\.(?:jpe?g|png|gif))$ {
            
            ## ...

            ## add_header Vary Save-Data; 
            try_files $1$save_data_ext_prefix$2 $uri =404;
        }
        
    }
}
```

Solution #2: Perfect, but not easy
-----
The request will be redirected to the optimized file. The `Vary:Save-Data` header is attached to the response.

```bash
http {
    
    ## ...
    
    map $http_save_data $save_data_ext_prefix {
        default "";

        on ".optimized";
    }
    
    server {
        
        ## ...
        
        location ~* \.(jpe?g|png|gif)$ {
            
            ## ...
            
            if ( $save_data_ext_prefix ) {
                rewrite ^(.+)(\.(?:jpe?g|gif))$ $1$save_data_ext_prefix$2 last;
            }
        
            location ~* \.optimized\. {
                add_header Vary Save-Data;
            }
        }
        
    }
}
```

### Links
* [Delivering Fast and Light Applications with Save-Data](https://developers.google.com/web/updates/2016/02/save-data)
* [The Save-Data Client Hint](http://httpwg.org/http-extensions/client-hints.html)