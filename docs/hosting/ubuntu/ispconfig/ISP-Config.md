## Where is the ISPConfig 3 configuration file?

ISPConfig 3 has two different configuration files, one for the server part and one for the interface.

### ISPConfig 3 Interface
The config file location is:

`/usr/local/ispconfig/interface/lib/config.inc.php`

### ISPConfig 3 Server

The config file location is:

`/usr/local/ispconfig/server/lib/config.inc.php`

### The MySQL root password that is used to create new MySQL databases only is stored in the file:

`/usr/local/ispconfig/server/lib/mysql_clientdb.conf`

## Where are the templates for the config files and default pages?

### The templates for the configuration files are located in the folder:

> /usr/local/ispconfig/server/conf/

### The templates for the default index pages are in the folder:

> /usr/local/ispconfig/server/conf/

### The templates for the error pages are in the folder:

> /usr/local/ispconfig/server/conf/error/

## Where are the templates for the config files and default pages?

### The templates for the configuration files are located in the folder:

> /usr/local/ispconfig/server/conf/

### The templates for the default index pages are in the folder:

> /usr/local/ispconfig/server/conf/

### The templates for the error pages are in the folder:

> /usr/local/ispconfig/server/conf/error/

### SSL for the ISPConfig 3 Controlpanel Login

> SSLCertificateFile /usr/local/ispconfig/interface/ssl/ispserver.crt
> SSLCertificateKeyFile /usr/local/ispconfig/interface/ssl/ispserver.key

***

## How to reset the administrator password in ISPConfig 3

If you lost your ISPConfig 3 administrator password, you can reset it with the following SQL query.

`UPDATE sys_user SET passwort = md5('admin') WHERE username = 'admin';`

The SQL query sets the password to "admin" for the user "admin", it has to be executed in the ISPConfig mysql database, e.g. with phpmyadmin. If you dont have phpmyadmin installed, then the query can be executed with the mysql commandline utility as well:

Login to the mysql database.

`mysql -u root -p`

Then enter the password of the mysql root user. To switch to the ISPConfig database, run this command:

use `dbispconfig`;

And execute the SQL command:

`UPDATE sys_user SET passwort = md5('admin') WHERE username = 'admin';`

Finally close the mysql shell:

`quit;`

## Debugging of ISPConfig 3 server actions in case of a failure

The follwing article describes the steps that can be taken to debug the ISPConfig 3 server scripts.

Enable the debug Loglevel in ISPConfig

Login to the ISPConfig intterface and set the log level to Debug under System > System > Server Config (see also chapter 4.9.2.2 of the ISPConfig 3 manual) for the affected server. After one or two minutes, there should be more detailed messages in ISPConfig's system log (Monitor > System State (All Servers) > Show System-Log).

### Disable the server.sh cronjob

Go to the command line of the server on which the error happens (on multiserver systems, it is often the slave and not the master) and run (as root):

> crontab -e

Comment out the server.sh cron job:

> * * * * * /usr/local/ispconfig/server/server.sh > /dev/null >> /var/log/ispconfig/cron.log
Run the server script manually to get detailed debug output

Then run the command:

> /usr/local/ispconfig/server/server.sh

This will display any errors directly on the command line which should help you to fix the error. When you have fixed the error, please don't forget to uncomment the server.sh cron job again.

https://www.faqforge.com/linux/debugging-ispconfig-3-server-actions-in-case-of-a-failure/

***

## How To Disable Error Logging For A Website In ISPConfig 3
https://www.faqforge.com/linux/how-to-disable-error-logging-for-a-website-in-ispconfig-3/

To disable the error.log for a website in ISPConfig on an Apache web server, follow this steps:

1) Login to ISPConfig

2) Go to the website settings of the website where you like to disable the error.log and there go to the "Options tab"

3) Add the following line in the field labeled "Apache Directives"

`ErrorLog /dev/null`

and press save:

## Which ports are used on a ISPConfig 3 server and shall be open in the firewall?

