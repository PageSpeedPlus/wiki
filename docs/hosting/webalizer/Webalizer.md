The language of the generated Webalizer statistics is statically compiled into the Webalizer binary. To change the language, Webalizer has to be recompiled. In the following example, I will recompile Webalizer to change the language to german.

## Uninstall Webalizer and install the GD library:

> apt-get remove webalizer
> apt-get install libgd2-xpm-dev

Download the latest Webalizer sources and uncompress the tar archive:

[Webalizer Repo](ftp://ftp.mrunix.net/pub/webalizer/)

> cd /tmp
> wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-2.23-08-src.tgz
> tar xzf webalizer-2.23-08-src.tgz
> cd webalizer-2.23-08

Reconfigure and compile Webalizer: [Alle Optionen](ftp://ftp.mrunix.net/pub/webalizer/INSTALL)

> ./configure --with-language=german --enable-dns --enable-geoip --sysconfdir=/etc --enable-bz2
> make
> make install

Create a symlink so that other applications find the Webalizer binary in the common place:

> ln -s /usr/local/bin/webalizer /usr/bin/webalizer

Cleanup:

> rm -f /tmp/webalizer-2.23-08-src.tgz
> rm -rf /tmp/webalizer-2.23-08