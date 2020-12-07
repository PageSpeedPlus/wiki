# Bash Skripten

## Dateirechte

* `chmod -Rf 750 /usr/local/ispconfig/interface/web/themes/squared/`
* `chown -Rf ispconfig:ispconfig /usr/local/ispconfig/interface/web/themes/`


***


## > - Ausgabe umleiten

_**>**_ - Inhalt des Zielfile wird ersetzt durch eine Ausgabe:

`echo $HOSTNAMESHORT > /etc/hostname`

_**>>**_ - Ausgabe wird an Zielfiel angehängt:

`echo $HOSTNAMESHORT >> /etc/hostname`



***



## apt/apt-get - Verwendung in Skripten

Die Hilfeseiten empfehlen, apt nicht in Skripten zu benutzen, da es nicht zwingend abwärtskompatibel und nicht als Entwicklerwerkzeug konzipiert wurde. Dies wird auch in der Manpage zu apt explizit hervorgehoben:

"Die apt(8)-Befehlszeile wurde als Endanwenderwerkzeug entworfen und kann bei Versionswechseln die Ausgabe ändern. Obwohl es versucht, nicht die Abwärtskompatibilität zu unterbrechen, kann sie nicht garantiert werden. Alle Funktionalitäten von apt(8) sind in apt-cache(8) und apt-get(8) über APT-Optionen verfügbar. Bitte benutzen Sie vorzugsweise diese Befehle in Ihren Skripten."

https://wiki.ubuntuusers.de/apt/apt/#Vergleiche-apt-get-apt



***



## hostname

``printf "Die Domain lautet %s und besitzt die IP-Adresse %s\n" `hostname -f` `hostname -I``



***



## export

```bash
export HOSTNAMESHORT="server1"
echo $HOSTNAMESHORT > /etc/hostname
/etc/init.d/hostname.sh start
```

* http://openbook.rheinwerk-verlag.de/shell_programmierung/shell_004_005.htm#RxxKap00400504004DB11F020172



***



## systemctl

* `systemctl restart nginx`
* `systemctl start nginx`
* `systemctl stop nginx`

anstatt:

`/etc/init.d/nginx restart` oder `service nginx restart`

https://www.youtube.com/watch?v=ApDkyByUHXw



***

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTc1MTk1NjMzMF19
-->