Here is a list of ports that are used commonly on ISPConfig 3 servers. If you don't have all services installed or if you e.g. don't want to connect to MySQL from external servers, then close the unused or unwanted ports.

### TCP ports

* 20 - FTP Data
* 21 - FTP Command
* 22 - SSH
* 25 - Email
* 53 - DNS
* 80 - HTTP (Webserver)
* 110 - POP3 (Email)
* 143 -Imap (Email)
* 443 - HTTPS (Secure web server)
* 993 - IMAPS (Secure Imap)
* 995 - POP3S (Secure POP3)
* 3306 - MySQL Database server
* 8080 - ISPConfig web interface
* 8081- ISPConfig apps vhost

### UDP ports

* 53 - DNS
* 3306 - MySQL

https://www.faqforge.com/linux/which-ports-are-used-on-a-ispconfig-3-server-and-shall-be-open-in-the-firewall/

***

## Login Formular für ISPConfig von externer Webseite

```html
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.js"></script>

<form name="ajaxform" id="ajaxform"  method="POST"  >
    <input type="hidden" name="s_mod" value="login">
    <input type="hidden" name="s_pg" value="index">
    <input name="username" id="username" value="" size="30" maxlength="255" type="text">
    <input name="passwort" id="passwort" value="" size="30" maxlength="255" type="password">
    <button type="submit" class="button" value=""  ><span>Anmelden</span></button>
</form>

<script type="text/javascript">
    //callback handler for form submit
    $("#ajaxform").submit(function()
    {
        var postData = $(this).serializeArray();
        $.ajax({
            url : 'https://isp.tld:8080/content.php',
            type: "POST",
            data : postData,
            xhrFields: {withCredentials: true},
            success:function(){
                window.location.replace("https://isp.tld:8080/index.php");
            }
        });
        return false;
    });
</script>
```

Erlaube nun die Domain der Webseite die das Formular hostet mit `nano /usr/local/ispconfig/lib/config.inc.local.php`

```php
<?php 
    header('Access-Control-Allow-Origin: http://www.lktechnik.ch'); 
    header('Access-Control-Allow-Methods: POST'); 
    header('Access-Control-Allow-Credentials: true');
```
***
## Eigens Logo verwenden

Also, wenn ich alle Lösungen hier beitreten, um das Logo mit einer benutzerdefinierten PNG-Datei (200x65px) zu ändern, alles, was Sie tun müssen, füllen Sie die `dbispconfig.sys_ini.custom_logo` Feld mit der Ausgabe dieses Befehls:
```bash
echo "data:image/png;base64,`base64 < path/to/your/custom_logo.png | tr -d '\n'`"​
```
Ersetzen Sie `path/to/your/custom_logo.png`` entsprechend. Sie müssen die richtigen Symbole (',' und ') im Kopf haben, wenn während des Kopierens und Einfügens etwas übersehen wird.

***

## Reduce load of backup scripts with nice and ionice

Runing a nightly backup script on a server system like a webhosting server can produce high load and longer latencys for other processes, e.g. HTML or .php pages load slow during backup because the backup script takes too much I/O or CPU resources.

On Linux systems there are two shell utilitys available to set the I/O and CPU Scheduling for a appliaction or script. The utilitys are named nice and ionice.

Reduce the I/O priority of the script "/usr/local/bin/backup.sh" so that it does not disrupt other processes:

`/usr/bin/ionice -c2 -n7 /usr/local/bin/backup.sh`

The -n parameter must be between 0 and 7, where lower numbers mean higher priority.

To reduce the CPU priority, use the command nice:
```bash
/usr/bin/nice -n 19 /usr/local/bin/backup.sh
```

The -n parameter can range from -20 to 19, where lower numbers mean higher priority

Nice and ionice can also be combined, to run a script at low I/O and CPU priority:
```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c2 -n7 /usr/local/bin/backup.sh
```
https://www.faqforge.com/linux/reduce-load-of-backup-scripts-with-nice-and-ionice/
***
