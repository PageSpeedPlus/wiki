## ionCube Loader PHP 7.0 - 7.2 installieren (Debian, Nginx)

How to install Ioncube Loader with Ubuntu, PHP7 and NGINX
Solved, after some tinkering, how to install for real Ioncube with PHP7 and NGINX running on Ubuntu.
The first thing to do it is to figure out which version of PHP you have.

> php -v 

The output should look like:

PHP 7.0.18-0ubuntu0.16.04.1 (cli) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2017 Zend Technologies
In this case the major version of PHP we’re running is 7.0.

The next step is to figure out if we’re using a 32 or 64bits operating system.
Run:

> dpkg --print-architecture

Which will give this output for a 64-bits architecture:

> amd64

And this for a 32-bits one:

> i386

Next step is to find which one is the correct extension location for PHP.
Run:

> php -i | grep extension_dir

And the output will look like this:

> extension_dir => /usr/lib/php/20151012 => /usr/lib/php/20151012

We can move into the extension folder:

> cd /usr/lib/php/20151012

and get the appropriate version of ioncube for our system:
For 32-bits systems:

> wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz

For 64-bits systems:

> wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

At this point we can extract the package we just downloaded:

> tar -xvf ioncube_loaders_lin_x86-64.tar.gz

and get the proper Ioncube extension file while cleaning up of the rest.
Make sure to get the proper version of ioncube for your php. In my case I am going to copy lin_7.0.

> mv ./ioncube/ioncube_loader_lin_7.0.so ./
> rm -Rf ./ioncube

Add ioncube to the PHP conf

Let’s move into the php config directory which is where we are going to create a new config file for the CLI and PHP-fpm. Here as well pay attention to the version of PHP that you’re running as you might have old installations.

> cd /etc/php/7.0/mods-available/

Let’s create the extension file for ioncube and let’s populate it with the location of the extension we want to load:

> echo "zend_extension = /usr/lib/php/20151012/ioncube_loader_lin_7.0.so" > ioncube.ini
Almost finished: we need to create symlinks into the cli and fpm folders:

> ln -s /etc/php/7.0/mods-available/ioncube.ini /etc/php/7.0/cli/conf.d/01-ioncube.ini
> ln -s /etc/php/7.0/mods-available/ioncube.ini /etc/php/7.0/fpm/conf.d/01-ioncube.ini


At this point we should be able to restart and use ioncube:

> service php7.0-fpm restart

If everything were fine we should be able to run:

> php -v

Which will output something like:

PHP 7.0.18-0ubuntu0.16.04.1 (cli) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2017 Zend Technologies
    with the ionCube PHP Loader (enabled) + Intrusion Protection from ioncube24.com (unconfigured) v6.1.0 (), Copyright (c) 2002-2017, by ionCube Ltd.
If instead you get an error such as:

Failed loading /usr/lib/php/20151012/ioncube_loader_lin_7.0.so: wrong ELF class: ELFCLASS32
or:

Failed loading /usr/lib/php/20151012/ioncube_loader_lin_7.0.so: /usr/lib/php/20151012/ioncube_loader_lin_7.0.so: wrong ELF class: ELFCLASS64
it means that you’re using the wrong ioncube version for your system. In that case you just need to swap the file under /usr/lib/php/20151012/ioncube_loader_lin_7.0.so with the correct one and restart php.

http://blog.maurizionapoleoni.com/how-to-install-ioncube-loader-with-ubuntu-php7-and-nginx/

## WHMCS installieren

1. Dateien hochladen
2. configuration.php.new in configuration.php umbennen
3. Datenbank angaben ausfüllen
4. Konto erstellen
5. install Ordner löschen