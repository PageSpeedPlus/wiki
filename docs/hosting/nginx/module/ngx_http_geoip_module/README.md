# ngx_http_geoip_module

[Zu NGiNX Module zurück](https://wiki.page-speed.ninja/hosting/nginx/module/)

How to configure GeoIP module for Nginx

Create a folder to store the databases : 
```
mkdir -p /usr/share/GeoIP
```

Download Country IP database
```
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz
mv  GeoIP.dat /usr/share/GeoIP/GeoIP.dat
```

Download City IP database
```
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip GeoLiteCity.dat.gz
mv GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
```

Add the following line to your nginx.conf file :
```
geoip_country /usr/share/GeoIP/GeoIP.dat;
geoip_city /usr/share/GeoIP/GeoIPCity.dat;
```

And the following lines to your /etc/nginx/fastcgi_params
  
```
fastcgi_param GEOIP_ADDR $remote_addr;
fastcgi_param GEOIP_COUNTRY_CODE $geoip_country_code;
fastcgi_param GEOIP_COUNTRY_NAME $geoip_country_name;
fastcgi_param GEOIP_REGION $geoip_region;
fastcgi_param GEOIP_REGION_NAME $geoip_region_name;
fastcgi_param GEOIP_CITY $geoip_city;
fastcgi_param GEOIP_AREA_CODE $geoip_area_code;
fastcgi_param GEOIP_LATITUDE $geoip_latitude;
fastcgi_param GEOIP_LONGITUDE $geoip_longitude;
fastcgi_param GEOIP_POSTAL_CODE $geoip_postal_code;
```

Check if everything is okay with `nginx -t` and then reload nginx `service nginx reload`

#### Links

* http://nginx.org/en/docs/http/ngx_http_geoip_module.html
* https://gist.github.com/VirtuBox/9ed03c9bd9169202c358a8be181b7840

[Zum Inhaltsverzeichnis](https://wiki.page-speed.ninja/)
