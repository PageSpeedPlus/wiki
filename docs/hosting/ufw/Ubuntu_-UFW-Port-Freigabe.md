## Ubuntu UFW: Server-Absicherung durch die gezielte Port-Freigabe

> Ubuntu UFW versteht sich als pflegeleichtes Firewall-Konfigurationstool, welches eine bequeme Steuerung von Einträgen in „iptables“ erlaubt.

In Ubuntu 14.04 vorinstalliert, erlaubt [UFW](http://wiki.ubuntuusers.de/ufw) (= Uncomplicated Firewall) eine Kommandozeile-basierende Pflege der Ports bzw. Protokollen auf der Firewall-Ebene. Die „Abdichtung“ der Server-Ports ist somit eine Sache von Minuten und kann von Systemadministratoren ab dem Einsteiger-Level vorgenommen werden.


### UFW Port-Freigabe

Nachfolgende Konsole-Befehle setzen [Standards-Ports](http://de.wikipedia.org/wiki/Liste_der_standardisierten_Ports) für SSH (_22_), HTTP (_80_) und HTTPS (_443_) auf die Whitelist der Firewall und gewähren Zutritt. Die letzte Zeile setzt die restlichen Ports auf die Blacklist, der Zugang wird also verweigert. Sind au dem Server weitere Ports in Verwendung, gehören diese ebenfalls als _UFW_ Regel hinzugefügt.

```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw default deny
```

_Wichtig_: Es empfiehlt sich, die genannten Ports stets freizuschalten, andernfalls würde man sich als SSH-Nutzer aussperren und den kompletten Web-Traffic via HTTP(S) blockieren.


### UFW Aktivierung

```bash
ufw enable
```

_Hinweis_: Eventuelle Sicherheitsabfrage mit „y“ bestätigen.


### UFW Firewall-Einträge

Zur Kontrolle kann die Liste mit festgelegten Zugriffsregeln bzw. erlaubten Ports eingeblendet werden:

```bash
ufw status
```

_Hinweis_: Die Liste beinhalten Ports sowohl für IPv4 wie IPv6.


### UFW Logging-Aktivierung

Auf Wunsch schreibt _UFW_ jede Aktivität in die System-Logdatei ```/var/log/syslog```, um vom Administrator eingesehen zu werden.

```bash
ufw logging on
```

Mithilfe des Parameters _off_ erfolgt die Deaktivierung der _UFW_ Logging-Funktion.

---

###### Fazit

_Ubuntu UFW_ ist eine sinnvolle Ergänzung zu _Fail2Ban_ als Maßnahme zur Absicherung des Webservers und darf auf keiner öffentlich zugänglichen Ubuntu-Instanz fehlen!