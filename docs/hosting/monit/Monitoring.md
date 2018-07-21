## Monit

apt-get install monit
Configure Monit by

nano /etc/monit/monitrc
set httpd port 2812 and use address localhost # only accept connection from localhost allow localhost # allow localhost to connect to the server allow admin:monit # require user 'admin' with password 'monit' allow @monit # allow users group 'monit' to connect (rw) allow @users readonly # allow users group 'users' to connect (r)

Add monitoring service Nginx

> check process nginx with pidfile /var/run/nginx.pid
> start program = "/etc/init.d/nginx start"
> stop program = "/etc/init.d/nginx stop"
> Zeit

> check process ntpd with pidfile /var/run/ntpd.pid
> start program = "/etc/init.d/ntpd start"
> stop program = "/etc/init.d/ntpd stop"
> if failed host 127.0.0.1 port 123 type udp then alert
> ClamAV

> check process clamavd with pidfile /var/run/clamd.pid
> group virus
> start program = "/etc/init.d/clamavd start"
> stop program = "/etc/init.d/clamavd stop"
> if failed unixsocket /var/run/clamd then restart
> depends on clamavd_bin
> depends on clamavd_rc
> System

> check system $HOST
> if loadavg (5min) > 3 then alert
> if loadavg (15min) > 1 then alert
> if memory usage > 80% for 4 cycles then alert
> if swap usage > 20% for 4 cycles then alert
> if cpu usage (user) > 80% for 2 cycles then alert
> if cpu usage (system) > 20% for 2 cycles then alert
> if cpu usage (wait) > 80% for 2 cycles then alert
> if cpu usage > 200% for 4 cycles then alert

https://mmonit.com/wiki/Monit/ConfigurationExamples

## Monit-Graph

You can use commercial version M/Monit for a lot many features or free script monit-graph

**Final step: Graphing the server performance**

This is the second part, and where Monit-Graph get’s into the picture. Monit-Graph is based on PHP and are using Google Charts to display graphical statistics.

[Download the zip of Monit-Graph](https://github.com/danschultzer/monit-graph/zipball/master), unpack it, and upload it to your server, in whatever directory you wish use to access the statistics.

**Follow these steps:**

- Set apache or nginx to serve monit-graph from `/path/to/monit/src/web/public/` [you can find configuration examples for nginx, iis, etc here](https://www.slimframework.com/docs/v3/start/web-servers.html)).
- Change permissions (chmod) for the ./data directory to 777.
- Change permissions (chmod) for ./data/.keep to 644.
- Copy ./config/servers.template.ini to ./config/servers.ini and modify to match your setup of monit as well as needs of graphing.

**Setup a crontab job to run cron.php every minute.**

Example: `* * * * * php /path/to/monit/src/scripts/cron.php >>/var/log/monit-graph.log`

Verify after a few minutes of running that the logging happens. You can check the php error log if there seams to be something wrong.
One last part you wish to do is to password protect the directory. This can be done through .htaccess.

Now you can access the statistics through your webbrowser! You are now able to select specific processes to monitor and it has a memory leak, or other issues. Also you can simply graph the whole servers usage to find e.g. peak hours.

### Nginx configuration

This is an example Nginx virtual host configuration for the domain example.com. It listens for inbound HTTP connections on port 80. It assumes a PHP-FPM server is running on port 9000. You should update the server_name, error_log, access_log, and root directives with your own values. The root directive is the path to your application’s public document root directory; your Slim app’s index.php front-controller file should be in this directory.

https://www.slimframework.com/docs/start/web-servers.html

https://dreamconception.com/tech/tools/measure-your-server-performance-with-monit-and-monit-graph/

https://github.com/danschultzer/monit-graph

## Festplatten Gesundheit

http://www.linux-community.de/Internal/Artikel/Print-Artikel/LinuxUser/2004/10/Die-Zuverlaessigkeit-von-Festplatten-ueberwachen-mit-smartmontools
